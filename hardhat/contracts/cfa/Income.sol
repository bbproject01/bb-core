// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interface/IIncome.sol";
import "../token/BBTOKENv2.sol";
import "../utils/Registry.sol";
import "../utils/GlobalMarker.sol";
import "./Referral.sol";

contract Income is
    IIncome,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    /**
     * Uses
     */
    using Strings for uint256;

    /**
     * Local variables
     */
    System system;
    Registry public registry;
    // GlobalMarker public globalMarker;
    // Referral public referral;
    Metadata public metadata;

    mapping(uint256 => Attributes) public attributes;
    mapping(uint256 => Loan) public loan;
    // mapping(uint256 => uint256) public lastClaimTime;
    uint256 public idCounter;

    /**
     * Events
     */
    event IncomeCreated(Attributes _attributes);
    event IncomeWithdrawn(uint256 _id, uint256 _amount, uint256 _time);
    event IncomeBurned(uint256 _id, Attributes _attributes, uint256 _time);
    event LoanCreated(uint256 _id, uint256 _totalLoan);
    event LoanRepaid(uint256 _id);
    event MetadataUpdate(uint256 _tokenId);

    /**
     * Modifiers
     */

    /**
     * Construstor
     */
    // constructor() ERC1155("") {
    //     system.maxPaymentFrequency = 12;
    //     system.maxPrincipalLockTime = 50;
    // }

    function initialize() public initializer {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        system.maxPaymentFrequency = 12;
        system.maxPrincipalLockTime = 50;
        idCounter = 1;
    }

    /**
     * Write function
     */
    function _setAttributes(Attributes memory _attributes) internal {
        require(
            _attributes.paymentFrequency <= system.maxPaymentFrequency,
            "Income:: Invalid payment frequency"
        );
        require(
            _attributes.principalLockTime <= system.maxPrincipalLockTime,
            "Income:: Invalid principal lock time"
        );

        _attributes.timeCreated =
            block.timestamp -
            (365 days * (_attributes.principalLockTime - 1)); // remove - 1 year for mainnet
        _attributes.interest = GlobalMarker(
            registry.getContractAddress("GlobalMarker")
        ).getInterestRate();
        // commented because those time will be saved as is and not in unix
        // _attributes.paymentFrequency *= 30 days;
        // _attributes.principalLockTime *= 365 days;
        _attributes.cfaLife =
            _attributes.timeCreated +
            (_attributes.principalLockTime * 365 days);
        attributes[idCounter] = _attributes;
    }

    function mintIncome(
        Attributes[] memory _attributes,
        address _referrer
    ) external {
        if (_referrer != address(0)) {
            Referral(registry.getContractAddress("Referral")).addReferrer(
                msg.sender,
                _referrer
            );
        }
        for (uint i = 0; i < _attributes.length; i++) {
            if (
                (
                    Referral(registry.getContractAddress("Referral"))
                        .eligibleForReward(msg.sender)
                )
            ) {
                Referral(registry.getContractAddress("Referral"))
                    .rewardForReferrer(msg.sender, _attributes[i].principal);
                uint256 discount = Referral(
                    registry.getContractAddress("Referral")
                ).getReferredDiscount();
                uint256 amtPayable = _attributes[i].principal -
                    ((_attributes[i].principal * discount) / 10000);
                IERC20(registry.getContractAddress("BbToken")).transferFrom(
                    msg.sender,
                    address(this),
                    amtPayable
                );
            } else {
                IERC20(registry.getContractAddress("BbToken")).transferFrom(
                    msg.sender,
                    address(this),
                    _attributes[i].principal
                );
            }
            _setAttributes(_attributes[i]);
            _mint(msg.sender, idCounter, 1, "");
            idCounter++;
        }
    }

    function withdrawIncome(uint256 _tokenId, uint256 _amount) public {
        require(
            balanceOf(msg.sender, _tokenId) >= 1,
            "Income:: Not product owner"
        );
        if (msg.sender != address(this)) {
            attributes[_amount].incomePaid += _amount;
        }
        attributes[_tokenId].lastClaimTime = block.timestamp;
        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.mint(msg.sender, _amount);
        emit MetadataUpdate(_tokenId);
    }

    function withdrawPrincipal(uint256 _tokenId) external {
        require(
            balanceOf(msg.sender, _tokenId) >= 1,
            "Income:: Not product owner"
        );
        require(
            block.timestamp >=
                attributes[_tokenId].timeCreated +
                    (attributes[_tokenId].principalLockTime * 365 days),
            "Income:: Principal is locked"
        );

        IERC20 token = IERC20(registry.getContractAddress("BbToken"));
        token.transfer(msg.sender, attributes[_tokenId].principal);

        _burn(msg.sender, _tokenId, 1);
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = Registry(_registry);
    }

    function setTimeCreated(uint256 _id, uint256 _timeCreated) external {
        attributes[_id].timeCreated = _timeCreated;
    }

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

    /**
     * Read function
     */
    function getIndexes(
        uint256 _tokenId
    ) external view returns (uint256, uint256) {
        uint256 timeDiff = (block.timestamp -
            attributes[_tokenId].timeCreated) /
            ((attributes[_tokenId].paymentFrequency * 30 days));
        uint256 currentIndex = 0;
        uint256 claimedIndex = 0;

        if (timeDiff > 0) {
            currentIndex = timeDiff;
        }

        if (attributes[_tokenId].lastClaimTime > 0) {
            claimedIndex =
                (attributes[_tokenId].lastClaimTime -
                    attributes[_tokenId].timeCreated) /
                (attributes[_tokenId].paymentFrequency * 30 days);
        }

        return (currentIndex, claimedIndex);
    }

    function getInterest(uint256 _tokenId) external view returns (uint256) {
        uint256 cfaInterest = attributes[_tokenId].interest;
        return cfaInterest;

        // remove if not needed
    }

    function getAccumulatedInterest(
        uint256 _interest,
        uint256 _id
    ) internal view returns (uint256) {
        if (
            attributes[_id].lastClaimTime - block.timestamp <
            attributes[_id].paymentFrequency
        ) {
            return 0;
        } else {
            uint256 iterations = (attributes[_id].lastClaimTime -
                block.timestamp) / attributes[_id].paymentFrequency;
            uint256 computedInterest = iterations *
                ((_interest * attributes[_id].principal) / 10000);
            return computedInterest;
        }
    }

    function getMetadata(uint256 _tokenId) public view returns (string memory) {
        string memory basicInfo = getBasicInfo(_tokenId);
        string memory firstHalfAttributesInfo = getFirstHalfAttributesInfo(
            _tokenId
        );
        string memory secondHalfAttributesInfo = getSecondHalfAttributesInfo(
            _tokenId
        );
        string memory loanInfo = getLoanInfo(_tokenId);

        return
            string(
                abi.encodePacked(
                    "{",
                    basicInfo,
                    firstHalfAttributesInfo,
                    secondHalfAttributesInfo,
                    loanInfo,
                    "]}"
                )
            );
    }

    function getBasicInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '"name":"INC1-',
                    Strings.toString(_tokenId),
                    '",',
                    '"description":"',
                    metadata.description,
                    '",',
                    '"image":"',
                    metadata.image,
                    '",',
                    '"attributes": ['
                )
            );
    }

    function getFirstHalfAttributesInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{ "trait_type": "Date Started", "display_type": "date", "value": "',
                    attributes[_tokenId].timeCreated.toString(),
                    '" },',
                    '{ "trait_type": "Date Finishing", "display_type": "date", "value": "',
                    attributes[_tokenId].cfaLife.toString(),
                    '" },',
                    '{ "trait_type": "CFA Life", "value": "',
                    Strings.toString(attributes[_tokenId].principalLockTime),
                    ' years" },'
                )
            );
    }

    function getSecondHalfAttributesInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{ "trait_type": "Principal", "display_type": "number", "value": "',
                    attributes[_tokenId].principal.toString(),
                    '" },',
                    '{ "trait_type": "Paid Up To Date", "display_type": "number", "value": "',
                    attributes[_tokenId].incomePaid.toString(),
                    '" },',
                    '{ "trait_type": "Loaned", "value": "',
                    (loan[_tokenId].onLoan ? "true" : "false"),
                    '" }'
                )
            );
    }

    function getLoanInfo(
        uint256 _tokenId
    ) internal view returns (string memory) {
        if (loan[_tokenId].onLoan) {
            return
                string(
                    abi.encodePacked(
                        ', { "trait_type": "Loan Time Created", "display_type": "date", "value": "',
                        loan[_tokenId].timeWhenLoaned.toString(),
                        '" },',
                        '{ "trait_type": "Loan Balance", "value": "',
                        loan[_tokenId].loanBalance.toString(),
                        '" }'
                    )
                );
        }
        return "";
    }

    /**
     * Loan functions
     */

    function createLoan(uint256 _id, uint256 _amount) external nonReentrant {
        require(balanceOf(msg.sender, _id) == 1, "Income: invalid id");
        require(!loan[_id].onLoan, "Income: Loan already created");
        require(
            block.timestamp < attributes[_id].cfaLife,
            "Income: Income has expired"
        );

        // uint256 interest = getAccumulatedInterest(attributes[_id].interest, _id);
        if (_amount != 0) {
            withdrawIncome(_id, _amount);
        }
        uint256 loanedPrincipal = ((attributes[_id].principal) * 25) / 100;
        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.mint(address(this), loanedPrincipal);

        loan[_id].onLoan = true;
        loan[_id].loanBalance = loanedPrincipal;
        loan[_id].timeWhenLoaned = block.timestamp;

        emit LoanCreated(_id, loanedPrincipal);
        emit MetadataUpdate(_id);
    }

    function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
        require(loan[_id].onLoan, "Income: Loan invalid");
        require(
            _amount <= loan[_id].loanBalance,
            "Income: Incorrect loan repayment amount"
        );

        IERC20(registry.getContractAddress("BbToken")).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (_amount < loan[_id].loanBalance) {
            loan[_id].loanBalance -= _amount;
        } else {
            attributes[_id].lastClaimTime = block.timestamp;
            loan[_id].loanBalance = 0;
            loan[_id].onLoan = false;
            uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
            attributes[_id].cfaLife += timePassed; // Extends CFA life to make up for loaned time
            uint256 _lastClaimTime = (((((block.timestamp -
                attributes[_id].lastClaimTime) /
                attributes[_id].paymentFrequency) + 1) *
                attributes[_id].paymentFrequency) +
                attributes[_id].lastClaimTime) - block.timestamp;
            attributes[_id].lastClaimTime = _lastClaimTime;
        }
        BBToken(registry.getContractAddress("BbToken")).burn(_amount);

        emit LoanRepaid(_id);
        emit MetadataUpdate(_id);
    }

    /**
     * Overrides
     */

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
