package actionScripts.managers
{
	import flash.net.SharedObject;
	
	import actionScripts.utils.FileUtils;
	import actionScripts.valueObjects.HelperConstants;

	public class CookieManager
	{
		private static var instance:CookieManager;
		
		private var cookie:SharedObject;
		
		public static function getInstance():CookieManager
		{	
			if (!instance) instance = new CookieManager();
			return instance;
		}
		
		public function loadLocalStorage():void
		{
			cookie = SharedObject.getLocal(HelperConstants.INSTALLER_COOKIE);
			
			// look for custom Windows path
			if (cookie.data.hasOwnProperty('customWindowsPath'))
			{
				if (FileUtils.isPathExists(cookie.data.customWindowsPath))
				{
					HelperConstants.CUSTOM_PATH_SDK_WINDOWS = cookie.data.customWindowsPath;
					HelperConstants.IS_CUSTOM_WINDOWS_PATH = (HelperConstants.CUSTOM_PATH_SDK_WINDOWS != "");
				}
			}
		}
		
		public function setWindowsCustomPath(value:String):void
		{
			cookie.data["customWindowsPath"] = value;
			cookie.flush();
		}
	}
}