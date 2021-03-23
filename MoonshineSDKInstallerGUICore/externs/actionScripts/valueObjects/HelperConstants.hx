package actionScripts.valueObjects;

extern class HelperConstants
{
	public static final SUCCESS:String;
	public static final ERROR:String;
	public static final WARNING:String;
	public static final START:String;
	public static final MOONSHINE_NOTIFIER_FILE_NAME:String;
	public static final INSTALLER_COOKIE:String;
	public static final DEFAULT_SDK_FOLDER_NAME:String;
	
	public static var IS_MACOS:Bool;
	public static var IS_RUNNING_IN_MOON:Bool;
	public static var IS_INSTALLER_READY:Bool;
	public static var DEFAULT_INSTALLATION_PATH:Dynamic;
	public static var CONFIG_AIR_VERSION:String;
	public static var WINDOWS_64BIT_DOWNLOAD_DIRECTORY:String;
	public static var INSTALLER_UPDATE_CHECK_URL:String;
	public static var IS_DETECTION_IN_PROCESS:Bool;
	public static var CUSTOM_PATH_SDK_WINDOWS:String;
	public static var IS_CUSTOM_WINDOWS_PATH:Bool;
	public static var IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH:Bool;
	
	@:flash.property
	public static var HELPER_STORAGE(default, default):Dynamic;
}