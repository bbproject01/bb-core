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
    System public system;
    Registry public registry;
    // GlobalMarker public globalMarker;
    // Referral public referral;
    Metadata public metadata;

    mapping(uint256 => Attributes) public attributes;
    mapping(uint256 => Loan) public loan;
    // mapping(uint256 => uint256) public lastClaimTime;

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
        system.idCounter = 1;
    }

    /**
     * Write function
     */
    function _setAttributes(
        Attributes memory _attributes
    ) internal {
        require(
            _attributes.paymentFrequency <= system.maxPaymentFrequency,
            "Income:: Invalid payment frequency"
        );
        require(
            _attributes.principalLockTime <= system.maxPrincipalLockTime,
            "Income:: Invalid principal lock time"
        );

        _attributes.timeCreated = block.timestamp;
        _attributes.beginningTimeForInterest = block.timestamp;
        _attributes.interest = GlobalMarker(
            registry.getContractAddress("GlobalMarker")
        ).getInterestRate();
        // commented because those time will be saved as is and not in unix
        // _attributes.paymentFrequency *= 30 days;
        // _attributes.principalLockTime *= 360 days;;
        _attributes.cfaLife =
            _attributes.timeCreated +
            (_attributes.principalLockTime * 360 days);
        _attributes.lastClaimTime = block.timestamp;
        attributes[system.idCounter] = _attributes;
    }

    function mintIncome(
        Attributes memory _attributes,
        uint256 _qty,
        address _referrer
    ) external {
        if (_referrer != address(0)) {
            Referral(registry.getContractAddress("Referral")).addReferrer(
                msg.sender,
                _referrer
            );
        }
        for (uint i = 0; i < _qty; i++) {
            if (
                (
                    Referral(registry.getContractAddress("Referral"))
                        .eligibleForReward(msg.sender)
                )
            ) {
                BBToken token = BBToken(registry.getContractAddress("BbToken"));
                Referral(registry.getContractAddress("Referral"))
                    .rewardForReferrer(msg.sender, _attributes.principal);
                uint256 discount = Referral(
                    registry.getContractAddress("Referral")
                ).getReferredDiscount();
                uint256 discounted = ((_attributes.principal * discount) /
                    10000);
                token.mint(address(this), discounted);
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
            _setAttributes(_attributes);
            _mint(msg.sender, system.idCounter, 1, "");
            system.idCounter++;
            system.totalActiveCfa++;
            system.totalRewardsToBeGiven += _attributes.totalPossibleReward;
        }
    }

    function withdrawIncome(uint256 _tokenId, uint256 _amount) public {
        require(
            balanceOf(msg.sender, _tokenId) >= 1,
            "Income:: Not product owner"
        );
        require(!loan[_tokenId].onLoan, "Income: On Loan");
        uint256 index;
        system.totalPaidAmount += _amount;
        system.totalRewardsToBeGiven -= _amount;
        attributes[_tokenId].incomePaid += _amount;
        (index, ) = getIndexes(_tokenId);
        index += attributes[_tokenId].claimedIndex;
        uint256 _lastClaimTime = block.timestamp -
            (block.timestamp -
                (attributes[_tokenId].lastClaimTime + (index * 30 days)));
        attributes[_tokenId].lastClaimTime = _lastClaimTime;
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
                attributes[_tokenId].beginningTimeForInterest +
                    (attributes[_tokenId].principalLockTime * 360 days),
            "Income:: Principal is locked"
        );
        require(!loan[_tokenId].onLoan, "Income: On Loan");

        IERC20 token = IERC20(registry.getContractAddress("BbToken"));
        token.transfer(msg.sender, attributes[_tokenId].principal);

        _burn(msg.sender, _tokenId, 1);
        system.totalActiveCfa--;
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
    ) public view returns (uint256, uint256) {
        uint256 timeDiff = (block.timestamp -
            attributes[_tokenId].lastClaimTime) /
            ((attributes[_tokenId].paymentFrequency * 30 days));
        uint256 currentIndex = 0;

        if (timeDiff > 0) {
            currentIndex = timeDiff;
        }

        if (
            currentIndex + attributes[_tokenId].claimedIndex >
            getTotalPossibleIndex(_tokenId)
        ) {
            return (
                getTotalPossibleIndex(_tokenId) -
                    attributes[_tokenId].claimedIndex,
                attributes[_tokenId].claimedIndex
            );
        } else {
            return (currentIndex, attributes[_tokenId].claimedIndex);
        }
    }

    function getInterest(uint256 _tokenId) external view returns (uint256) {
        uint256 cfaInterest = attributes[_tokenId].interest;
        return cfaInterest;
    }

    function getTotalPossibleIndex(
        uint256 _tokenId
    ) internal view returns (uint256) {
        uint256 index = (attributes[_tokenId].principalLockTime * 360 days) /
            (attributes[_tokenId].paymentFrequency * 30 days);
        return index;
    }

    // function getAccumulatedInterest(
    //     uint256 _interest,
    //     uint256 _id
    // ) internal view returns (uint256) {
    //     if (
    //         attributes[_id].lastClaimTime - block.timestamp <
    //         attributes[_id].paymentFrequency
    //     ) {
    //         return 0;
    //     } else {
    //         uint256 iterations = (attributes[_id].lastClaimTime -
    //             block.timestamp) / attributes[_id].paymentFrequency;
    //         uint256 computedInterest = iterations *
    //             ((_interest * attributes[_id].principal) / 10000);
    //         return computedInterest;
    //     }
    // }

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
                    '"name":"',
                    metadata.name,
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
                    '{ "trait_type": "Principal", "value": "',
                    (attributes[_tokenId].principal / 1 ether).toString(),
                    '" },',
                    '{ "trait_type": "Paid Up To Date", "value": "',
                    (attributes[_tokenId].incomePaid / 1 ether).toString(),
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
                        (loan[_tokenId].loanBalance / 1 ether).toString(),
                        '" }'
                    )
                );
        }
        return "";
    }

    /**
     * Loan functions
     */
    function getTimeBeforeNextPayment(
        uint256 _id
    ) internal view returns (uint256) {
        uint256 index;
        (index, ) = getIndexes(_id);
        uint256 timeLeft = (block.timestamp - attributes[_id].lastClaimTime) -
            ((index) * (attributes[_id].paymentFrequency * 30 days));
        return timeLeft;
    }

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
        token.mint(msg.sender, loanedPrincipal);
        loan[_id].timeBeforeNextPayment = getTimeBeforeNextPayment(_id);
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
        } else if ((loan[_id].loanBalance - _amount) <= 100000000000000) {
            attributes[_id].lastClaimTime = block.timestamp;
            loan[_id].loanBalance = 0;
            loan[_id].onLoan = false;
            uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
            attributes[_id].cfaLife += timePassed; // Extends CFA life to make up for loaned time
            attributes[_id].beginningTimeForInterest += timePassed; // Extends CFA life to make up for loaned time
            uint256 _lastClaimTime = block.timestamp -
                loan[_id].timeBeforeNextPayment;
            attributes[_id].lastClaimTime = _lastClaimTime;
        }
        BBToken(registry.getContractAddress("BbToken")).burn(_amount);

        emit LoanRepaid(_id);
        emit MetadataUpdate(_id);
    }

    function newExpiry(uint256 _id) external view returns (uint256) {
        uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
        uint256 _newExpiry = attributes[_id].cfaLife + timePassed;
        return _newExpiry;
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

    /**
     * Testing functions DELETE BEFORE DEPELOYMENT
     */

    function changeTimeToEndOfProduct(uint256 _id) external {
        /* WORKS ONLY IF:
         * The product has never been loaned
         * The product has never been withdrawn once
         */
        require(
            balanceOf(msg.sender, _id) >= 1,
            "Income:: You are not the owner of this product!"
        );
        uint256 timeadjustment = (attributes[_id].principalLockTime * 360 days);
        attributes[_id].lastClaimTime -= timeadjustment;
        attributes[_id].beginningTimeForInterest -= timeadjustment;
        attributes[_id].cfaLife = block.timestamp;
    }

    function changeTimeManually(uint256 _id, uint256 _timeAdjustment) external {
        // Same as changeTimeToEndOfProduct but with manual timeadjustments
        require(
            balanceOf(msg.sender, _id) >= 1,
            "Income:: You are not the owner of this product!"
        );
        uint256 timeadjustment = _timeAdjustment;
        attributes[_id].beginningTimeForInterest -= timeadjustment;
        attributes[_id].lastClaimTime -= timeadjustment;
    }
}
