import { NativeModules } from "react-native";

const { RNFritz } = NativeModules;

export const { RNFritzVisionImageLabeling } = NativeModules;
export const { RNFritzVisionObjectDetection } = NativeModules;

const { RNFritzVisionImageStyling: RNFritzVisionImageStylingNative } = NativeModules;
const { RNFritzCustomModel: CustomModelNative } = NativeModules;

export async function RNFritzVisionImageStyling(params) {
  const modelParams = {
    customModel: false,
    ...params,
    modelIdentifier: !params.customModel || !params.modelIdentifier ? params.name : params.modelIdentifier,
  }
  console.log(modelParams)
  try {
    const loaded = await RNFritzVisionImageStylingNative.initializeModel(modelParams);
    if (!loaded) {
      throw new Error('MODEL not loaded');
    }
    let { modelIdentifier } = modelParams;
    const style = (params) => {
      console.log(modelIdentifier, params);
      return RNFritzVisionImageStylingNative.style(modelIdentifier, params);
    }
    return { style };
  } catch (e) {
    console.warn(e);
    throw e;
  }
}

export async function RNFritzCustomModel(fileInfo) {
  let modelIdentifier = '';

  try {
    const loaded = await CustomModelNative.initializeModel(fileInfo);
    if (!loaded) {
      throw new Error('MODEL not loaded');
    }
    modelIdentifier = fileInfo.name;

    const predictFromImage = (params) => {
      return CustomModelNative.predictFromImage(modelIdentifier, params);
    }

    // const predictFromArray = (params) => {
    //   return CustomModelNative.predictFromArray(modelIdentifier, params);
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
