package actionScripts.valueObjects;

extern class HelperConstants
{
	public static final BG_LIST_DIVIDER:Class;
	public static final BG_LIST_DIVIDER_WHITE:Class;
	
	public static final SUCCESS:String;
	public static final ERROR:String;
	public static final WARNING:String;
	public static final START:String;
	public static final MOONSHINE_NOTIFIER_FILE_NAME:String;
	public static final INSTALLER_COOKIE:String;
	public static final DEFAULT_SDK_FOLDER_NAME:String;
	
	public static var IS_MACOS:Boolean;
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
	
	public static function get HELPER_STORAGE():File;
}