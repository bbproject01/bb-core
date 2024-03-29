// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISavings {
    struct System {
        uint256 idCounter; // The total number of CFAs minted
        uint256 totalActiveCfa; // The total number of CFAs active in the contract
        uint256 totalPaidAmount; //total amount rewarded to users
        uint256 totalRewardsToBeGiven; //total amount of rewards to be given, subtracted every time a reward is given
    }

    struct Life {
        uint256 min;
        uint256 max;
    }

    struct Attributes {
        uint256 timeCreated; // The time the CFA was minted
        uint256 cfaLife; // The time the CFA was locked
        uint256 cfaLifeTimestamp;
        uint256 effectiveInterestTime;
        uint256 principal; // The amount of B&B tokens locked
        uint256 interestRate; // The interest rate of the CFA
        uint256 totalPossibleReward;
    }

    struct Loan {
        bool onLoan;
        uint256 loanBalance;
        uint256 timeWhenLoaned;
    }

    struct Metadata {
        string name; // The name of the CFA
        string description; // The description of the CFA
        string image; // The image of the CFA
    }
}
