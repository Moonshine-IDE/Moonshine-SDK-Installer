package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.business.DataAgent;
	import actionScripts.events.HelperEvent;
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
			}
		}
		
		public function loadMoonshineConfig():void
		{
			new DataAgent(File.applicationDirectory.resolvePath("/helperResources/data/moonshineHelperConfig.xml").nativePath, onMoonshineConfigLoaded, onMoonshineConfigError);
		}
		
		protected function onMoonshineConfigLoaded(message:String=null, ...args):void
		{
			var config:XML = XML(args[0]);
			if (config) Parser.parseHelperConfig(config);
			
			dispatchEvent(new HelperEvent(EVENT_CONFIG_LOADED));
		}
		
		protected function onMoonshineConfigError(errorMessage:String=null, ...args):void
		{
			dispatchEvent(new HelperEvent(EVENT_CONFIG_ERROR, errorMessage));
		}
	}
}