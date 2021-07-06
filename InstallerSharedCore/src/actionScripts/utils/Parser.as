package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ComponentVariantVO;
	import actionScripts.valueObjects.EnvironmentVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.HelperSDKVO;
	import actionScripts.valueObjects.PackageVO;
	
	import feathers.data.ArrayCollection;
	
	public class Parser
	{
		public static function parseEnvironmentFrom(values:String, to:EnvironmentVO):void
		{
			var lines:Array = values.split("\r\n");
			var tmpPath:File;
			var splitLine:Array;
			for each (var line:String in lines)
			{
				splitLine = line.split("=");
				if (splitLine[0] == "JAVA_HOME")
				{
					tmpPath = new File(splitLine[1]);
					// validate the path against JDK
					if (tmpPath.exists && tmpPath.resolvePath("bin/javac.exe").exists)
					{
						to.JAVA_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "ANT_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.ANT_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "FLEX_HOME")
				{
					tmpPath = new File(splitLine[1]);
					// validate if Flex SDK path
					if (tmpPath.exists)
					{
						var tmpSDK:HelperSDKVO = HelperUtils.isSDKFolder(tmpPath);
						if (tmpSDK && (tmpSDK.type == ComponentTypes.TYPE_FLEX || 
										tmpSDK.type == ComponentTypes.TYPE_FEATHERS || 
										tmpSDK.type == ComponentTypes.TYPE_ROYALE || 
										tmpSDK.type == ComponentTypes.TYPE_FLEXJS))
						{
							to.FLEX_HOME = tmpSDK;
						}
					}
				}
				else if (splitLine[0] == "MAVEN_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.MAVEN_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "GRADLE_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.GRADLE_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "GRAILS_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.GRAILS_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "GIT_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.GIT_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "SVN_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.SVN_HOME = tmpPath;
					}
				}
				else if (splitLine[0] == "PLAYERGLOBAL_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.PLAYERGLOBAL_HOME = tmpPath;
					}
				}
				/*else if (splitLine[0] == "NODEJS_HOME")
				{
					tmpPath = new File(splitLine[1]);
					if (tmpPath.exists)
					{
						to.NODEJS_HOME = tmpPath;
					}
				}*/
			}
		}
		
		public static function parseHelperConfig(xmlData:XML):void
		{
			var model:HelperModel = HelperModel.getInstance();
			var descriptionCalculator:Dictionary = new Dictionary();
			var staticRequiredText:String = "Required for: ";
			
			// store AIR version
			HelperConstants.CONFIG_ADOBE_AIR_VERSION = xmlData.airAdobe.@version.toString();
			HelperConstants.CONFIG_HARMAN_AIR_VERSION = xmlData.airHarman.@version.toString();
			HelperConstants.CONFIG_HARMAN_AIR_SERVER = String(xmlData.airHarman.download[HelperConstants.IS_MACOS ? "mac" : "windows"].version.path);
			HelperConstants.CONFIG_HARMAN_AIR_FILE = String(xmlData.airHarman.download[HelperConstants.IS_MACOS ? "mac" : "windows"].version.file);
			
			// store 64-bit windows url
			if (!HelperConstants.IS_MACOS)
			{
				HelperConstants.WINDOWS_64BIT_DOWNLOAD_DIRECTORY = (File.getRootDirectories()[0] as File).nativePath +"Program Files"+ File.separator +"MoonshineSDKInstaller";
				HelperConstants.INSTALLER_UPDATE_CHECK_URL = String(xmlData.installerUpdateCheckUrl);
			}
			
			// parse packages
			model.components = new ArrayCollection();
			var tmpComponent:ComponentVO;
			for each (var comp:XML in xmlData.components.item)
			{
				tmpComponent = new ComponentVO();
				tmpComponent.id = String(comp.@id);
				tmpComponent.title = String(comp.title);
				tmpComponent.description = staticRequiredText;
				tmpComponent.imagePath = String(comp.image);
				tmpComponent.type = String(comp.sdkType);
				tmpComponent.isSelectionChangeAllowed = true;
				tmpComponent.website = String(comp.website);
				
				// some items may requires to install manually
				if (comp.hasOwnProperty("@isDownloadable"))
				{
					tmpComponent.isDownloadable = (String(comp.@isDownloadable) == "false") ? false : true;
					tmpComponent.hasWarning = !tmpComponent.isDownloadable ? "This item may require to install manually." : null;
				}
				
				// variants
				var variantCount:int = XMLList(comp.download.variant).length();
				if (variantCount == 1)
				{
					tmpComponent.version = String(comp.download.variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.@version);
					tmpComponent.displayVersion = String(comp.download.variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.@displayVersion);
					tmpComponent.downloadURL = comp.download.variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.path.toString() 
						+ comp.download.variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.file.toString();
					tmpComponent.installToPath = getInstallDirectoryPath(tmpComponent.type, tmpComponent.version);
					tmpComponent.sizeInMb = int(comp.download.variant.diskMBusage[HelperConstants.IS_MACOS ? "mac" : "windows"]);
				}
				else
				{
					tmpComponent.downloadVariants = new ArrayCollection()
					
					var tmpVariant:ComponentVariantVO;
					var preSelectedVariant:ComponentVariantVO;
					for each (var variant:XML in comp.download.variant)
					{
						tmpVariant = new ComponentVariantVO();
						tmpVariant.version = String(variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.@version);
						tmpVariant.displayVersion = String(variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.@displayVersion);
						tmpVariant.title = String(variant.title) +" - "+ tmpVariant.version;
						tmpVariant.downloadURL = variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.path.toString() + variant[HelperConstants.IS_MACOS ? "mac" : "windows"].version.file.toString();
						tmpVariant.sizeInMb = int(variant.diskMBusage[HelperConstants.IS_MACOS ? "mac" : "windows"]);
						
						tmpComponent.downloadVariants.add(tmpVariant);
						if (variant.hasOwnProperty("@isSelected"))
						{
							preSelectedVariant = tmpVariant;
						}
						if (variant.hasOwnProperty("@isRedownload"))
						{
							tmpVariant.isReDownloadAvailable = (String(variant.@isRedownload) == "true") ? true : false;
						}
					}
					
					if (!preSelectedVariant) preSelectedVariant = tmpComponent.downloadVariants[0];
					
					tmpComponent.selectedVariantIndex = tmpComponent.downloadVariants.indexOf(preSelectedVariant);
					tmpComponent.version = preSelectedVariant.version;
					tmpComponent.downloadURL = preSelectedVariant.downloadURL;
					tmpComponent.installToPath = getInstallDirectoryPath(tmpComponent.type, tmpComponent.version);
					tmpComponent.sizeInMb = preSelectedVariant.sizeInMb;
				}
				
				// parse validation-path
				// con contain platform specific or global values
				if (comp.pathValidation.hasOwnProperty('windows'))
				{
					tmpComponent.pathValidation = String(comp.pathValidation[HelperConstants.IS_MACOS ? "mac" : "windows"]);
				}
				else
				{
					tmpComponent.pathValidation = String(comp.pathValidation);
				}
				
				// parse license
				// can contain platform specific or global values
				if (comp.license.hasOwnProperty('windows'))
				{
					tmpComponent.licenseUrl = String(comp.license[HelperConstants.IS_MACOS ? "mac" : "windows"].url);
					tmpComponent.licenseTitle = String(comp.license[HelperConstants.IS_MACOS ? "mac" : "windows"].title);
					setDescriptionBy(comp.license[HelperConstants.IS_MACOS ? "mac" : "windows"].description, tmpComponent);
				}
				else
				{
					tmpComponent.licenseUrl = String(comp.license.url);
					tmpComponent.licenseTitle = String(comp.license.title);
					setDescriptionBy(comp.license.description, tmpComponent);
				}
				
				model.components.add(tmpComponent);
			}
			
			// parse components
			model.packages = new ArrayCollection();
			var tmpPackage:PackageVO;
			for each (var pkg:XML in xmlData.packages.item)
			{
				tmpPackage = new PackageVO();
				tmpPackage.title = String(pkg.title);
				tmpPackage.description = String(pkg.description);
				tmpPackage.imagePath = String(pkg.image);
				tmpPackage.isIntegrated = (String(pkg.@integrated) == "true") ? true : false;
				
				var dependencyIDs:Array = String(pkg.componentDependencyIDs).split(",");
				if (dependencyIDs[0] != "") 
				{
					tmpPackage.dependencyTypes = new ArrayCollection()
					for each (var id:String in dependencyIDs)
					{
						tmpComponent = HelperUtils.getComponentById(id);
						tmpComponent.description += ((tmpComponent.description == staticRequiredText) ? tmpPackage.title : ", "+ tmpPackage.title);
						tmpPackage.dependencyTypes.add(tmpComponent);
					}
				}
				
				model.packages.add(tmpPackage);
			}
		}
		
		public static function getFeathersObjectForApacheInstaller():Object
		{
			var feathers:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_FEATHERS);
			var shortNameSplit:Array = feathers.downloadURL.split("/").pop().split(".");
			shortNameSplit.pop();
			if (HelperConstants.IS_MACOS) shortNameSplit.pop(); // this will to remove .tar
			var shortName:String = shortNameSplit.join(".");
			var fileName:String = feathers.downloadURL.split("/").pop();
			var label:String = feathers.title + feathers.version;
			var path:String = feathers.downloadURL.substring(0, feathers.downloadURL.indexOf(fileName));
			
			return {
				shortName: shortName, fileName: fileName, label: label, version: feathers.version,
					path: path, overlay: false, prefix: "feathers-sdk-", legacy: false, nocache: false,
					needsAIR: true, needsFlash: true, devBuild: false, icon: feathers.imagePath
			};
		}
		
		public static function getInstallDirectoryPath(type:String, version:String):String
		{
			switch (type)
			{
				case ComponentTypes.TYPE_FLEX:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Flex_SDK"+ File.separator +"Flex_"+ version +"_AIR_"+ HelperConstants.CONFIG_ADOBE_AIR_VERSION;
				case ComponentTypes.TYPE_FLEX_HARMAN:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Flex_SDK"+ File.separator +"Flex_"+ version +"_AIR_"+ HelperConstants.CONFIG_HARMAN_AIR_VERSION;
				case ComponentTypes.TYPE_FLEXJS:
					return null;
				case ComponentTypes.TYPE_ROYALE:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Royale_SDK"+ File.separator +"apache-royale-"+ version +"-bin-js";
				case ComponentTypes.TYPE_FEATHERS:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Flex_SDK"+ File.separator +"feathers-sdk-"+ version +"-bin";
				case ComponentTypes.TYPE_ANT:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Ant"+ File.separator +"apache-ant-"+ version;
				case ComponentTypes.TYPE_MAVEN:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Maven"+ File.separator +"apache-maven-"+ version;
				case ComponentTypes.TYPE_GRADLE:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Gradle"+ File.separator +"gradle-"+ version +"-bin";
				case ComponentTypes.TYPE_GRAILS:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Grails"+ File.separator +"grails-"+ version;
				case ComponentTypes.TYPE_OPENJAVA:
				case ComponentTypes.TYPE_OPENJAVA_V8:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Java"+ File.separator +"openjdk-"+ version;
				case ComponentTypes.TYPE_GIT:
					if (HelperConstants.IS_MACOS) return "Command Line Tools";
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"Git"+ File.separator +"git-"+ version;
				case ComponentTypes.TYPE_SVN:
					//if (HelperConstants.IS_MACOS) return "Command Line Tools";
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"SVN"+ File.separator +"slik-svn-"+ version;
				case ComponentTypes.TYPE_NODEJS:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath + File.separator +"NodeJS"+ File.separator +"node-v"+ version;
				case ComponentTypes.TYPE_NOTES:
					return "";
				default:
					throw new Error("Unknown Component Type");
			}
			
			return null;
		}
		
		private static function setDescriptionBy(node:XMLList, to:ComponentVO):void
		{
			if (node.hasOwnProperty("@licenseFile"))
			{
				if (FileUtils.isPathExists(File.applicationDirectory.nativePath + "/helperResources/data/"+ String(node.@licenseFile)))
				{
					to.licenseSmallDescription = FileUtils.readFromFile(File.applicationDirectory.resolvePath("helperResources/data/"+ String(node.@licenseFile))) as String;
				}
			}
			else
			{
				to.licenseSmallDescription = String(node);
			}
		}
	}
}