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
	
	import spark.components.Alert;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class MoonshineNotifier
	{
		private var customProcess:NativeProcess;
		private var model:HelperModel = HelperModel.getInstance();
		
		public function notifyMoonshineWithUpdate():void
		{
			var applicationStorage:File = HelperConstants.HELPER_STORAGE.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);
			
			// save the recent update information
			var updateXML:XML = toXML();
			FileUtils.writeToFileAsync(applicationStorage, updateXML, onNotifierFileWriteCompletes, onNotifierFileWriteError);
		}
		
		private function onNotifierFileWriteCompletes():void
		{
			// send update notification to Moonshine
			// mac specific
			if (HelperConstants.IS_MACOS) sendUpdateNotificationToMoonshine();
			else findMoonshineProcessWindows();
		}
		
		private function onNotifierFileWriteError(value:String):void
		{
			Alert.show("Error notifying Moonshine-IDE.\n"+ value, "Error!");
		}
		
		private function toXML():XML
		{
			var root:XML = new XML(<root/>);
			var items:XML = new XML(<items/>);
			
			for each (var item:ComponentVO in model.components.source)
			{
				if (item.isAlreadyDownloaded)
				{
					var itemXml:XML = new XML(<item/>);
					itemXml.@id = item.id;
					itemXml.@type = item.id;
					
					var pathXML:XML = new XML(<path/>);
					pathXML.appendChild(item.installToPath);
					
					var validationXML:XML = new XML(<pathValidation/>);
					if (item.pathValidation) validationXML.appendChild(item.pathValidation);
					
					itemXml.appendChild(pathXML);
					itemXml.appendChild(validationXML);
					items.appendChild(itemXml);
				}
			}
			
			root.appendChild(items);
			return root;
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