import { NativeModules } from "react-native";

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

    const predictFromImage = (params) => {
      return CustomModelNative.predictFromImage(modelId, params);
    }

    // const predictFromArray = (params) => {
    //   return CustomModelNative.predictFromArray(modelId, params);
    // }

    return {
      predictFromImage,
      // predictFromArray
    };
  } catch (e) {
    console.warn(e);
    throw e;
  }
}

export default RNFritz;
