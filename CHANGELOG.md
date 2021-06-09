# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine SDK Installer [3.8.1]

### Fixed
* Fixed issue where downloading Royale Nightly fails with download unavailable error ([#50](https://github.com/prominic/Moonshine-SDK-Installer/issues/50))
* Fixed issue where downloading Royale Nightly fails with already downloaded error in certain circumstances ([#50](https://github.com/prominic/Moonshine-SDK-Installer/issues/50))

## Moonshine SDK Installer [3.8.0]

### Added
* Add [Harman Adobe AIR](https://airsdk.harman.com/) SDK ([#32](https://github.com/prominic/Moonshine-SDK-Installer/issues/32))
* Updated default OpenJDK to v11.0.10 to support the latest language server ([#38](https://github.com/prominic/Moonshine-SDK-Installer/issues/38))
* Added additional OpenJDK 8 SDK for projects that still require JDK 8 (including HCL Domino projects).

### Fixed
* Fixed queue for SDK downloads ([#40](https://github.com/prominic/Moonshine-SDK-Installer/issues/40))
* Fixed display for license agreements when installing all SDKs ([#44](https://github.com/prominic/Moonshine-SDK-Installer/issues/44))

### Changed
* Improved installation process for Apache Royale nightly build to make it less likely that the last valid installation will be lost if there is an error ([#34](https://github.com/prominic/Moonshine-SDK-Installer/issues/34), [#35](https://github.com/prominic/Moonshine-SDK-Installer/issues/35)))
* Show a version number for each listed SDK ([#39](https://github.com/prominic/Moonshine-SDK-Installer/issues/39))
* Windows: Upgraded Git distribution to version 2.30.0.windows.1/2 ([#37](https://github.com/prominic/Moonshine-SDK-Installer/issues/37))
* Show application version and build number on main page ([#45](https://github.com/prominic/Moonshine-SDK-Installer/issues/45)

## Moonshine SDK Installer [3.7.0]

### Added

* Windows: Switch native Adobe Air installer to NSIS.
* Windows: Enable automatic updates.

## Moonshine SDK Installer [3.6.0]

### Added

* Added [NodeJS](https://nodejs.org/en/) installation.
* Apache Royale update to version 0.9.7 and nightly build 0.9.8.

## Moonshine SDK Installer [3.5.1]

### Fixed

* Fixed issue where downloading Royale v0.9.6 failed to apply patch fix for the broken royale-config.xml. (More information on patch fix can be found in this [discussion](http://apache-royale-development.20373.n8.nabble.com/Broken-royale-config-in-JS-only-build-of-released-Apache-Royale-SDK-0-9-6-td12515.html) on the Royale development mailing list.)

## Moonshine SDK Installer [3.5.0]

### Added

* Add ability to download Apache Royale SDK Nightly build.

## Moonshine SDK Installer [3.4.0]

### Changed

* Apache Roayle SDK updated to download v0.9.6
* Apply a patch fix for the broken royale-config.xml. More information can be found in the this [discussion](http://apache-royale-development.20373.n8.nabble.com/Broken-royale-config-in-JS-only-build-of-released-Apache-Royale-SDK-0-9-6-td12515.html) on the Royale development mailing list.

## Moonshine SDK Installer [3.3.0]

### Fixed

* Fixed issue where SDKs were not configuring automatically from Installer with non-Sandbox build

### Changed

* Misc. structural changes and cleanup

## Moonshine SDK Installer [3.2.0]

### Added

* Gradle download
* Grails download

## Moonshine SDK Installer [3.1.0]

### Added

* Information on disk space usage added

### Changed

* SDK detection logic updated
