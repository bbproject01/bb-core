// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFNFT {
  enum Product {
    FNFT
  }

  struct FNFTMetadata {
    Product product; // The type of FNFT Product
    uint256 timeCreated; // The time the FNFT was minted
    uint256 timeLocked; // The time the FNFT was locked        // *** Chagne to FNFTLife
    bool soulBounded; // Whether the FNFT is soul bounded
    uint256 amount; // The amount of B&B tokens locked
    uint256 interestRate; // The interest rate of the FNFT

    // uint256 originalTerm; // The original term in months for the FNFT
    // uint256 timePassed; // The time that has passed since the minting of the FNFT, in months
    // uint256 maximumReduction; // The maximum reduction allowed in the original term, represented as a fraction (eg 0.25 for 25%)
  }
}
