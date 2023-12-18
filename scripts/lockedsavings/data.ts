import { ethers } from 'hardhat';

export const markers = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100];

export const multipliers = [2, 3, 5, 10, 15, 20, 25, 50, 75, 100, 150, 200];

export const months = [
  [46, 47, 48, 49, 50, 52, 53, 55, 56, 58, 60, 62, 64, 66, 68, 71, 74, 77, 80, 83, 87],
  [72, 73, 75, 77, 79, 81, 83, 85, 88, 90, 93, 96, 99, 102, 106, 110, 114, 118, 123, 129, 135],
  [103, 105, 108, 110, 113, 116, 119, 122, 126, 129, 133, 137, 142, 146, 151, 157, 163, 169, 176, 183, 192],
  [144, 147, 151, 154, 158, 162, 166, 170, 175, 180, 185, 190, 197, 203, 210, 217, 225, 234, 243, 253, 264],
  [167, 171, 175, 179, 183, 188, 192, 198, 203, 208, 214, 221, 228, 235, 243, 251, 260, 270, 280, 292, 304],
  [184, 188, 192, 196, 201, 206, 211, 216, 222, 228, 235, 242, 249, 257, 265, 274, 284, 295, 306, 318, 332],
  [196, 200, 204, 209, 214, 220, 225, 231, 237, 243, 250, 258, 265, 274, 283, 292, 302, 314, 326, 339, 353],
  [234, 239, 244, 249, 255, 261, 268, 274, 281, 289, 297, 305, 314, 324, 334, 346, 357, 0, 0, 0, 0],
  [255, 260, 266, 272, 278, 285, 291, 299, 307, 315, 323, 332, 342, 353, 0, 0, 0, 0, 0, 0, 0],
  [270, 275, 281, 287, 294, 301, 308, 316, 324, 333, 342, 351, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [290, 397, 303, 309, 317, 324, 331, 340, 348, 357, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [305, 311, 318, 325, 332, 340, 348, 356, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
];

export const mintData = {
  attributes: [
    '0', // time created
    '2', // multiplier
    '0', // marker
    '0', // cfa life
    '0', // interest rate
    ethers.utils.parseEther('100'), // principal
  ],
  referrer: ethers.constants.AddressZero,
};
