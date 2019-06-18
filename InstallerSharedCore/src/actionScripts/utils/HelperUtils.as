package actionScripts.utils
{
	import flash.filesystem.File;
	
	import mx.utils.StringUtil;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.HelperSDKVO;

	public class HelperUtils
	{
		private static var model:HelperModel = HelperModel.getInstance();
		
		public static function getComponentById(id:String):ComponentVO
		{
			if (!model.components) return null;
			
			// go by source as collection can be in filtered state
			for (var i:int; i < model.components.source.length; i++)
			{
				if (model.components.source[i].id == id) return model.components.source[i];
			}
			return null;
		}
		
		public static function getComponentByType(type:String):ComponentVO
		{
			if (!model.components) return null;

			// go by source as collection can be in filtered state
			for each (var item:ComponentVO in model.components.source)
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
		
		public static function isNewUpdateVersion(currentVersion:String, updateVersion:String):Boolean
		{
			var _currentMajor:int = -1;
			var _currentMinor:int = -1;
			var _currentRevision:int = -1;
			
			var tmpArr:Array = currentVersion.split(".");
			if (tmpArr.length == 3)
			{
				_currentMajor = parseInt(tmpArr[0]);
				_currentMinor = parseInt(tmpArr[1]);
				_currentRevision = parseInt(tmpArr[2]);
			}
			
			var tmpSplit:Array = updateVersion.split(".");
			var uv1:Number = Number(tmpSplit[0]);
			var uv2:Number = Number(tmpSplit[1]);
			var uv3:Number = Number(tmpSplit[2]);
			
			if (uv1 > _currentMajor) return true;
			else if (uv1 >= _currentMajor && uv2 > _currentMinor) return true;
			else if (uv1 >= _currentMajor && uv2 >= _currentMinor && uv3 > _currentRevision) return true;
			
			return false;
		}
		
		public static function getMacOSDownloadsDirectory():File
		{
			if (!HelperConstants.DEFAULT_INSTALLATION_PATH)
			{
				var tmpUserFolderSplit: Array = File.userDirectory.nativePath.split(File.separator);
				if (tmpUserFolderSplit[1] == "Users") tmpUserFolderSplit = tmpUserFolderSplit.slice(1, 3);
				HelperConstants.DEFAULT_INSTALLATION_PATH = new File("/" + tmpUserFolderSplit.join("/") +"/Downloads/"+ HelperConstants.DEFAULT_SDK_FOLDER_NAME);
			}
			
			return HelperConstants.DEFAULT_INSTALLATION_PATH;
		}
		
		public static function isValidSDKDirectoryBy(type:String, originPath:String, validationPath:String=null):Boolean
		{
			if (FileUtils.isPathExists(originPath))
			{
				// file-system check inside the named-sdk
				if (validationPath && StringUtil.trim(validationPath).length != 0)
				{
					if (FileUtils.isPathExists(originPath + File.separator + validationPath))
					{
						return true;
					}
				}
				else
				{
					return true;
				}
			}
			
			return false;
		}
		
		public static function isValidExecutableBy(type:String, originPath:String, validationPath:String=null):Boolean
		{
			var pathValidationFileName:String;
			if (FileUtils.isPathExists(originPath))
			{
				// file-system check inside the named-sdk
				if (validationPath && StringUtil.trim(validationPath).length != 0)
				{
					originPath = FileUtils.normalizePath(originPath);
					pathValidationFileName = FileUtils.normalizePath(validationPath);
					if (originPath.indexOf(pathValidationFileName) != -1)
					{
						return true;
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
			for each (var item:ComponentVO in model.components.source)
			{
				item.installToPath = HelperConstants.CUSTOM_PATH_SDK_WINDOWS +  
					item.installToPath.substring(item.installToPath.indexOf(HelperConstants.DEFAULT_SDK_FOLDER_NAME) + HelperConstants.DEFAULT_SDK_FOLDER_NAME.length);
			}
		}
		
		public static function getTotalDiskSizePendingItems():String
		{
			var totalMbs:int;
			for each (var item:ComponentVO in model.components)
			{
				if (!item.isAlreadyDownloaded)
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
	}
}