import { NativeModules } from 'react-native';

const { RNFritz } = NativeModules;

export const { RNFritzVisionImageLabeling } = NativeModules;
export const { RNFritzVisionObjectDetection } = NativeModules;
export default RNFritz;
