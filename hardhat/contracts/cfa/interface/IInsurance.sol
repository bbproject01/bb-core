// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IInsurance {
    struct Attributes {
        uint256 timeCreated;
        uint256 timePeriod;
        uint256 principal;
        uint256 effectiveInterestTime;
        uint256 cfaLife;
    }

    struct Loan {
        bool onLoan;
        uint256 loanBalance;
        uint256 loanTimeCreated;
        uint256 timeWhenLoaned;
    }

    struct Metadata {
        string name;
        string description;
        string image;
    }
}
