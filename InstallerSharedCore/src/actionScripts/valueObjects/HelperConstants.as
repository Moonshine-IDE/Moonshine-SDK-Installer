package actionScripts.valueObjects
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import actionScripts.utils.HelperUtils;
	
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
		public static const MOONSHINE_NOTIFIER_FILE_NAME:String = ".MoonshineHelperNewUpdate.xml";
		public static const INSTALLER_COOKIE:String = "moonshine-installer-local";
		public static const DEFAULT_SDK_FOLDER_NAME:String = "MoonshineSDKs";
		
		public static var IS_MACOS:Boolean = !NativeApplication.supportsSystemTrayIcon;
		public static var IS_RUNNING_IN_MOON:Boolean;
		public static var IS_INSTALLER_READY:Boolean;
		public static var DEFAULT_INSTALLATION_PATH:File;
		public static var CONFIG_AIR_VERSION:String;
		public static var WINDOWS_64BIT_DOWNLOAD_DIRECTORY:String;
		public static var INSTALLER_UPDATE_CHECK_URL:String;
		public static var IS_DETECTION_IN_PROCESS:Boolean;
		public static var CUSTOM_PATH_SDK_WINDOWS:String;
		public static var IS_CUSTOM_WINDOWS_PATH:Boolean;
		public static var IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH:Boolean;
		
		public static function get HELPER_STORAGE():File
		{
			if (IS_MACOS) 
			{
				// on sandbox File.userDirectory returns an strage path, i.e.
				// /Users/$user/Library/Containers/com.moonshine-ide/Data
				// thus, we need to determine more practical path out of it
				DEFAULT_INSTALLATION_PATH = HelperUtils.getMacOSDownloadsDirectory();
				return DEFAULT_INSTALLATION_PATH;
			}
			
			return File.userDirectory.resolvePath("AppData/Roaming/net.prominic.MoonshineSDKInstaller/Local Store");
		}
	}
}