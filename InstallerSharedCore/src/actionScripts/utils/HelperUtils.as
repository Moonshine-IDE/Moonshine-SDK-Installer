package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.HelperSDKVO;

	public class HelperUtils
	{
		private static var model:HelperModel = HelperModel.getInstance();
		
		public static function getComponentById(id:String):ComponentVO
		{
			for (var i:int; i < model.components.length; i++)
			{
				if (model.components[i].id == id) return model.components[i];
			}
			return null;
		}
		
		public static function runAppStoreHelper():void
		{
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = HelperConstants.IS_MACOS ? 
				File.documentsDirectory.resolvePath("/bin/bash") :
				new File("C:/Program Files (x86)/MoonshineAppStoreHelper/MoonshineAppStoreHelper.exe");
			
			// probable termination
			if (!npInfo.executable.exists) return;
			
			var arg:Vector.<String> = new Vector.<String>();
			
			if (HelperConstants.IS_MACOS)
			{
				var shFile:File = File.applicationDirectory.resolvePath("macOScripts/SendToASH.sh");
				var pattern:RegExp = new RegExp( /( )/g );
				var shPath:String = shFile.nativePath.replace(pattern, "\\ ");
				
				arg.push("-c");
				arg.push(shPath);
			}
			
			npInfo.arguments = arg;
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}
		
		public static function isSDKFolder(path:File):HelperSDKVO
		{
			var descriptor:File = path.resolvePath("royale-sdk-description.xml");
			if (!descriptor.exists)
			{
				descriptor = path.resolvePath("royale-asjs/royale-sdk-description.xml");
			}
			if (!descriptor.exists)
			{
				descriptor = path.resolvePath("flex-sdk-description.xml");
			}
			
			if (descriptor.exists)
			{
				// read the xml value to get SDK name
				var tmpXML:XML = XML(FileUtils.readFromFile(descriptor));
				var displayName:String = tmpXML["name"];
				if (descriptor.name.indexOf("royale") > -1)
				{
					displayName += " " + tmpXML.version;
				}
				
				var tmpSDK:HelperSDKVO = new HelperSDKVO();
				tmpSDK.path = descriptor.parent;
				tmpSDK.name = displayName;
				tmpSDK.version = String(tmpXML.version);
				tmpSDK.build = String(tmpXML.build);
				
				return tmpSDK;
			}
			
			return null;
		}
	}
}