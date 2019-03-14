package actionScripts.utils
{
	import flash.filesystem.File;
	
	import mx.utils.StringUtil;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.HelperSDKVO;

	public class HelperUtils
	{
		private static var model:HelperModel = HelperModel.getInstance();
		
		public static function getComponentById(id:String):ComponentVO
		{
			// go by source as collection can be in filtered state
			for (var i:int; i < model.components.source.length; i++)
			{
				if (model.components.source[i].id == id) return model.components.source[i];
			}
			return null;
		}
		
		public static function getComponentByType(type:String):ComponentVO
		{
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
		
		public static function isValidSDKDirectoryBy(type:String, originPath:String, validationPath:String=null):Boolean
		{
			var pathValidationFileName:String;
			if (FileUtils.isPathExists(originPath))
			{
				// file-system check inside the named-sdk
				if (validationPath && StringUtil.trim(validationPath).length != 0)
				{
					if (type == ComponentTypes.TYPE_OPENJAVA) 
					{
						pathValidationFileName = HelperConstants.IS_MACOS ? validationPath : validationPath +".exe";
					}
					else
					{
						pathValidationFileName = validationPath;
					}
					
					if (FileUtils.isPathExists(originPath + File.separator + pathValidationFileName))
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
	}
}