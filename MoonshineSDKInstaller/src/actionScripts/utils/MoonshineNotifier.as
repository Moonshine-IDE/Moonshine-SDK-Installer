package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class MoonshineNotifier
	{
		private static const UPDATE_XML_STRING:String = '<root><item id="$id"/></root>';
		
		public static function notifyMoonshineWithUpdate(item:ComponentVO):void
		{
			var moonshineStorage:File = HelperConstants.IS_MACOS ? 
				File.userDirectory.resolvePath("Library/Containers/com.moonshine-ide/Data/Library/Application Support/com.moonshine-ide/Local Store") :
				File.userDirectory.resolvePath("AppData/Roaming/com.moonshine-ide/Local Store");
			
			if (moonshineStorage.exists)
			{
				moonshineStorage = moonshineStorage.resolvePath("MoonshineHelperNewUpdate.xml");
				
				// save the recent update information
				var updateXML:XML = new XML(UPDATE_XML_STRING.replace("$id", item.id));
				
				var tmpStream:FileStream = new FileStream();
				tmpStream.open(moonshineStorage, FileMode.WRITE);
				tmpStream.writeUTFBytes(updateXML);
				tmpStream.close();
				
				// send update notification to Moonshine
				sendUpdateNotificationToMoonshine();
			}
		}
		
		private static function sendUpdateNotificationToMoonshine():void
		{
			var scpt:File = File.applicationDirectory.resolvePath("macOScripts/SendToMoonshine.scpt");
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			npInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");
			
			var arg:Vector.<String> = new Vector.<String>();
			arg.push(scpt.nativePath);
			arg.push("");
			
			npInfo.arguments = arg;
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}
	}
}