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
        uint256 timeWhenLoaned;
        uint256 timeBeforeNextPayment;
    }

    struct System {
        uint256 maxPaymentFrequency; // defined as months
        uint256 maxPrincipalLockTime; // defined as years
        uint256 idCounter; // The total number of CFAs minted
        uint256 totalActiveCfa; // The total number of CFAs active in the contract
        uint256 totalPaidAmount; //total amount rewarded to users
    }

    struct Metadata {
        string name;
        string description;
        string image;
    }
}
