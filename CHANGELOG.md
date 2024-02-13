# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine SDK Installer [4.6.0]

### Summary

Moonshine SDK Installer 4.6.0 includes version updates for Apache Flex SDK (Harman AIR). It contains as well some improvements in Haxe installation.

### Changed

* Update Harman AIR SDK to 50.2.4.3 ([#117](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/117))

### Fixed

* Fixed issue where with installed Flex SDK with Harman Air user wasn't able to build non-Air application ([#116](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/116))
* Fixed "permission denied" error while installing Haxe ([#113](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/113))

## Moonshine SDK Installer [4.5.0]

### Summary

Moonshine SDK Installer 4.5.0 includes version updates for Apache Royale, Apache Flex SDK (Harman AIR), and Haxe.

### Added


### Changed

* Update Royale to v0.9.11 ([#104](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/104))
* Update Harman AIR SDK to 50.2.2.6 ([#107](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/107))
* Update Haxe to 4.2.5 ([#105](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/105))


### Fixed



## Moonshine SDK Installer [4.4.0]

### Summary

The primary purpose of this release was to add support for OpenJDK 17, which is required for the latest language servers in the upcoming Moonshine-IDE 3.3.4 release.

Gradle was also updated to 7.5.1 to work with OpenJDK 17.

### Added


### Changed

* Update OpenJDK version to 17.0.5 ([#98](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/98))
* Update Gradle version to 7.5.1 ([#99](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/99))
* Update Harman AIR Version for `Apache Flex SDK (Harman AIR) installation to 50.2.2.1 ([#103](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/103))
* Changed license to SSPL ([#95](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/95))

### Fixed

* Download the correct version of Java for M1 (arm64) MacOS machines.  No special version is available for Java 8 ([#98](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/98#issuecomment-1342565752))


## Moonshine SDK Installer [4.3.0]

### Summary

Key Features:
- Install SVN on macOS using MacPorts
- Updates for Apache Royale 0.9.9 release

### Added


### Changed

* Install SVN Using MacPorts ([#31](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/31))
* Update Apache Royale 0.9.8 to 0.9.9 ([#91](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/91))
* Update Apache Royale nightly build to 0.9.10 ([#89](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/89))
* Update Harman Air to 33.1.1.795 ([#90](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/90))


### Fixed



## Moonshine SDK Installer [4.2.0]

### Summary

The main updates for version 4.2.0 are Haxe and Neko installation.  This will also setup the haxelib library and expand some libraries used by Moonshine-IDE.

### Added
* Haxe and Neko SDK installation ([#13](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/13))

### Changed
* Update Harman AIR Version for Flex SDK install to 33.1.1.743 ([#86](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/86))
* Notify both Moonshine and Moonshine Development on SDK installation ([#78](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/78))

### Fixed
* Flex SDK install fails ith Expand-Archive error ([#87](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/87))
* Git install failed on macOS ([#85](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/85))


## Moonshine SDK Installer [4.1.1]

### Changed
* Updated icon to match Moonshine-IDE ([#77](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/77))
* Moonshine SDK Installer is now built with Harman Air 33.1.1.633. ([#75](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/75))

### Fixed
* Windows: Fixed problem with validation of download URLs ([#71](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/71))

## Moonshine SDK Installer [4.1.0]

### Changed
* Switched download URL for Apache Royale nightly build to use Apache Foundation servers. ([#46](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/46))
* Updated Harman Air to version 33.1.1.633. ([#74](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/74))

### Fixed
* Windows: Fixed issue where path to SDK folder location wasn't displayed. ([#72](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/72))

## Moonshine SDK Installer [4.0.0]

### Summary

This release updates Apache Royale to newest version 0.9.8 and nightly build 0.9.9.

### Changed
* Update Harman Air to version 33.1.1.575.
* Update Apache Royale to version 0.9.8.
* Update nightly build of Apache Royale to version 0.9.9.

## Moonshine SDK Installer [3.9.0]

### Summary

Fixed errors for Apache Flex SDK (Harman AIR) install.  Improved the logic to make the errors less likely to trigger in the future.

The UI was updated to Haxe.  It should generally look similar, but there we made several other small changes to the UI while we worked on this.

### Fixed
* Fixed download error for Apache Flex SDK with Harman AIR ([#62](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/62))
* Fixed hang when downloading Harman Air ([#60](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/60))
* Display full version of Harman Air ([#63](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/63))
* Fixed message on warning icon for SVN and Git ([#51](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/51))
* Fixed cases where download button didn't work until the window was scrolled ([#57](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/57))
* Fixed issue where Harman Air license agreement link opened wrong page ([#58](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/58))

### Changed
* Updated main UI to Haxe
* Improved mirror selection logic for Apache Flex SDK with Harman AIR ([#62](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/62))
* macOS:  Decouple installation logic of SVN and Git on Mac OSX ([#61](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/61))
* Updated HCL Notes to version 12.0 ([#52](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/52))
* Updated format for installation date. ([#54](https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/54))

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
