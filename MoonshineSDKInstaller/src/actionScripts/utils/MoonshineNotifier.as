package actionScripts.utils
{
	import com.adobe.utils.StringUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class MoonshineNotifier
	{
		private static const UPDATE_XML_STRING:String = '<root><item id="$id" type="$id"><path>$path</path></item></root>';
		
		private var customProcess:NativeProcess;
		
		public function notifyMoonshineWithUpdate(item:ComponentVO):void
		{
			var moonshineStorage:File = HelperConstants.IS_MACOS ? 
				File.userDirectory.resolvePath("Library/Containers/com.moonshine-ide/Data/Library/Application Support/com.moonshine-ide/Local Store") :
				File.userDirectory.resolvePath("AppData/Roaming/com.moonshine-ide/Local Store");
			
			if (moonshineStorage.exists)
			{
				moonshineStorage = moonshineStorage.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);
				
				// save the recent update information
				var xmlString:String = UPDATE_XML_STRING.replace(/(\$id)/g, item.id);
				xmlString = xmlString.replace("$path", item.installToPath);
				var updateXML:XML = new XML(xmlString);
				FileUtils.writeToFile(moonshineStorage, updateXML);
				
				// send update notification to Moonshine
				// mac specific
				if (HelperConstants.IS_MACOS) sendUpdateNotificationToMoonshine();
				else findMoonshineProcessWindows();
			}
		}
		
		private function sendUpdateNotificationToMoonshine(moonshineBinPath:String=null):void
		{
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var arg:Vector.<String> = new Vector.<String>();
			
			if (HelperConstants.IS_MACOS)
			{
				var scpt:File = File.applicationDirectory.resolvePath("shellScripts/SendToMoonshine.scpt");
				npInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");
				arg.push(scpt.nativePath);
				arg.push("");
				npInfo.arguments = arg;
			}
			else if (moonshineBinPath)
			{
				npInfo.executable = new File(moonshineBinPath);
			}
			
			var process:NativeProcess = new NativeProcess();
			process.start(npInfo);
		}
		
		private function findMoonshineProcessWindows():void
		{
			startShell(false);
			
			var batFile:File = File.applicationDirectory.resolvePath("shellScripts/DetectMoonshineWinProcess.bat");
			
			var customInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			customInfo.executable = new File("c:\\Windows\\System32\\cmd.exe");
			customInfo.arguments = Vector.<String>(["/c", batFile.nativePath]);
			
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			var searchString:String = "executablepath=";
			var pathIndex:int = data.toLowerCase().indexOf(searchString);
			if (pathIndex != -1)
			{
				data = StringUtil.trim(data.substr(pathIndex + searchString.length, data.indexOf("\r", pathIndex)));
				sendUpdateNotificationToMoonshine(data);
			}
		}
		
		private function shellError(event:ProgressEvent):void
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				startShell(false);
			}
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
			}
		}
	}
}