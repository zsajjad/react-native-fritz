import { NativeModules } from 'react-native';

const { RNFritz } = NativeModules;

export const { RNFritzVisionImageLabeling } = NativeModules;
export const { RNFritzVisionObjectDetection } = NativeModules;
export const { RNFritzCustomModel } = NativeModules;

export default RNFritz;
