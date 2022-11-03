package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import spark.components.Alert;
	
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	public class LinkVerifier extends NativeProcess
	{
		private var customProcess:NativeProcess;
		private var resultHandler:Function;
		private var component:ComponentVO;
		private var isSuccessOrError:Boolean;
		
		/**
		 * resultHandler --> BOOL, ComponentVO
		 * Example,
		 * function myResultHandler(success:Boolean, component:ComponentVO)
		 */
		public function LinkVerifier(component:ComponentVO, 
									 resultHandler:Function, 
									 directURL:String=null)
		{
			super();
			
			this.resultHandler = resultHandler;
			this.component = component;
			
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = HelperConstants.IS_MACOS ? 
				File.documentsDirectory.resolvePath("/bin/bash") : 
				new File("c:\\Windows\\System32\\cmd.exe");
			
			var command:String = "curl --head --fail "+ (directURL ? directURL : component.downloadURL);
			if (HelperConstants.IS_MACOS)
			{
				npInfo.arguments = Vector.<String>(["-c", command]);
			}
			else
			{
				npInfo.arguments = Vector.<String>(["/c", command]);
			}
			
			startShell(true);
			customProcess.start(npInfo);
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
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
			}
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			isSuccessOrError = true;

			Alert.show("DATA:\n" + data);
			
			relayResult(true);
		}
		
		private function shellError(event:ProgressEvent):void
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				isSuccessOrError = true;
				Alert.show("ERROR:\n" + data);

				/*if (data.match(/certificate/))
				{
					// any certificate related error treat that as Okay
					relayResult(true);
				}
				else
				{
					Alert.show("Link verification failed:\n"+ data, "Error!");
					relayResult(false);
				}*/

				dispose();
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				Alert.show("EXIT:");
				// in case of invalid link process doesn't 
				// returns anything either as data or error.
				// testing by a flag help to understand to
				// verify invalid link in that case
				if (!isSuccessOrError)
				{
					relayResult(false);
				}
				
				dispose();
			}
		}
		
		private function relayResult(value:Boolean):void
		{
			if (resultHandler != null) 
				resultHandler(value, component);
		}
		
		private function dispose():void
		{
			startShell(false);
			
			resultHandler = null;
			component = null;
			isSuccessOrError = true;
		}
	}
}