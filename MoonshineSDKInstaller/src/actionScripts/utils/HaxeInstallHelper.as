package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import mx.controls.Alert;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class HaxeInstallHelper extends EventDispatcher
	{
		public static const EVENT_INSTALL_OUTPUT:String = "eventHaxeInstallOutput";
		public static const EVENT_INSTALL_COMPLETES:String = "eventHaxeInstallCompletes";
		public static const EVENT_INSTALL_ERROR:String = "eventHaxeInstallError";
		
		private var windowsBatchFile:File;
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var haxeSetupCommands:Array;
		
		public function HaxeInstallHelper()
		{
			var haxeLibPath:String = HelperConstants.DEFAULT_INSTALLATION_PATH.resolvePath("Haxe").nativePath +
					File.separator + "lib";
			haxeSetupCommands = [
				"haxelib install feathersui --quiet",
				"haxelib install openfl --quiet",
				"haxelib install actuate --quiet",
				"haxelib install lime --quiet"
			];
			if (HelperConstants.IS_MACOS)
			{
				haxeSetupCommands.insertAt(0, "echo \""+ haxeLibPath +"\" | haxelib setup");
			}
			else
			{
				haxeSetupCommands.insertAt(0, "haxelib setup --always "+ haxeLibPath);
			}
		}
		
		public function execute():void
		{
			var setCommand:String = getPlatformCommand();
			
			// do not proceed if no path to set
			if (!setCommand)
			{
				return;
			}

			if (HelperConstants.IS_MACOS)
			{
				onCommandLineExecutionWith(setCommand);
			}
			else
			{
				// to reduce file-writing process
				// re-run by the existing file if the
				// contents matched
				windowsBatchFile = getBatchFilePath();
				try
				{
					//this previously used FileUtils.writeToFileAsync(), but commands
					//would sometimes fail because the file would still be in use, even
					//after the FileStream dispatched Event.CLOSE
					FileUtils.writeToFile(windowsBatchFile, setCommand);
					onBatchFileWriteComplete();
				}
				catch(e:Error)
				{
					onBatchFileWriteError(e.toString());
					return;
				}
			}
		}
		
		private function getPlatformCommand():String
		{
			var setCommand:String = HelperConstants.IS_MACOS ? "" : "@echo off\r\n";
			var isValidToExecute:Boolean;
			var setPathCommand:String = HelperConstants.IS_MACOS ? "export PATH=" : "set PATH=";
			var defaultOrCustomSDKPath:String;
			var haxe:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_HAXE);
			var neko:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_NEKO);
			
			if (FileUtils.isPathExists(haxe.installToPath))
			{
				setCommand += getSetExportWithoutQuote("HAXE_HOME", haxe.installToPath);
				setPathCommand += (HelperConstants.IS_MACOS ? "$HAXE_HOME:" : "%HAXE_HOME%;");
				isValidToExecute = true;
			}
			
			if (FileUtils.isPathExists(neko.installToPath))
			{
				setCommand += getSetExportWithoutQuote("DYLD_LIBRARY_PATH", neko.installToPath);
				setPathCommand += (HelperConstants.IS_MACOS ? "$DYLD_LIBRARY_PATH:" : "%DYLD_LIBRARY_PATH%;");
				isValidToExecute = true;
			}
			
			// if nothing found in above three don't run
			if (!isValidToExecute) return null;

			if (HelperConstants.IS_MACOS)
			{
				setCommand += setPathCommand + "$PATH;";
				setCommand += haxeSetupCommands.join(";");
			}
			else
			{
				// need to set PATH under application shell
				setCommand += setPathCommand + "%PATH%\r\n";
				setCommand += haxeSetupCommands.join("\r\n");
			}
			
			return setCommand;
		}

		private function getSetExportWithoutQuote(field:String, path:String):String
		{
			if (HelperConstants.IS_MACOS)
			{
				return getSetExportWithQuote(field, path);
			}

			return "set "+ field +"="+ path +"\r\n";
		}

		private function getSetExportWithQuote(field:String, path:String):String
		{
			if (HelperConstants.IS_MACOS)
			{
				return "export "+ field +"='"+ path +"';";
			}

			return "set "+ field +"=\""+ path +"\"\r\n";
		}
		
		private function getBatchFilePath():File
		{
			var tempDirectory:File = File.cacheDirectory.resolvePath("moonshine-sdk-installer/environmental");
			if (!tempDirectory.exists)
			{
				tempDirectory.createDirectory();
			}
			
			return tempDirectory.resolvePath(UIDUtil.createUID() +".cmd");
		}
		
		private function onBatchFileWriteError(value:String):void
		{
			Alert.show("Local environment setup failed[1]!\n"+ value, "Error!");
		}
		
		private function onBatchFileWriteComplete():void
		{
			onCommandLineExecutionWith(windowsBatchFile.nativePath);
		}

		private function onCommandLineExecutionWith(command:String):void
		{
			var haxe:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_HAXE);

			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = HelperConstants.IS_MACOS ?
					File.documentsDirectory.resolvePath("/bin/bash") : new File("c:\\Windows\\System32\\cmd.exe");

			customInfo.arguments = Vector.<String>([HelperConstants.IS_MACOS ? "-c" : "/c", command]);
			customProcess = new NativeProcess();
			customInfo.workingDirectory = new File(haxe.installToPath);
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
			}
		}
		
		private function shellError(event:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				trace("stdError: "+ data);
				startShell(false);
				dispatchEvent(new GeneralEvent(EVENT_INSTALL_ERROR, data));
			}
		}
		
		private function shellExit(event:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				startShell(false);
				dispatchEvent(new GeneralEvent(EVENT_INSTALL_COMPLETES));
			}
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			dispatchEvent(new GeneralEvent(EVENT_INSTALL_OUTPUT, data));
			trace("stdOut: "+ data);
		}
	}
}