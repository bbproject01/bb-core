// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IIncome {
  struct Attributes {
    uint256 timeCreated;
    uint256 principal;
    uint256 paymentFrequency; // in months
    uint256 principalLockTime; // in years
    uint256 lastClaimTime;
    uint256 interest; 
  }

  struct System {
    uint256 maxPaymentFrequency; // defined as months
    uint256 maxPrincipalLockTime; // defined as years
  }
}
