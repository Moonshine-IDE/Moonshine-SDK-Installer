package actionScripts.valueObjects
{
	import flash.filesystem.File;

	[Bindable] public class HelperConstants
	{
		[Embed(source="/helperResources/images/bg_listDivider.png")]
		public static const BG_LIST_DIVIDER:Class;
		[Embed(source="/helperResources/images/bg_listDivider_white.png")]
		public static const BG_LIST_DIVIDER_WHITE:Class;
		
		public static var IS_MACOS:Boolean;
		public static var IS_RUNNING_IN_MOON:Boolean;
		public static var DEFAULT_INSTALLATION_PATH:File;
		public static var CONFIG_AIR_VERSION:String;
	}
}