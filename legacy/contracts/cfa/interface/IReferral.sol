// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IReferral {
  struct Referrer {
    address referrer;
    address[] referrals;
    uint256 referralCount;
    uint256 buyCount;
    bool wasReferred;
  }
}
