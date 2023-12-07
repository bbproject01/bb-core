import { ethers } from 'hardhat';

export const interests = [
  15310000000000000, 15240000000000000, 15170000000000000, 15100000000000000, 15030000000000000, 14960000000000000,
  14890000000000000, 14810000000000000, 14740000000000000, 14670000000000000, 14600000000000000, 14530000000000000,
  14460000000000000, 14390000000000000, 14320000000000000, 14250000000000000, 14170000000000000, 14100000000000000,
  14030000000000000, 13960000000000000, 13890000000000000, 13820000000000000, 13750000000000000, 13670000000000000,
  13600000000000000, 13530000000000000, 13460000000000000, 13390000000000000, 13310000000000000, 13240000000000000,
  13170000000000000, 13100000000000000, 13030000000000000, 12950000000000000, 12880000000000000, 12810000000000000,
  12740000000000000, 12660000000000000, 12590000000000000, 12520000000000000, 12450000000000000, 12370000000000000,
  12300000000000000, 12230000000000000, 12150000000000000, 12080000000000000, 12010000000000000, 11930000000000000,
  11860000000000000, 11790000000000000, 11710000000000000, 11640000000000000, 11570000000000000, 11490000000000000,
  11420000000000000, 11350000000000000, 11270000000000000, 11200000000000000, 11130000000000000, 11050000000000000,
  10980000000000000, 10900000000000000, 10830000000000000, 10760000000000000, 10680000000000000, 10610000000000000,
  10530000000000000, 10460000000000000, 10390000000000000, 10310000000000000, 10240000000000000, 10160000000000000,
  10090000000000000, 10010000000000000, 9940000000000000, 9860000000000000, 9790000000000000, 9710000000000000,
  9640000000000000, 9560000000000000, 9490000000000000, 9410000000000000, 9340000000000000, 9260000000000000,
  9190000000000000, 9110000000000000, 9040000000000000, 8960000000000000, 8890000000000000, 8810000000000000,
  8730000000000000, 8660000000000000, 8580000000000000, 8510000000000000, 8430000000000000, 8360000000000000,
  8280000000000000, 8200000000000000, 8130000000000000, 8050000000000000, 7970000000000000, 7900000000000000,
  7820000000000000, 7740000000000000, 7670000000000000, 7590000000000000, 7510000000000000, 7440000000000000,
  7360000000000000, 7280000000000000, 7210000000000000, 7130000000000000, 7050000000000000, 6980000000000000,
  6900000000000000, 6820000000000000, 6740000000000000, 6670000000000000, 6590000000000000, 6510000000000000,
  6430000000000000, 6360000000000000, 6280000000000000, 6200000000000000, 6120000000000000, 6040000000000000,
  5970000000000000, 5890000000000000, 5810000000000000, 5730000000000000, 5650000000000000, 5580000000000000,
  5500000000000000, 5420000000000000, 5340000000000000, 5260000000000000, 5180000000000000, 5100000000000000,
  5030000000000000, 4950000000000000, 4870000000000000, 4790000000000000, 4710000000000000, 4630000000000000,
  4550000000000000, 4470000000000000, 4390000000000000, 4310000000000000, 4230000000000000, 4150000000000000,
  4070000000000000, 3990000000000000, 3910000000000000, 3830000000000000, 3750000000000000, 3670000000000000,
  3590000000000000, 3510000000000000, 3430000000000000, 3350000000000000, 3270000000000000, 3190000000000000,
  3110000000000000, 3030000000000000, 2950000000000000, 2870000000000000, 2790000000000000, 2710000000000000,
  2630000000000000, 2550000000000000, 2470000000000000, 2390000000000000, 2300000000000000, 2220000000000000,
  2140000000000000, 2060000000000000, 1980000000000000, 1900000000000000, 1820000000000000, 1730000000000000,
  1650000000000000, 1570000000000000, 1490000000000000, 1410000000000000, 1320000000000000, 1240000000000000,
  1160000000000000, 1080000000000000, 990000000000000, 910000000000000, 830000000000000, 750000000000000,
  660000000000000, 580000000000000, 500000000000000, 420000000000000, 330000000000000, 250000000000000, 170000000000000,
  150000000000000, 130000000000000, 120000000000000, 100000000000000, 80000000000000, 70000000000000, 70000000000000,
  60000000000000, 50000000000000, 40000000000000, 30000000000000, 20000000000000, 20000000000000, 10000000000000, 0, 0,
  0, 0, 0, 0,
];

