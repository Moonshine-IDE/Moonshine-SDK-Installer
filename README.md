# Moonshine-SDK-Installer
Moonshine SDK Installer -- This was formerly known as Moonshine App Store Helper internally.

### To Build Moonshine-SDK-Installer

#### Prerequisite
- Ant
- Apache Flex SDK
- Haxe

#### Steps

1. Checkout the Moonshine-SDK-Installer repository
2. Open `MoonshineSDKInstaller/build/ApplicationProperties.xml` from your downloaded location
3. Provide Apache Flex SDK path to `<winSDKPath>` or `<winSDKPath64>` if your platform is Windows, and to `<unixSDKPath>` if it's macOS
4. Make sure `<isSignedBuild>` value is `false` if you want a non-signed build. Keep all the followed-by tags' value blank in case of a non-signed build
5. Open a Terminal or Command Prompt window
6. Navigate into `MoonshineSDKInstaller/build` from Terminal or Command Prompt
7. Run `ant` on Terminal or Command Prompt - a build process should start now

At the end of the build process generated artifacts can be found under `MoonshineSDKInstaller/build/DEPLOY` directory.

(Note: On macOS a `.pkg` installer can available only if it's a signed build)
