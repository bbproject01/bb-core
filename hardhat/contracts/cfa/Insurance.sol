// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "../utils/GlobalMarker.sol";
import "../utils/Registry.sol";
import "./interface/IInsurance.sol";
import "./Referral.sol";

contract Insurance is
    IInsurance,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    /**
     * Use
     */
    using Strings for uint256;

    /**
     * Local variables
     */
    Metadata public metadata;
    Registry public registry;
    Referral public referral;
    System public system;

    mapping(uint256 => uint256) public interestRate;
    mapping(uint256 => Attributes) public attributes;
    mapping(uint256 => Loan) public loan;

    /**
     * Modifiers
     */

    /**
     * Events
     */
    event InsuranceCreated(Attributes _attributes);
    event InsuranceWithdrawn(uint256 _id, uint256 _amount, uint256 _time);
    event InsuranceBurned(Attributes _attributes, uint256 _time);
    event LoanCreated(uint256 _id, uint256 _totalLoan);
    event LoanRepaid(uint256 _id);
    event MetadataUpdate(uint256 _tokenId);

    /**
     * Constructor
     */

    function initialize() external initializer {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        system.idCounter = 1;
    }

    /**
     * Main Functions
     */
    function _saveAttributes(Attributes memory _attributes) internal {
        require(
            interestRate[_attributes.timePeriod] != 0,
            "Insurance: invalid time period"
        );

        _attributes.timeCreated = block.timestamp;
        _attributes.cfaLife = block.timestamp + (30 days * 12 * 30); // 30 Years of CFA Life
        _attributes.effectiveInterestTime = _attributes.timeCreated;
        _attributes.interest = GlobalMarker(
            registry.getContractAddress("GlobalMarker")
        ).getInterestRate();
        attributes[system.idCounter] = _attributes;
    }

    function _mintInsurance(
        Attributes memory _attributes,
        address caller
    ) internal {
        BBToken token = BBToken(registry.getContractAddress("BbToken"));

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
            uint256 discounted = ((_attributes.principal * discount) / 10000);
            token.mint(address(this), discounted);
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
        emit InsuranceCreated(_attributes);
    }

    function mintInsurance(
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
        for (uint256 i = 0; i < _qty; i++) {
            require(
                interestRate[_attributes.timePeriod] != 0,
                "Insurance: invalid time period"
            );
            _mintInsurance(_attributes, msg.sender);
            system.idCounter++;
            system.totalActiveCfa++;
        }
    }

    function withdraw(
        uint256 _id,
        uint256 _amount,
        uint256 _interest
    ) external nonReentrant {
        // (uint256 interest, uint256 totalPrincipal) = getInterest(_id); // interest = total yielded interest, totalPrincipal = principal + interest
        // require(block.timestamp < attributes[_id].cfaLife, 'Insurance: insurance has expired');
        require(balanceOf(msg.sender, _id) == 1, "Insurance: invalid id");
        require(
            _amount <= (attributes[_id].principal + _interest),
            "Insurance: invalid amount"
        );
        require(!loan[_id].onLoan, "Insurance: On Loan");

        attributes[_id].principal += _interest;
        attributes[_id].principal -= _amount;

        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.mint(address(this), _interest);
        token.transfer(msg.sender, _amount);

        if (attributes[_id].principal < 1000000000000000000) {
            emit InsuranceBurned(attributes[_id], block.timestamp);
            delete attributes[_id];
            _burn(msg.sender, _id, 1);
            system.totalActiveCfa--;
        } else {
            attributes[_id].effectiveInterestTime +=
                getIterations(_id) *
                attributes[_id].timePeriod;
        }
        system.totalPaidAmount += _interest;
        emit InsuranceWithdrawn(_id, _amount, block.timestamp);
        emit MetadataUpdate(_id);
    }

    /**
     * Write Functions
     */
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

    function setInterestRate(
        uint256[] memory _period,
        uint256[] memory _interestRate
    ) external onlyOwner {
        require(
            _period.length == _interestRate.length,
            "Insurance: invalid length"
        );
        for (uint256 i = 0; i < _period.length; i++) {
            interestRate[_period[i]] = _interestRate[i];
        }
    }

    /**
     * Read Functions
     */
    function getIterations(uint256 _id) public view returns (uint256) {
        uint256 totalIterations = (block.timestamp -
            attributes[_id].effectiveInterestTime) / getTimePeriod(_id);
        if (block.timestamp > attributes[_id].cfaLife) {
            totalIterations =
                (attributes[_id].cfaLife -
                    attributes[_id].effectiveInterestTime) /
                getTimePeriod(_id);
        }
        return totalIterations;
    }

    function getInterestRate(uint256 _period) public view returns (uint256) {
        require(interestRate[_period] != 0, "Insurance: invalid period");
        return interestRate[_period];
    }

    function getInsuranceInterest(uint256 _id) external view returns (uint256) {
        uint256 period = attributes[_id].timePeriod;
        return getInterestRate(period);
    }

    function getInterest(uint256 _id) public view returns (uint256, uint256) {
        uint256 principal = attributes[_id].principal;
        uint256 interest = getInterestRate(attributes[_id].timePeriod);
        uint256 iterations = getIterations(_id);
        uint256 totalInterest = 0;

        if (iterations == 0) {
            return (0, principal);
        }

        for (uint256 i = 0; i < iterations; i++) {
            uint256 tempInterest = (principal * interest) / 10000;
            principal += tempInterest;
            totalInterest += tempInterest;
        }

        return (totalInterest, principal);
    }

    function getImage() public view returns (string memory) {
        string memory image = metadata.image;
        return image;
    }

    function setImage(string memory _image) external onlyOwner {
        metadata.image = _image;
    }

    function getTimePeriod(uint256 _id) internal view returns (uint256) {
        if (attributes[_id].timePeriod == 3) {
            return 3 * 30 days;
        } else if (attributes[_id].timePeriod == 1) {
            return 12 * 30 days;
        } else if (attributes[_id].timePeriod == 2) {
            return 24 * 30 days;
        } else if (attributes[_id].timePeriod == 5) {
            return 60 * 30 days;
        } else if (attributes[_id].timePeriod == 10) {
            return 120 * 30 days;
        } else {
            revert("Invalid Period");
        }
    }

    function getPeriodString(
        uint256 _period
    ) internal pure returns (string memory) {
        if (_period == 3) {
            return "3 months";
        } else if (_period == 1) {
            return "1 year";
        } else if (_period == 2) {
            return "2 years";
        } else if (_period == 5) {
            return "5 years";
        } else if (_period == 10) {
            return "10 years";
        } else {
            revert("Invalid Period, Please Contact Support");
        }
    }

    function getPeriodName(
        uint256 _period
    ) internal pure returns (string memory) {
        if (_period == 3) {
            return "3M-";
        } else if (_period == 1) {
            return "1Y-";
        } else if (_period == 2) {
            return "2Y-";
        } else if (_period == 5) {
            return "5Y-";
        } else if (_period == 10) {
            return "10Y-";
        } else {
            revert("Invalid Period, Please Contact Support");
        }
    }

    function getMetadata(uint256 _tokenId) public view returns (string memory) {
        string memory basicInfo = getBasicInfo(_tokenId);
        string memory attributesInfo = getAttributesInfo(_tokenId);
        string memory loanInfo = getLoanInfo(_tokenId);

        return
            string(
                abi.encodePacked("{", basicInfo, attributesInfo, loanInfo, "]}")
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
                    getPeriodName(attributes[_tokenId].timePeriod),
                    Strings.toString(_tokenId),
                    '",',
                    '"description":"',
                    metadata.description,
                    '",',
                    '"image":"',
                    getImage(),
                    '",',
                    '"attributes": ['
                )
            );
    }

    function getAttributesInfo(
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
                    '{ "trait_type": "Period", "value": "Every ',
                    getPeriodString(attributes[_tokenId].timePeriod),
                    '" },',
                    '{ "trait_type": "Principal", "value": "',
                    (attributes[_tokenId].principal / 1 ether).toString(),
                    '" },',
                    '{ "trait_type": "Loan Status", "value": "',
                    (loan[_tokenId].onLoan ? "On Loan" : "Not on Loan"),
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
        require(balanceOf(msg.sender, _id) == 1, "Insurance: invalid id");
        require(!loan[_id].onLoan, "Insurance: Loan already created");
        require(
            block.timestamp < attributes[_id].cfaLife,
            "Insurance: insurance has expired"
        );

        uint256 loanedPrincipal = ((attributes[_id].principal +
            _yieldedInterest) * 25) / 100;
        BBToken token = BBToken(registry.getContractAddress("BbToken"));
        token.mint(msg.sender, loanedPrincipal);

        loan[_id].onLoan = true;
        loan[_id].loanBalance = loanedPrincipal;
        loan[_id].timeWhenLoaned = block.timestamp;

        emit LoanCreated(_id, loanedPrincipal);
        emit MetadataUpdate(_id);
    }

    function repayLoan(uint256 _id, uint256 _amount) external nonReentrant {
        require(loan[_id].onLoan, "Insurance: Loan invalid");
        require(
            _amount <= loan[_id].loanBalance,
            "Insurance: Incorrect loan repayment amount"
        );

        IERC20(registry.getContractAddress("BbToken")).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (_amount < loan[_id].loanBalance) {
            loan[_id].loanBalance -= _amount;
        } else if ((loan[_id].loanBalance - _amount) <= 100000000000000) {
            uint256 timePassed = block.timestamp - loan[_id].timeWhenLoaned;
            attributes[_id].cfaLife += timePassed;
            uint256 oldTime = attributes[_id].effectiveInterestTime;
            attributes[_id].effectiveInterestTime =
                block.timestamp -
                (loan[_id].timeWhenLoaned - oldTime);
            loan[_id].loanBalance = 0;
            loan[_id].onLoan = false;
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
     * Override Functions
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
        uint256 timeadjustment = 30 days * 12 * 30;
        attributes[_id].effectiveInterestTime -= timeadjustment;
        attributes[_id].cfaLife = block.timestamp;
    }

    function changeTimeManually(uint256 _id, uint256 _timeAdjustment) external {
        // Same as changeTimeToEndOfProduct but with manual timeadjustments
        require(
            balanceOf(msg.sender, _id) >= 1,
            "Income:: You are not the owner of this product!"
        );
        uint256 timeadjustment = _timeAdjustment;
        attributes[_id].effectiveInterestTime -= timeadjustment;
    }
}
