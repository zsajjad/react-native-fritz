
# react-native-fritz

## Getting started

`$ npm install react-native-fritz --save`

### Mostly automatic installation

`$ react-native link react-native-fritz`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-fritz` and add `RNFritz.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNFritz.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.rnfritz.RNFritzPackage;` to the imports at the top of the file
  - Add `new RNFritzPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-fritz'
  	project(':react-native-fritz').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-fritz/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-fritz')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNFritz.sln` in `node_modules/react-native-fritz/windows/RNFritz.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Fritz.RNFritz;` to the usings at the top of the file
  - Add `new RNFritzPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNFritz from 'react-native-fritz';

// TODO: What to do with the module?
RNFritz;
```
  