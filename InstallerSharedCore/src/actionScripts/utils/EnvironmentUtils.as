package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.valueObjects.EnvironmentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	[Event(name="ENV_READ_COMPLETED", type="flash.events.Event")]
	public class EnvironmentUtils extends EventDispatcher
	{
		public static const ENV_READ_COMPLETED:String = "ENV_READ_COMPLETED";
		
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var isErrorClose:Boolean;
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
				
				customInfo = new NativeProcessStartupInfo();
				customInfo.executable = new File("c:\\Windows\\System32\\cmd.exe");
				
				customInfo.arguments = new <String>["/c", "set"];
				startShell(true);
			}
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				
				// @note
				// for some strange reason all the standard output turns to standard error output by git command line.
				// to have them dictate and continue the native process (without terminating by assuming as an error)
				// let's listen standard errors to shellData method only
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
				
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess.start(customInfo);
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
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array;
			var isFatal:Boolean;
			
			match = data.match(/fatal: .*/);
			if (match)
			{
				isErrorClose = true;
			}
			else if (data != "")
			{
				environmentData += data + "\r\n";
			}
		}
		
		private function shellError(e:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				var syntaxMatch:Array;
				var generalMatch:Array;
				var initMatch:Array;
				var hideDebug:Boolean;
				
				syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) error: (.*).*/);
				if (syntaxMatch)
				{
					
				}
				
				generalMatch = data.match(/(.*?): error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					
				}
				
				isErrorClose = true;
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				startShell(false);
				
				// parse
				if (environmentData != "")
				{
					_environments = new EnvironmentVO();
					Parser.parseEnvironmentFrom(environmentData, _environments);
				}
				
				// pass completion
				this.dispatchEvent(new Event(ENV_READ_COMPLETED));
			}
		}
	}
}