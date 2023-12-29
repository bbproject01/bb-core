// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interface/ISavings.sol";
import "./Referral.sol";
import "../utils/Registry.sol";
import "../utils/GlobalMarker.sol";

contract Savings is
    ISavings,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Strings for uint256;

    /**
     * Local variables
     */
    System public system;
    Referral public referral; // Referral contract
    Registry public registry; // The registry contract
    Life public life; // max and minimum life of Savings CFA
    Metadata public metadata; // The metadata of the Savings CFA
    GlobalMarker public globalMarker; // the supply and Interest marker

    mapping(uint256 => Loan) public loan;
    mapping(uint256 => Attributes) public attributes;

    /**
     * Events
     */
    event SavingsCreated(Attributes _attribute);
    event SavingsWithdrawn(Attributes _attribute, uint256 _time);
    event SavingsBurned(Attributes _attribute, uint256 _time);
    event LoanCreated(uint256 _id, uint256 _totalLoan);
    event LoanRepaid(uint256 _id);

    /**
     * Modifier
     */

    /**
     * Constructor
     */
    // constructor() ERC1155Upgradeable() {
    //     system.idCounter = 1;
    // }
    function initialize() public initializer {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        system.idCounter = 1;
    }

    /**
     * Main Function
     */

    function _saveAttributes(Attributes memory _attributes) internal {
        require(
            _attributes.cfaLife >= life.min && life.max >= _attributes.cfaLife,
            "Savings: Invalid CFA life duration"
        );
        _attributes.timeCreated = block.timestamp - 365 days; // remove - 1 year for mainnet
        _attributes.effectiveInterestTime = block.timestamp - 365 days; // remove - 1 year for mainnet
        _attributes.interestRate = GlobalMarker(
            registry.getContractAddress("GlobalMarker")
        ).getInterestRate();
        attributes[system.idCounter] = _attributes;
    }

    function _mintSavings(
        Attributes memory _attributes,
        address caller
    ) internal {
        if (
            (
                Referral(registry.getContractAddress("Referral"))
                    .eligibleForReward(caller)
            )
        ) {
            Referral(registry.getContractAddress("Referral")).rewardForReferrer(
                    caller,
                    _attributes.principal
                );
            uint256 discount = Referral(registry.getContractAddress("Referral"))
                .getReferredDiscount();
            uint256 amtPayable = _attributes.principal -
                ((_attributes.principal * discount) / 10000);
            IERC20(registry.getContractAddress("BbToken")).transferFrom(
                msg.sender,
                address(this),
                amtPayable
            );
        } else {
            IERC20(registry.getContractAddress("BbToken")).transferFrom(
                msg.sender,
                address(this),
                _attributes.principal
            );
        }
        _mint(msg.sender, system.idCounter, 1, "");
        _saveAttributes(_attributes);
        emit SavingsCreated(_attributes);
    }

    function mintSavings(
        Attributes[] memory _attributes,
        address _referrer
    ) external nonReentrant {
        require(
            GlobalMarker(registry.getContractAddress("GlobalMarker"))
                .isInterestSet(),
            "GlobalSupply: Interest not yet set"
        );
        if (_referrer != address(0)) {
            Referral(registry.getContractAddress("Referral")).addReferrer(
                msg.sender,
                _referrer
            );
        }
        for (uint256 i = 0; i < _attributes.length; i++) {
            _mintSavings(_attributes[i], msg.sender);
            system.idCounter++;
        }
    }

    function _burnSavings(uint256 _id) internal {
        emit SavingsBurned(attributes[_id], block.timestamp);
        delete attributes[_id];
        _burn(msg.sender, _id, 1);
    }

    function withdrawSavings(
        uint256 _id,
        uint256 _amount
    ) external nonReentrant {
        require(
            block.timestamp >
                getTotalLife(
                    attributes[_id].timeCreated,
                    attributes[_id].cfaLife
                ),
            "Savings: CFA not yet matured"
        );
        require(!loan[_id].onLoan, "Savings: On Loan");

        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.transfer(msg.sender, attributes[_id].principal);
        token.mint(msg.sender, _amount);

        _burnSavings(_id);
        emit SavingsWithdrawn(attributes[_id], block.timestamp);
    }

    /**
     * Write Function
     */

    function setImage(string memory _image) external onlyOwner {
        metadata.image = _image;
    }

    function setMetadata(
        string memory _name,
        string memory _description
    ) external onlyOwner {
        metadata.name = _name;
        metadata.description = _description;
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = Registry(_registry);
    }

    function setLife(uint256 _min, uint256 _max) external onlyOwner {
        life.min = _min;
        life.max = _max;
    }

    /**
     * Read Function
     */

    function getTotalLife(
        uint256 _timeCreate,
        uint256 _cfaLife
    ) public pure returns (uint256) {
        uint256 cfaLife = _cfaLife * (12 * 30 days);
        uint256 totalLife = _timeCreate + cfaLife;
        return totalLife;
    }

    function getImage() public view returns (string memory) {
        string memory image = metadata.image;
        return image;
    }

    function getMetadata(uint256 _tokenId) public view returns (string memory) {
        string memory _metadata = string(
            abi.encodePacked(
                "{",
                '"name":"',
                metadata.name,
                " #",
                _tokenId.toString(),
                '",',
                '"description":',
                '"',
                metadata.description,
                '",',
                '"image":',
                '"',
                getImage(),
                '"',
                "}"
            )
        );

        return _metadata;
    }

    function getLoanBalance(uint _id) external view returns (uint256) {
        uint _loanBalance = loan[_id].loanBalance;
        return _loanBalance;
    }

    /**
     * Loan functions
     */

    function createLoan(
        uint256 _id,
        uint256 _yieldedInterest
    ) external nonReentrant {
        require(balanceOf(msg.sender, _id) == 1, "Savings: invalid id");
        require(!loan[_id].onLoan, "Savings: Loan already created");
        require(
            block.timestamp <
                getTotalLife(
                    attributes[_id].timeCreated,
                    attributes[_id].cfaLife
                ),
            "Savings: CFA has expired"
        );

        uint256 loanedPrincipal = ((attributes[_id].principal +
            _yieldedInterest) * 25) / 100;
        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.mint(msg.sender, loanedPrincipal);

        loan[_id].onLoan = true;
        loan[_id].loanBalance = loanedPrincipal;
        loan[_id].timeWhenLoaned = block.timestamp;

        emit LoanCreated(_id, (loanedPrincipal * 25) / 100);
    }

    function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
        require(loan[_id].onLoan, "Savings: Loan invalid");
        require(
            _amount <= loan[_id].loanBalance,
            "Savings: Incorrect loan repayment amount"
        );

        IERC20(registry.getContractAddress("BbToken")).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (_amount < loan[_id].loanBalance) {
            loan[_id].loanBalance -= _amount;
        } else {
            attributes[_id].effectiveInterestTime = block.timestamp;
            loan[_id].loanBalance = 0;
            loan[_id].onLoan = false;
            uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
            attributes[_id].cfaLife += timePassed; // Extends CFA life to make up for loaned time
        }

        BBToken(registry.getContractAddress("BbToken")).burn(_amount);

        emit LoanRepaid(_id);
    }

    /**
     * Override Functions
     */

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        // require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede transferir');
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Overrides the `burn` function to prevent burning of locked CFAs.
     */
    function burn(uint256 id) public {
        // require(attributes[id].soulBoundTerm == 0, 'CFA: El CFA esta bloqueado y no se puede quemar');
        _burn(msg.sender, id, 1);
    }

    // Override the `burnBatch` function to prevent burning of locked CFAs
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        // for (uint256 i = 0; i < ids.length; i++) {
        //   require(attributes[ids[i]].soulBoundTerm == 0, 'CFA: No se puede quemar un CFA bloqueado');
        // }
        this.burnBatch(account, ids, amounts);
    }

    function uri(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        bytes memory _metadata = abi.encodePacked(getMetadata(_tokenId));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(_metadata)
                )
            );
    }
}
