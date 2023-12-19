import { ethers } from 'hardhat';

// export const interests = [
//   '15310000000000000',
//   '15240000000000000',
//   '15170000000000000',
//   '15100000000000000',
//   '15030000000000000',
//   '14960000000000000',
//   '14890000000000000',
//   '14810000000000000',
//   '14740000000000000',
//   '14670000000000000',
//   '14600000000000000',
//   '14530000000000000',
//   '14460000000000000',
//   '14390000000000000',
//   '14320000000000000',
//   '14250000000000000',
//   '14170000000000000',
//   '14100000000000000',
//   '14030000000000000',
//   '13960000000000000',
//   '13890000000000000',
//   '13820000000000000',
//   '13750000000000000',
//   '13670000000000000',
//   '13600000000000000',
//   '13530000000000000',
//   '13460000000000000',
//   '13390000000000000',
//   '13310000000000000',
//   '13240000000000000',
//   '13170000000000000',
//   '13100000000000000',
//   '13030000000000000',
//   '12950000000000000',
//   '12880000000000000',
//   '12810000000000000',
//   '12740000000000000',
//   '12660000000000000',
//   '12590000000000000',
//   '12520000000000000',
//   '12450000000000000',
//   '12370000000000000',
//   '12300000000000000',
//   '12230000000000000',
//   '12150000000000000',
//   '12080000000000000',
//   '12010000000000000',
//   '11930000000000000',
//   '11860000000000000',
//   '11790000000000000',
//   '11710000000000000',
//   '11640000000000000',
//   '11570000000000000',
//   '11490000000000000',
//   '11420000000000000',
//   '11350000000000000',
//   '11270000000000000',
//   '11200000000000000',
//   '11130000000000000',
//   '11050000000000000',
//   '10980000000000000',
//   '10900000000000000',
//   '10830000000000000',
//   '10760000000000000',
//   '10680000000000000',
//   '10610000000000000',
//   '10530000000000000',
//   '10460000000000000',
//   '10390000000000000',
//   '10310000000000000',
//   '10240000000000000',
//   '10160000000000000',
//   '10090000000000000',
//   '10010000000000000',
//   '9940000000000000',
//   '9860000000000000',
//   '9790000000000000',
//   '9710000000000000',
//   '9640000000000000',
//   '9560000000000000',
//   '9490000000000000',
//   '9410000000000000',
//   '9340000000000000',
//   '9260000000000000',
//   '9190000000000000',
//   '9110000000000000',
//   '9040000000000000',
//   '8960000000000000',
//   '8890000000000000',
//   '8810000000000000',
//   '8730000000000000',
//   '8660000000000000',
//   '8580000000000000',
//   '8510000000000000',
//   '8430000000000000',
//   '8360000000000000',
//   '8280000000000000',
//   '8200000000000000',
//   '8130000000000000',
//   '8050000000000000',
//   '7970000000000000',
//   '7900000000000000',
//   '7820000000000000',
//   '7740000000000000',
//   '7670000000000000',
//   '7590000000000000',
//   '7510000000000000',
//   '7440000000000000',
//   '7360000000000000',
//   '7280000000000000',
//   '7210000000000000',
//   '7130000000000000',
//   '7050000000000000',
//   '6980000000000000',
//   '6900000000000000',
//   '6820000000000000',
//   '6740000000000000',
//   '6670000000000000',
//   '6590000000000000',
//   '6510000000000000',
//   '6430000000000000',
//   '6360000000000000',
//   '6280000000000000',
//   '6200000000000000',
//   '6120000000000000',
//   '6040000000000000',
//   '5970000000000000',
//   '5890000000000000',
//   '5810000000000000',
//   '5730000000000000',
//   '5650000000000000',
//   '5580000000000000',
//   '5500000000000000',
//   '5420000000000000',
//   '5340000000000000',
//   '5260000000000000',
//   '5180000000000000',
//   '5100000000000000',
//   '5030000000000000',
//   '4950000000000000',
//   '4870000000000000',
//   '4790000000000000',
//   '4710000000000000',
//   '4630000000000000',
//   '4550000000000000',
//   '4470000000000000',
//   '4390000000000000',
//   '4310000000000000',
//   '4230000000000000',
//   '4150000000000000',
//   '4070000000000000',
//   '3990000000000000',
//   '3910000000000000',
//   '3830000000000000',
//   '3750000000000000',
//   '3670000000000000',
//   '3590000000000000',
//   '3510000000000000',
//   '3430000000000000',
//   '3350000000000000',
//   '3270000000000000',
//   '3190000000000000',
//   '3110000000000000',
//   '3030000000000000',
//   '2950000000000000',
//   '2870000000000000',
//   '2790000000000000',
//   '2710000000000000',
//   '2630000000000000',
//   '2550000000000000',
//   '2470000000000000',
//   '2390000000000000',
//   '2300000000000000',
//   '2220000000000000',
//   '2140000000000000',
//   '2060000000000000',
//   '1980000000000000',
//   '1900000000000000',
//   '1820000000000000',
//   '1730000000000000',
//   '1650000000000000',
//   '1570000000000000',
//   '1490000000000000',
//   '1410000000000000',
//   '1320000000000000',
//   '1240000000000000',
//   '1160000000000000',
//   '1080000000000000',
//   '990000000000000',
//   '910000000000000',
//   '830000000000000',
//   '750000000000000',
//   '660000000000000',
//   '580000000000000',
//   '500000000000000',
//   '420000000000000',
//   '330000000000000',
//   '250000000000000',
//   '170000000000000',
//   '150000000000000',
//   '130000000000000',
//   '120000000000000',
//   '100000000000000',
//   '80000000000000',
//   '70000000000000',
//   '70000000000000',
//   '60000000000000',
//   '50000000000000',
//   '40000000000000',
//   '30000000000000',
//   '20000000000000',
//   '20000000000000',
//   '10000000000000',
//   '0',
//   '0',
//   '0',
//   '0',
//   '0',
//   '0',
// ];

