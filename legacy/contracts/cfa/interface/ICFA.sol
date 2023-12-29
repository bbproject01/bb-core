// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ICFA {
  struct Life {
    uint256 min;
    uint256 max;
  }

  struct Attributes {
    // Product product; // The type of CFA Product
    uint256 timeCreated; // The time the CFA was minted
    uint256 cfaLife; // The time the CFA was locked        // *** Chagne to CFALife
    uint256 soulBoundTerm; //
    uint256 amount; // The amount of B&B tokens locked
    uint32 interestRate; // The interest rate of the CFA

    // uint256 originalTerm; // The original term in months for the CFA
    // uint256 timePassed; // The time that has passed since the minting of the CFA, in months
    // uint256 maximum Reduction; // The maximum reduction allowed in the original term, represented as a fraction (eg 0.25 for 25%)
  }

  struct Metadata {
    string name; // The name of the CFA
    string description; // The description of the CFA
    string[2] image; // The image of the CFA
  }
}
