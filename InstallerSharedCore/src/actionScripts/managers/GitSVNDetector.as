package actionScripts.managers
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	
	import mx.events.CloseEvent;
	
	import spark.components.Alert;
	
	import actionScripts.valueObjects.HelperConstants;

	public class GitSVNDetector
	{
		private static const XCODE_PATH_DECTECTION:String = "xcodePathDectection";
		private static const XCODE_COMLINE_INSTALL:String = "xcodeCommandLineToolInstall";
		private static const GIT_AVAIL_DECTECTION:String = "gitAvailableDectection";
		
		private static var instance:GitSVNDetector;
		
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var isErrorClose:Boolean;
		private var presentRunningQueue:Object;
		private var onCompletion:Function;
		private var pollingTimer:Timer;
		private var installerCompletion:Function;
		
		public static function getInstance():GitSVNDetector
		{	
			if (!instance) instance = new GitSVNDetector();
			return instance;
		}
		
		public function testGitSVNmacOS(onCompletion:Function):void
		{
			if (onCompletion == null)
			{
				throw new Error("Completion function is required field.");
				return;
			}
			
			this.onCompletion = onCompletion;
			if (customProcess) startShell(false);
			if (HelperConstants.IS_MACOS)
			{
				queue.push({com:'xcode-select -p', type:XCODE_PATH_DECTECTION});
			}
			else
			{
				
			}
			
			customInfo = renewProcessInfo();
			startShell(true);
			flush();
		}
		
		public function installXCodeCommandLine(onCompletion:Function=null):void
		{
			this.onCompletion = onCompletion;
			Alert.show("Moonshine SDK Installer will now install Command Line Tools for Git support. This will open an external installer.", "Confirm!", Alert.OK|Alert.CANCEL, null, onConfirmationInstall);
			
			/*
			 * @local
			 */
			function onConfirmationInstall(event:CloseEvent):void
			{
				if (event.detail == Alert.OK)
				{
					onCompletion(null, HelperConstants.START);
					queue.push({com:'xcode-select --install', type:XCODE_COMLINE_INSTALL});
					
					customInfo = renewProcessInfo();
					startShell(true);
					flush();
				}
				else
				{
					onCompletion(null, HelperConstants.ERROR);
				}
			}
		}
		
		private function flush():void
		{
			if (queue.length == 0)
			{
				startShell(false);
				return;
			}
			
			var tmpArr:Array = queue[0].com.split("&&");
			
			if (!HelperConstants.IS_MACOS) tmpArr.unshift("/c");
			else tmpArr.unshift("-c");
			customInfo.arguments = Vector.<String>(tmpArr);
			
			presentRunningQueue = queue.shift();
			customProcess.start(customInfo);
		}
		
		private function renewProcessInfo():NativeProcessStartupInfo
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = !HelperConstants.IS_MACOS ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			
			return customInfo;
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
				presentRunningQueue = null;
				isErrorClose = false;
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
				startShell(false);
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				if (!isErrorClose) 
				{
					flush();
				}
			}
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array;
			var isFatal:Boolean;
			
			match = data.match(/fatal: .*/);
			if (match) isFatal = true;
			
			switch(presentRunningQueue.type)
			{
				case XCODE_PATH_DECTECTION:
				{
					data = data.replace("\n", "");
					match = data.toLowerCase().match(/xcode.app\/contents\/developer/);
					if (match)
					{
						if (new File(data).exists) 
						{
							this.onCompletion(data);
							return;
						}
					}
					
					match = data.toLowerCase().match(/commandlinetools/);
					if (match)
					{
						if (new File(data).exists) 
						{
							this.onCompletion(data);
							return;
						}
					}
					
					// even if not found
					this.onCompletion(null);
					break;
				}
				case XCODE_COMLINE_INSTALL:
				{
					match = data.match(/error: command line tools are already installed.*/);
					if (match)
					{
						this.onCompletion(null, HelperConstants.SUCCESS);
					}
					else if (data.match(/.*install requested.*/))
					{
						startPolling();
					}
				}
			}
			
			if (isFatal)
			{
				startShell(false);
				return;
			}
		}
		
		private function startPolling():void
		{
			stopPolling();
			
			installerCompletion = onCompletion;
			
			pollingTimer = new Timer(10000);
			pollingTimer.addEventListener(TimerEvent.TIMER, onPollTimerTick);
			pollingTimer.start();
		}
		
		private function stopPolling():void
		{
			if (pollingTimer && pollingTimer.running)
			{
				pollingTimer.stop();
				pollingTimer.removeEventListener(TimerEvent.TIMER, onPollTimerTick);
				pollingTimer = null;
			}
		}
		
		private function onPollTimerTick(event:TimerEvent):void
		{
			testGitSVNmacOS(function(value:String):void
			{
				if (value) 
				{
					stopPolling();
					installerCompletion(value, HelperConstants.SUCCESS);
				}
			});
		}
	}
}