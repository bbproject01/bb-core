// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFNFT {
  enum Product {
    FNFT
  }

  struct Attributes {
    Product product; // The type of FNFT Product
    uint256 timeCreated; // The time the FNFT was minted
    uint256 fnftLife; // The time the FNFT was locked        // *** Chagne to FNFTLife
    uint256 soulBoundTerm; //
    uint256 amount; // The amount of B&B tokens locked
    uint256 interestRate; // The interest rate of the FNFT

    // uint256 originalTerm; // The original term in months for the FNFT
    // uint256 timePassed; // The time that has passed since the minting of the FNFT, in months
    // uint256 maximumReduction; // The maximum reduction allowed in the original term, represented as a fraction (eg 0.25 for 25%)
  }

  struct Metadata {
    string name; // The name of the FNFT
    string description; // The description of the FNFT
    string[] image; // The image of the FNFT
  }
}
