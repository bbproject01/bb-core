// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IReferral {
  struct Referrer {
    address referrer;
    uint256 referralCount;
    uint256 buyCount;
    bool wasReferred;

  }
}
