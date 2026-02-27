# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moonshine SDK Installer (MSDKI) is a cross-platform desktop application for installing and managing development SDKs (Apache Flex, Royale, Haxe, Java, Git, Gradle, Maven, etc.). Built with ActionScript 3 / MXML on Adobe AIR, with the UI layer being migrated from Apache Flex to Haxe/Feathers UI.

## Build Commands

All build commands run from `MoonshineSDKInstaller/build/`:

```bash
ant build            # Compile and create executable app (output: bin/app/)
ant pack-and-sign    # Package and sign for deployment (output: bin/deploy/)
ant clean            # Remove all build artifacts
ant print-info       # Display build configuration and tool paths
```

### First-Time Setup

1. Copy `MoonshineSDKInstaller/build/local.properties.template` to `local.properties`
2. Set `JAVA_HOME` and `FLEX_HOME` if not in environment
3. Prerequisites: Ant, Java 11+, Apache Flex SDK 4.16.1, Haxe 4.3.7, AIR SDK 51.3.1.1

### Build Pipeline (what `ant build` does)

1. `init` — creates dirs, generates self-signed certificate
2. `modify-app-descriptor` — stamps version/id into `MoonshineSDKInstaller-app.xml`
3. `install-haxe-dependencies` — `haxelib install` feathersui, openfl, actuate, lime
4. `compile-gui-core` — builds Haxe UI components to SWC (Flash library)
5. `compile-swf` — compiles ActionScript/MXML to SWF via mxmlc
6. `compile-app` — packages AIR bundle via ADT

## Architecture

### Three-Module Structure

- **MoonshineSDKInstaller/** — Main AIR application. Entry point: `src/MoonshineSDKInstaller.mxml`. Contains UI components (MXML), menus, auto-updater, styles, and shell scripts.
- **InstallerSharedCore/** — Shared ActionScript library with core business logic: SDK detection, installation management, platform-specific utilities.
- **MoonshineSDKInstallerGUICore/** — Haxe/Feathers UI components compiled to SWC and consumed by the main app. This is the in-progress UI migration target.

Two legacy modules (`ApacheFlexSDKInstallerLib/`, `flex-utilities/`) provide Flex SDK installer functionality and are compiled as library dependencies.

### Key Patterns

- **HelperModel** (`InstallerSharedCore/src/actionScripts/locator/HelperModel.as`) — Singleton service locator holding shared state (`packages`, `components`, `moonshineBridge`).
- **Manager classes** (`InstallerSharedCore/src/actionScripts/managers/`) — Core logic:
  - `DetectionManager` — detects installed SDKs with platform-specific logic
  - `InstallerItemsManager` — manages SDK metadata and installation
  - `StartupHelper` — application initialization sequence
  - `CookieManager` — persists SDK paths between runs
  - `MacOSGitDetector`, `NotesDominoDetector` — platform-specific detectors
- **Haxe-ActionScript bridge** — `HelperView.hx` (Feathers UI) is wrapped by `HelperViewWrapper.as` for use in the Flex app.

### Compilation Flow

The Haxe GUI core compiles to a SWC via OpenFL targeting Flash. The main app's mxmlc compilation includes source paths from all modules and links the Haxe SWC as a library. ADT then packages everything into a native AIR bundle.

### Source Paths (from mxmlc)

```
MoonshineSDKInstaller/src/                          # Main app
InstallerSharedCore/src/                             # Shared core
flex-utilities/flex-installer/common/src/            # Flex utilities
flex-utilities/flex-installer/ant_on_air/external/   # ANT on AIR
flex-utilities/flex-installer/ant_on_air/src/
ApacheFlexSDKInstallerLib/src/                       # Flex installer lib
```

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **build-macos.yml** — Builds, code-signs (.app), creates .pkg, signs .pkg, notarizes with Apple
- **build-windows.yml** — Builds, creates NSIS installer (.exe), signs with DigiCert
- **release.yml** — Manual dispatch that calls both build workflows and creates a GitHub Release

Build artifacts: `MoonshineSDKInstaller-{version}.pkg` (macOS) and `.exe` (Windows).

Development vs production builds are controlled by `build.is.development` (affects app ID, name, and title).

## App Descriptor

`MoonshineSDKInstaller-app.xml` contains placeholders replaced at build time:
- `idToBeReplacedByANT` → app ID
- `nameToBeReplacedByANT` → app title + version
- `filenameToBeReplacedByANT` → executable filename
- `0.0.0` → actual version number

## License

Server Side Public License (SSPL) with OpenSSL exception. All source files require the SSPL header comment.
