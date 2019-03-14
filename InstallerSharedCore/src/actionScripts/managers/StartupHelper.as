package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.events.HelperEvent;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.Parser;
	import actionScripts.valueObjects.HelperConstants;

	[Event(name="EVENT_CONFIG_LOADED", type="actionScripts.events.HelperEvent")]
	[Event(name="EVENT_CONFIG_ERROR", type="actionScripts.events.HelperEvent")]
	public class StartupHelper extends EventDispatcher
	{
		public static const EVENT_CONFIG_LOADED:String = "eventConfigLoaded";
		public static const EVENT_CONFIG_ERROR:String = "eventConfigError";
		
		public function setLocalPathConfig():void
		{
			var tmpUserFolderSplit: Array = File.userDirectory.nativePath.split(File.separator);
			if (HelperConstants.IS_MACOS)
			{
				// for macOS ~/Downloads directory
				if (tmpUserFolderSplit[1] == "Users") tmpUserFolderSplit = tmpUserFolderSplit.slice(1, 3);
				HelperConstants.DEFAULT_INSTALLATION_PATH = new File("/" + tmpUserFolderSplit.join("/") +"/Downloads/"+ HelperConstants.DEFAULT_SDK_FOLDER_NAME);
			}
			else
			{
				// Windows download directory
				HelperConstants.DEFAULT_INSTALLATION_PATH = HelperConstants.CUSTOM_PATH_SDK_WINDOWS ? 
					new File(HelperConstants.CUSTOM_PATH_SDK_WINDOWS) : 
					File.documentsDirectory.resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME);
				
				// determine if choosing custom sdk path is allow-able
				if ((!HelperConstants.CUSTOM_PATH_SDK_WINDOWS && !HelperConstants.DEFAULT_INSTALLATION_PATH.exists) || 
					(HelperConstants.CUSTOM_PATH_SDK_WINDOWS && !FileUtils.isPathExists(HelperConstants.CUSTOM_PATH_SDK_WINDOWS)))
				{
					HelperConstants.IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH = true;
				}
			}
		}
		
		public function loadMoonshineConfig():void
		{
			var configFile:String = File.applicationDirectory.nativePath + "/helperResources/data/moonshineHelperConfig.xml";
			FileUtils.readFromFileAsync(new File(configFile), FileUtils.DATA_FORMAT_STRING, onMoonshineConfigLoaded, onMoonshineConfigError);
		}
		
		protected function onMoonshineConfigLoaded(value:Object):void
		{
			var config:XML = new XML(value);
			if (config) Parser.parseHelperConfig(config);
			
			dispatchEvent(new HelperEvent(EVENT_CONFIG_LOADED));
		}
		
		protected function onMoonshineConfigError(value:String):void
		{
			dispatchEvent(new HelperEvent(EVENT_CONFIG_ERROR, value));
		}
	}
}