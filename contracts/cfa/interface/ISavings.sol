// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISavings {
  struct Life {
    uint256 min;
    uint256 max;
  }

  struct Attributes {
    uint256 timeCreated; // The time the CFA was minted
    uint256 cfaLife; // The time the CFA was locked        // *** Chagne to CFALife
    uint256 soulBoundTerm; //
    uint256 amount; // The amount of B&B tokens locked
    uint32 interestRate; // The interest rate of the CFA
  }

  struct Metadata {
    string name; // The name of the CFA
    string description; // The description of the CFA
    string[2] image; // The image of the CFA
  }
}
