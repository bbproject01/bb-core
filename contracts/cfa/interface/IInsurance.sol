// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IInsurance {
  struct Attributes {
    uint256 timeCreated;
    uint256 timePeriod;
    uint256 principal;
  }

  struct Metadata {
    string name;
    string description;
  }
}