export const rawMarkers = [
  1_000_000, 20_000_000, 21_000_000, 22_000_000, 23_000_000, 24_000_000, 26_000_000, 28_000_000, 30_000_000, 32_000_000,
  34_000_000, 36_000_000, 38_000_000, 40_000_000, 42_000_000, 44_000_000, 46_000_000, 48_000_000, 50_000_000,
  52_000_000, 54_000_000, 56_000_000, 58_000_000, 60_000_000, 62_000_000, 64_000_000, 66_000_000, 68_000_000,
  70_000_000, 72_000_000, 74_000_000, 76_000_000, 78_000_000, 80_000_000, 82_000_000, 85_000_000, 88_000_000,
  91_000_000, 94_000_000, 97_000_000, 100_000_000, 104_000_000, 108_000_000, 112_000_000, 116_000_000, 120_000_000,
  125_000_000, 130_000_000, 135_000_000, 140_000_000, 150_000_000, 160_000_000, 170_000_000, 180_000_000, 190_000_000,
  200_000_000, 210_000_000, 220_000_000, 230_000_000, 240_000_000, 250_000_000, 260_000_000, 270_000_000, 280_000_000,
  300_000_000, 320_000_000, 340_000_000, 360_000_000, 380_000_000, 400_000_000, 420_000_000, 450_000_000, 480_000_000,
  510_000_000, 540_000_000, 570_000_000, 600_000_000, 630_000_000, 660_000_000, 690_000_000, 720_000_000, 760_000_000,
  800_000_000, 840_000_000, 900_000_000, 960_000_000, 1_020_000_000, 1_080_000_000, 1_140_000_000, 1_200_000_000,
  1_260_000_000, 1_320_000_000, 1_380_000_000, 1_440_000_000, 1_500_000_000, 1_560_000_000, 1_620_000_000,
  1_680_000_000, 1_740_000_000, 1_800_000_000, 1_860_000_000, 1_920_000_000, 1_980_000_000, 2_040_000_000,
  2_100_000_000, 2_180_000_000, 2_260_000_000, 2_340_000_000, 2_420_000_000, 2_500_000_000, 2_600_000_000,
  2_700_000_000, 2_800_000_000, 2_900_000_000, 3_000_000_000, 3_100_000_000, 3_200_000_000, 3_300_000_000,
  3_400_000_000, 3_500_000_000, 3_600_000_000, 3_700_000_000, 3_800_000_000, 3_900_000_000, 4_000_000_000,
  4_100_000_000, 4_200_000_000, 4_300_000_000, 4_400_000_000, 4_500_000_000, 4_700_000_000, 4_900_000_000,
  5_100_000_000, 5_300_000_000, 5_500_000_000, 5_700_000_000, 5_900_000_000, 6_100_000_000, 6_300_000_000,
  6_500_000_000, 6_700_000_000, 6_900_000_000, 7_100_000_000, 7_300_000_000, 7_500_000_000, 7_750_000_000,
  8_000_000_000, 8_250_000_000, 8_500_000_000, 8_750_000_000, 9_000_000_000, 9_250_000_000, 9_500_000_000,
  9_750_000_000, 10_000_000_000, 10_250_000_000, 10_500_000_000, 10_750_000_000, 11_000_000_000, 11_250_000_000,
  11_500_000_000, 11_750_000_000, 12_000_000_000, 12_250_000_000, 12_500_000_000, 12_750_000_000, 13_000_000_000,
  13_250_000_000, 13_500_000_000, 13_750_000_000, 14_000_000_000, 14_250_000_000, 14_500_000_000, 14_750_000_000,
  15_000_000_000, 15_250_000_000, 15_500_000_000, 15_750_000_000, 16_000_000_000, 16_250_000_000, 16_500_000_000,
  16_750_000_000, 17_000_000_000, 17_250_000_000, 17_500_000_000, 17_750_000_000, 18_000_000_000, 18_250_000_000,
  18_500_000_000, 18_750_000_000, 19_000_000_000, 19_200_000_000, 19_400_000_000, 19_600_000_000, 19_800_000_000,
  20_000_000_000, 20_100_000_000, 20_200_000_000, 20_250_000_000, 20_300_000_000, 20_350_000_000, 20_400_000_000,
  20_450_000_000, 20_500_000_000, 20_550_000_000, 20_600_000_000, 20_650_000_000, 20_700_000_000, 20_750_000_000,
  20_800_000_000, 20_820_000_000, 20_840_000_000, 20_860_000_000, 20_880_000_000, 20_900_000_000, 20_990_000_000,
  20_999_000_000, 20_999_900_000, 20_999_990_000,
];

export const trueMarkers = () => {
  let markers = [];
  for (let i = 0; i < rawMarkers.length; i++) {
    markers.push(String(ethers.utils.parseEther(String(rawMarkers[i]))));
  }

  return markers;
};
