package actionScripts.utils
{
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.utils.IDataInput;
	
	import actionScripts.events.HelperEvent;
	import actionScripts.valueObjects.EnvironmentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	[Event(name="ENV_READ_COMPLETED", type="actionScripts.events.HelperEvent")]
	[Event(name="ENV_READ_ERROR", type="actionScripts.events.HelperEvent")]
	public class EnvironmentUtils extends NativeProcessBase
	{
		public static const ENV_READ_COMPLETED:String = "ENV_READ_COMPLETED";
		public static const ENV_READ_ERROR:String = "ENV_READ_ERROR";
		
		private var errorCloseData:String;
		private var environmentData:String;
		
		private var _environments:EnvironmentVO;
		public function get environments():EnvironmentVO
		{
			return _environments;
		}
		
		public function EnvironmentUtils() {}
		
		public function readValues():void
		{
			// since mapping an environment variable won't work
			// in sandbox Moonshine unless the folder opened
			// by file-browser dialog once, let's keep this
			// for Windows only
			if (!HelperConstants.IS_MACOS)
			{
				// it's possible that data returns in
				// multiple standard_output_data
				// we need a container to hold the breakups
				environmentData = "";
				
				start(new <String>["set"]);
			}
		}

		override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void 
		{
			var output:IDataInput = (nativeProcess.standardOutput.bytesAvailable != 0) ? nativeProcess.standardOutput : nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			var match:Array = data.match(/fatal: .*/);
			if (match)
			{
				errorCloseData = data;
			}
			else if (data != "")
			{
				environmentData += data + "\r\n";
			}
		}
		
		override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void 
		{
			if (nativeProcess)
			{
				var output:IDataInput = nativeProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();

				errorCloseData = data;
				dispose();
				
				this.dispatchEvent(new HelperEvent(ENV_READ_ERROR, errorCloseData));
			}
		}
		
		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void 
		{
			if (nativeProcess) 
			{
				dispose();
				
				// parse
				if (errorCloseData)
				{
					this.dispatchEvent(new HelperEvent(ENV_READ_ERROR, errorCloseData));
					return;
				}
				
				if (environmentData != "")
				{
					_environments = new EnvironmentVO();
					try
					{
						Parser.parseEnvironmentFrom(environmentData, _environments);
					} catch (e:Error)
					{
						environmentData += "\nParsing error:: "+ e.getStackTrace();
					}
				}
				// pass completion
				this.dispatchEvent(new HelperEvent(ENV_READ_COMPLETED, environmentData));
			}
		}
	}
}