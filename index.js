import { NativeModules } from 'react-native';

const { RNFritz } = NativeModules;

export const { RNFritzVisionLabel } = NativeModules;
export const { RNFritzVisionObject } = NativeModules;
export const { RNFritzTextRecognition } = NativeModules;
export default RNFritz;
