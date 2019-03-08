package actionScripts.valueObjects
{
	import flash.filesystem.File;

	[Bindable] public class HelperConstants
	{
		[Embed(source="/helperResources/images/bg_listDivider.png")]
		public static const BG_LIST_DIVIDER:Class;
		[Embed(source="/helperResources/images/bg_listDivider_white.png")]
		public static const BG_LIST_DIVIDER_WHITE:Class;
		
		public static const SUCCESS:String = "success";
		public static const ERROR:String = "error";
		public static const WARNING:String = "warning";
		public static const START:String = "start";
		public static const MOONSHINE_NOTIFIER_FILE_NAME:String = "MoonshineHelperNewUpdate.xml";
		
		public static var IS_MACOS:Boolean;
		public static var IS_RUNNING_IN_MOON:Boolean;
		public static var DEFAULT_INSTALLATION_PATH:File;
		public static var CONFIG_AIR_VERSION:String;
		public static var WINDOWS_64BIT_DOWNLOAD_URL:String;
		public static var WINDOWS_64BIT_DOWNLOAD_DIRECTORY:String;
	}
}