export const interests = [
  '15309470499731200',
  '15238935953279900',
  '15168347460706100',
  '15097704935669100',
  '15027008291617700',
  '14956257441789600',
  '14885452299209900',
  '14814592776692500',
  '14743678786836700',
  '14672710242028800',
  '14601687054440100',
  '14530609136026700',
  '14459476398528200',
  '14388288753468100',
  '14317046112151800',
  '14245748385667100',
  '14174395484882100',
  '14102987320446100',
  '14031523802787500',
  '13960004842113600',
  '13888430348409900',
  '13816800231439800',
  '13745114400742300',
  '13673372765633700',
  '13601575235204100',
  '13529721718319200',
  '13457812123618000',
  '13385846359511800',
  '13313824334185300',
  '13241745955593400',
  '13169611131462300',
  '13097419769288400',
  '13025171776336300',
  '12952867059639700',
  '12880505525999500',
  '12808087081983600',
  '12735611633925700',
  '12663079087924500',
  '12590489349843600',
  '12517842325310100',
  '12445137919713500',
  '12372376038206000',
  '12299556585700500',
  '12226679466870400',
  '12153744586148800',
  '12080751847727500',
  '12007701155556600',
  '11934592413342700',
  '11861425524549300',
  '11788200392395000',
  '11714916919853400',
  '11641575009651500',
  '11568174564269500',
  '11494715485939900',
  '11421197676646500',
  '11347621038123100',
  '11273985471853500',
  '11200290879070000',
  '11126537160753200',
  '11052724217629700',
  '10978851950173500',
  '10904920258603100',
  '10830929042881400',
  '10756878202715000',
  '10682767637553200',
  '10608597246586800',
  '10534366928747700',
  '10460076582707200',
  '10385726106876500',
  '10311315399404100',
  '10236844358176400',
  '10162312880815700',
  '10087720864679700',
  '10013068206861100',
  '9938354804185370',
  '9863580553211460',
  '9788745350229440',
  '9713849091260500',
  '9638891672055120',
  '9563872988093360',
  '9488792934583050',
  '9413651406458450',
  '9338448298380490',
  '9263183504735210',
  '9187856919632200',
  '9112468436904610',
  '9037017950107580',
  '8961505352517610',
  '8885930537131600',
  '8810293396664950',
  '8734593823551910',
  '8658831709943860',
  '8583006947708420',
  '8507119428428080',
  '8431169043400240',
  '8355155683635210',
  '8279079239855050',
  '8202939602493630',
  '8126736661694610',
  '8050470307310990',
  '7974140428903760',
  '7897746915740850',
  '7821289656796630',
  '7744768540749680',
  '7668183455983080',
  '7591534290582570',
  '7514820932335690',
  '7438043268730650',
  '7361201186955270',
  '7284294573896010',
  '7207323316136720',
  '7130287299957680',
  '7053186411334570',
  '6976020535936820',
  '6898789559127930',
  '6821493365962270',
  '6744131841185610',
  '6666704869233710',
  '6589212334230600',
  '6511654119987890',
  '6434030110003430',
  '6356340187460900',
  '6278584235227310',
  '6200762135853080',
  '6122873771570170',
  '6044919024291720',
  '5966897775609550',
  '5888809906794410',
  '5810655298793760',
  '5732433832231320',
  '5654145387405270',
  '5575789844287640',
  '5497367082522910',
  '5418876981426290',
  '5340319419983030',
  '5261694276847750',
  '5183001430342000',
  '5104240758453840',
  '5025412138836230',
  '4946515448805980',
  '4867550565343050',
  '4788517365088120',
  '4709415724342140',
  '4630245519064770',
  '4551006624873950',
  '4471698917043020',
  '4392322270500900',
  '4312876559829700',
  '4233361659264910',
  '4153777442692520',
  '4074123783648350',
  '3994400555316970',
  '3914607630530310',
  '3834744881765940',
  '3754812181146150',
  '3674809400436850',
  '3594736411045130',
  '3514593084019250',
  '3434379290046860',
  '3354094899452820',
  '3273739782198910',
  '3193313807882130',
  '3112816845733060',
  '3032248764614830',
  '2951609433021530',
  '2870898719076640',
  '2790116490532180',
  '2709262614766670',
  '2628336958784500',
  '2547339389213250',
  '2466269772303690',
  '2385127973927090',
  '2303913859575290',
  '2222627294357070',
  '2141268142999310',
  '2059836269842740',
  '1978331538843300',
  '1896753813568350',
  '1815102957196450',
  '1733378832515120',
  '1651581301920220',
  '1569710227413700',
  '1487765470602480',
  '1405746892696680',
  '1323654354508320',
  '1241487716449270',
  '1159246838530860',
  '1076931580360710',
  '994541801142779',
  '912077359674468',
  '829538114346162',
  '746923923138798',
  '664234643622530',
  '581470132955175',
  '498630247881326',
  '415714844729020',
  '332723779409738',
  '249656907416185',
  '166514083820735',
  '149876392125936',
  '133235655389807',
  '116591872446392',
  '99945042129734',
  '83295163273212',
  '74969080277487',
  '66642234708869',
  '58314626421252',
  '49986255268530',
  '41657121104599',
  '33327223783575',
  '24996563158686',
  '16665139084049',
  '8332951413337',
  '833329513839',
  '83333295153',
  '8333332913',
  '833333402',
  '83333340',
  '8333334',
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