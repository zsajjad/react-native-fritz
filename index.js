import { NativeModules } from 'react-native';

const { RNFritz } = NativeModules;

export const { RNFritzVisionImageLabeling } = NativeModules;
export const { RNFritzVisionObjectDetection } = NativeModules;

const { RNFritzCustomModel: CustomModelNative } = NativeModules;

export async function RNFritzCustomModel(fileInfo) {
  let modelId = '';

  try {
    const loaded = await CustomModelNative.initializeModel(fileInfo);
    if (!loaded) {
      throw new Error('MODEL not loaded');
    }
    modelId = fileInfo.name;

    const detectFromImage = (params) => {
      return CustomModelNative.detectFromImage(modelId, params);
    }

    const detectFromArray = (params) => {
      return CustomModelNative.detectFromArray(modelId, params);
    }

    return {
      detectFromImage,
      detectFromArray
    };
  } catch (e) {
    console.warn(e);
    throw e;
  }
}


export default RNFritz;
