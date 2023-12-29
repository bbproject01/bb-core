import { ethers } from "ethers";

export const supplyMarkers = [
  '34000000',
  '44000000',
  '54000000',
  '64000000',
  '74000000',
  '85000000',
  '100000000',
  '120000000',
  '1860000000',
  '4700000000',
  '9000000000',
];
export const interests = [
  ['500', '700', '1000', '1500', '2000', '2000'],
  ['200', '500', '500', '1000', '1500', '2000'],
  ['200', '200', '500', '1000', '1500', '2000'],
  ['200', '200', '200', '1000', '1500', '2000'],
  ['200', '200', '200', '700', '1000', '1500'],
  ['200', '200', '200', '500', '1000', '1500'],
  ['200', '200', '200', '200', '700', '1200'],
  ['200', '200', '200', '200', '500', '1000'],
  ['200', '200', '200', '200', '300', '700'],
  ['200', '200', '200', '200', '200', '500'],
  ['200', '200', '200', '200', '100', '300'],
];
export const numberOfReferrals = ['20', '100', '1000', '10000', '100000', '1000000'];
export const discountForReferred = ['500', '400', '400', '300', '300', '200', '200', '100', '100', '50', '50'];

export const trueMarkers = () => {
  let markers = [];
  for (let i = 0; i < supplyMarkers.length; i++) {
    markers.push(String(ethers.utils.parseEther((supplyMarkers[i]))));
  }

  return markers;
  
};