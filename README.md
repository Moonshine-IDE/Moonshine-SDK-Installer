# Moonshine-SDK-Installer
Moonshine SDK Installer -- This was formerly known as Moonshine App Store Helper internally.

### To Build Moonshine-SDK-Installer

#### Prerequisite
- Ant
- Apache Flex SDK
- OpenJDK 11 or greater
- [Download Haxe](https://haxe.org/download/)
- [Install FeathersUI](https://feathersui.com/learn/haxe-openfl/installation/)

#### Steps to build executable application

1. Checkout the Moonshine-SDK-Installer repository
2. Open `MoonshineSDKInstaller/build/local.properties.template` from your downloaded location and copy it as `local.properties`.
3. If you need to provide custom JAVA_HOME or FLEX_HOME paths, uncomment the settings in local.properties and put the paths in.
4. Do the same if you need a custom haxelib path.
5. Open a Terminal or Command Prompt window and navigate to `MoonshineSDKInstaller/build`.
6. Run `ant build` to build executable application. At the end of the build process generated artifacts can be found under `MoonshineSDKInstaller/build/app` directory.

#### Steps to build signed installers
After building executable application run `ant pack-and-sign`. Generated artifacts can be found under `MoonshineSDKInstaller/build/deploy` directory. This step requires additional tools, env settings and certificates. You'll find more details in `local.properties` file.
