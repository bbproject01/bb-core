// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IInsurance {
    struct Attributes {
        uint256 timeCreated;
        uint256 timePeriod;
        uint256 principal;
        uint256 effectiveInterestTime;
        uint256 cfaLife;
        uint256 interest;
        uint256 totalPossibleReward; // the total reward the user has earned
    }

    struct Loan {
        bool onLoan;
        uint256 loanBalance;
        uint256 timeWhenLoaned;
    }

    struct Metadata {
        string name;
        string description;
        string image;
    }

    struct System {
        uint256 idCounter; // The total number of CFAs minted
        uint256 totalActiveCfa; // The total number of CFAs active in the contract
        uint256 totalPaidAmount; //total amount rewarded to users
        uint256 totalRewardsToBeGiven; //total amount of rewards to be given, subtracted every time a reward is given
    }
}
