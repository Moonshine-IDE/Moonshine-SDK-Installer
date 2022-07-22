package actionScripts.utils
{
	import flash.filesystem.File;
	
	import mx.utils.StringUtil;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ComponentVariantVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.HelperSDKVO;

	public class HelperUtils
	{
		private static var model:HelperModel = HelperModel.getInstance();
		
		public static function getComponentById(id:String):ComponentVO
		{
			if (!model.components) return null;
			
			// go by source as collection can be in filtered state
			for (var i:int; i < model.components.length; i++)
			{
				if (model.components.get(i).id == id) return (model.components.get(i) as ComponentVO);
			}
			return null;
		}
		
		public static function getComponentByType(type:String):ComponentVO
		{
			if (!model.components) return null;

			// go by source as collection can be in filtered state
			for each (var item:ComponentVO in model.components.array)
			{
				if (item.type == type)
				{
					return item;
				}
			}
			
			return null;
		}
		
		public static function isSDKFolder(path:File):HelperSDKVO
		{
			var descriptor:File = path.resolvePath("royale-sdk-description.xml");
			if (!descriptor.exists)
			{
				descriptor = path.resolvePath("royale-asjs/royale-sdk-description.xml");
			}
			if (!descriptor.exists)
			{
				descriptor = path.resolvePath("flex-sdk-description.xml");
			}
			
			if (descriptor.exists)
			{
				// read the xml value to get SDK name
				var tmpXML:XML = XML(FileUtils.readFromFile(descriptor));
				var displayName:String = tmpXML["name"];
				if (descriptor.name.indexOf("royale") > -1)
				{
					displayName += " " + tmpXML.version;
				}
				
				var tmpSDK:HelperSDKVO = new HelperSDKVO();
				tmpSDK.path = descriptor.parent;
				tmpSDK.name = displayName;
				tmpSDK.version = String(tmpXML.version);
				tmpSDK.build = String(tmpXML.build);
				
				return tmpSDK;
			}
			
			return null;
		}
		
		/**
		 * @returns
		 * 0 = no
		 * 1 = yes
		 * -1 = similar 
		 */
		public static function isNewUpdateVersion(currentVersion:String, updateVersion:String):int
		{
			if (currentVersion == updateVersion) return -1;
			
			var _currentMajor:int = -1;
			var _currentMinor:int = -1;
			var _currentRevision:int = -1;
			
			var currentVersionIndexes:Array = currentVersion.split(".");
			_currentMajor = parseInt(currentVersionIndexes[0]);
			if (currentVersionIndexes.length > 1) _currentMinor = parseInt(currentVersionIndexes[1]);
			if (currentVersionIndexes.length > 2) _currentRevision = parseInt(currentVersionIndexes[2]);
			
			var uv1:Number = -1;
			var uv2:Number = -1;
			var uv3:Number = -1;

			var updateVersionIndexes:Array = updateVersion.split(".");
			uv1 = Number(updateVersionIndexes[0]);
			if (updateVersionIndexes.length > 1) uv2 = Number(updateVersionIndexes[1]);
			if (updateVersionIndexes.length > 2) uv3 = Number(updateVersionIndexes[2]);
			
			if ((uv1 != -1) && (uv1 > _currentMajor)) return 1;
			else if ((uv2 != -1) && (uv1 >= _currentMajor) && (uv2 > _currentMinor)) return 1;
			else if ((uv3 != -1) && (uv1 >= _currentMajor) && (uv2 >= _currentMinor) && (uv3 > _currentRevision)) return 1;
			
			return 0;
		}
		
		public static function getMacOSDownloadsDirectory():File
		{
			if (!HelperConstants.DEFAULT_INSTALLATION_PATH)
			{
				HelperConstants.DEFAULT_INSTALLATION_PATH = FileUtils.getUserDownloadsDirectory().resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME);
			}
			
			return HelperConstants.DEFAULT_INSTALLATION_PATH;
		}
		
		public static function isValidSDKDirectoryBy(type:String, originPath:String, validationPath:Array=null):Boolean
		{
			if (FileUtils.isPathExists(originPath))
			{
				// file-system check inside the named-sdk
				if (validationPath)
				{
					var isValidPath:Boolean = validationPath.some(function (path:String, index:int, arr:Array):Boolean
					{
						if (FileUtils.isPathExists(originPath + File.separator + StringUtil.trim(path)))
						{
							return true;
						}
						return false;
					});
					return isValidPath;
				}
				else
				{
					return true;
				}
			}
			
			return false;
		}

		public static function isValidExecutableBy(type:String, originPath:String, validationPath:Array=null):Boolean
		{
			var pathValidationFileName:String;
			if (FileUtils.isPathExists(originPath))
			{
				// special test to not to validate by any sub-path
				// on macOS where the path is not command-line-tools or
				// xcode, since the path needs to be direct executable link
				if (HelperConstants.IS_MACOS && 
					(type == ComponentTypes.TYPE_GIT) && 
					!isGitSVNSpecialPathCheckPass(originPath))
				{
					return false;
				}

				// file-system check inside the named-sdk
				if (validationPath)
				{
					for each (var path:String in validationPath)
					{
						if (StringUtil.trim(path).length != 0)
						{
							originPath = FileUtils.normalizePath(originPath);
							pathValidationFileName = FileUtils.normalizePath(path);

							// SDKs which validates based on *_HOME way
							if ((type != ComponentTypes.TYPE_GIT) && (type != ComponentTypes.TYPE_SVN))
							{
								var fullPath:String = originPath + File.separator + pathValidationFileName;
								if (FileUtils.isPathExists(fullPath))
								{
									return true;
								}
							}
							else
							{
								if (originPath.toLowerCase().indexOf(pathValidationFileName.toLowerCase()) != -1)
								{
									return true;
								}
							}
						}
					}
				}
				else
				{
					return true;
				}
			}

			return false;
		}
		
		public static function updatePathWithCustomWindows(path:String):void
		{
			// probable termination
			if (path == HelperConstants.CUSTOM_PATH_SDK_WINDOWS) return;
			
			// update default directory location
			HelperConstants.IS_CUSTOM_WINDOWS_PATH = true;
			HelperConstants.CUSTOM_PATH_SDK_WINDOWS = path;
			HelperConstants.DEFAULT_INSTALLATION_PATH = new File(HelperConstants.CUSTOM_PATH_SDK_WINDOWS);
			
			// update target location for each components
			for each (var item:ComponentVO in model.components.array)
			{
				item.installToPath = HelperConstants.CUSTOM_PATH_SDK_WINDOWS +  
					item.installToPath.substring(item.installToPath.indexOf(HelperConstants.DEFAULT_SDK_FOLDER_NAME) + HelperConstants.DEFAULT_SDK_FOLDER_NAME.length);
			}
		}
		
		public static function getTotalDiskSizePendingItems():String
		{
			var totalMbs:int;
			for each (var item:ComponentVO in model.components.array)
			{
				if (!item.isAlreadyDownloaded && item.isDownloadable)
				{
					totalMbs += item.sizeInMb;
				}
			}
			
			return getSizeFix(totalMbs);
		}
		
		public static function getSizeFix(value:int):String
		{
			if (value.toString().length > 3)
			{
				return ((value / 1000).toFixed(2) +" GB");
			}
			
			return (value +" MB");
		}
		
		public static function updateComponentByVariant(component:ComponentVO, variant:ComponentVariantVO):void
		{
			component.installToPath = Parser.getInstallDirectoryPath(component.type, variant.version);
			component.version = variant.version;
			component.downloadURL = variant.downloadURL;
			component.sizeInMb = variant.sizeInMb;
		}
		
		public static function convertString(path:String):String
		{
			if (!HelperConstants.IS_MACOS)
			{
				path= path.split(" ").join("^ ");
				path= path.split("(").join("^(");
				path= path.split(")").join("^)");
				path= path.split("&").join("^&");
			}
			else
			{
				path= path.split(" ").join("\\ ");
				path= path.split("(").join("\\(");
				path= path.split(")").join("\\)");
				path= path.split("&").join("\\&");
			}
			return path;
		}
		
		/**
		 * Returns encoded string to run on Windows' shell
		 */
		public static function getEncodedForShell(value:String, forceOSXEncode:Boolean=false, forceWindowsEncode:Boolean=false):String
		{
			var tmpValue:String = "";
			if (HelperConstants.IS_MACOS || forceOSXEncode)
			{
				// @note
				// in case of /bash one should send the value surrounded by $''
				// i.e. $' +encodedValue+ '
				tmpValue = value.replace(/(\\)/g, '\\\\"');
				tmpValue = value.replace(/(")/g, '\\"');
				tmpValue = value.replace(/(')/g, "\\'");
			}
			else if (!HelperConstants.IS_MACOS || forceWindowsEncode)
			{
				for (var i:int; i < value.length; i++)
				{
					tmpValue += "^"+ value.charAt(i);
				}
			}
			
			return tmpValue;
		}

		private static function isGitSVNSpecialPathCheckPass(pathValue:String):Boolean
		{
			if ((pathValue.toLowerCase().indexOf("commandlinetools") != -1) ||
					(pathValue.toLowerCase().indexOf("xcode.app/contents") != -1))
			{
				return true;
			}

			return false;
		}
	}
}