package actionScripts.utils
{
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.utils.IDataInput;
	
	import actionScripts.events.HelperEvent;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	[Event(name="ENV_READ_COMPLETED", type="actionScripts.events.HelperEvent")]
	[Event(name="ENV_READ_ERROR", type="actionScripts.events.HelperEvent")]
	public class JavaVersionReader extends NativeProcessBase
	{
		public static const ENV_READ_COMPLETED:String = "ENV_READ_COMPLETED";
		public static const ENV_READ_ERROR:String = "ENV_READ_ERROR";
		
		public var component:ComponentVO;
		
		private var errorCloseData:String;
		private var outputData:String = "";
		
		public function readVersion(javaPath:String=null):void
		{
			var tmpArgs:Vector.<String> = javaPath ? 
				new <String>[javaPath +"\\bin\\java", "-version"] : 
				new <String>["java", "-version"];
			start(tmpArgs);
		}

		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void 
		{
			var output:IDataInput = (nativeProcess.standardOutput.bytesAvailable != 0) ? nativeProcess.standardOutput : nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			if (data.match(/fatal: .*/))
			{
				errorCloseData = data;
			}
			else
			{
				outputData += data;
			}
		}
		
		override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void 
		{
			if (nativeProcess)
			{
				var output:IDataInput = nativeProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				// it's strange that output turns as
				// error data
				if (data.match(/version ".*/))
				{
					outputData += data;
				}
				else
				{
					errorCloseData = data;
				}
			}
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void 
		{
			if (nativeProcess) 
			{
				dispose();
				
				if (outputData) parseVersion(outputData);
				
				// pass completion
				if (errorCloseData) this.dispatchEvent(new HelperEvent(ENV_READ_ERROR, errorCloseData));
			}
		}
		
		private function parseVersion(value:String):void
		{
			var tmpLine:String = value.substring(
				value.indexOf("version \""),
				value.indexOf(HelperConstants.IS_MACOS ? "\n" : "\r\n")
			);
			var firstIndex:int = tmpLine.indexOf("\"")+1;
			var version:String = tmpLine.substring(firstIndex, tmpLine.indexOf("\"", firstIndex+1));
			if (version.indexOf("_") != -1)
			{
				version = version.substring(0, version.indexOf("_"));
			}
			
			// pass completion
			this.dispatchEvent(new HelperEvent(ENV_READ_COMPLETED, version));
		}
	}
}