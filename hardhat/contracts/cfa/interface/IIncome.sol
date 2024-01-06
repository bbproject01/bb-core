// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IIncome {
    struct Attributes {
        uint256 timeCreated;
        uint256 principal;
        uint256 paymentFrequency; // in months
        uint256 principalLockTime; // in years
        uint256 lastClaimTime;
        uint256 interest;
        uint256 cfaLife;
        uint256 incomePaid; // paid income in total
    }

    struct Loan {
        bool onLoan;
        uint256 loanBalance;
        uint256 loanTimeCreated; //remove this
        uint256 timeWhenLoaned;
    }

    struct System {
        uint256 maxPaymentFrequency; // defined as months
        uint256 maxPrincipalLockTime; // defined as years
    }

    struct Metadata {
        string name;
        string description;
        string image;
    }
}
