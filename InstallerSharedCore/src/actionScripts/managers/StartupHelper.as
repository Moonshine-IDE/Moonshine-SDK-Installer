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
				HelperConstants.DEFAULT_INSTALLATION_PATH = new File("/" + tmpUserFolderSplit.join("/") + "/Downloads/MoonshineSDKs");
			}
			else
			{
				// TODO: need to decide on download directory
				trace(File.userDirectory.nativePath);
			}
		}
		
		public function loadMoonshineConfig():void
		{
			var configFile:File = HelperConstants.IS_MACOS ? 
				File.applicationDirectory.resolvePath("/helperResources/data/moonshineHelperConfig.xml") : 
				new File(File.applicationDirectory.nativePath + "/helperResources/data/moonshineHelperConfig.xml");
			FileUtils.readFromFileAsync(configFile, FileUtils.DATA_FORMAT_STRING, onMoonshineConfigLoaded, onMoonshineConfigError);
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