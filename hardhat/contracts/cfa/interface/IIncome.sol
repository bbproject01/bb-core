// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IIncome {
    struct Attributes {
        uint256 timeCreated; // The time the CFA was minted
        uint256 principal; // The amount of B&B tokens locked
        uint256 paymentFrequency; // in months
        uint256 principalLockTime; // in years
        uint256 lastClaimTime;  // the last time the user claimed the income
        uint256 interest; // The interest rate of the CFA
        uint256 cfaLife; // The time the CFA will lock
        uint256 incomePaid; // paid income in total
        uint256 beginningTimeForInterest; // the time when the interest starts to count
        uint256 claimedIndex; // the index of the last claimed income
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
