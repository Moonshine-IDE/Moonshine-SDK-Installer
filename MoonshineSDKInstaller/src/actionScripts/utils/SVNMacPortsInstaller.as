package actionScripts.utils
{
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;

	import components.HelperInstaller;

	import flash.desktop.NativeProcess;

	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;

	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;

	import spark.components.Alert;

	public class SVNMacPortsInstaller extends EventDispatcher
	{
		public static const EVENT_INSTALL_COMPLETE:String = "svnMacPortsInstallCompletes";
		public static const EVENT_INSTALL_TERMINATES:String = "svnMacPortsInstallTerminates";
		public static const EVENT_INSTALL_PROGRESS:String = "svnMacPortsInstallationProgress";

		private var _message:String;
		public function get message():String
		{
			return _message;
		}

		private var customInfo:NativeProcessStartupInfo;
		private var customProcess:NativeProcess;

		public function SVNMacPortsInstaller()
		{
		}

		public function execute():void
		{
			var macPort:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_MACPORTS);
			var svn:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);

			if (!HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_MACPORTS, macPort.installToPath, macPort.pathValidation))
			{
				var errorMessage:String = "Subversion requires MacPorts to be installed.\nPlease install MacPorts separately.\nInstallation terminates.";
				Alert.show(errorMessage, "!Error");
				_message = errorMessage;
				dispatchEvent(new Event(EVENT_INSTALL_TERMINATES));
				return;
			}

			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			_message = "Subversion installation in-progress. Please wait.";
			dispatchEvent(new Event(EVENT_INSTALL_PROGRESS));

			var command:String = "do shell script \"sudo "+ macPort.installToPath +"/port -N install subversion\" with administrator privileges";
			customInfo.arguments = Vector.<String>(["-e", command]);
			customProcess = new NativeProcess();
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
				_message = output.readUTFBytes(output.bytesAvailable).toLowerCase();

				startShell(false);
				dispatchEvent(new Event(EVENT_INSTALL_TERMINATES));
			}
		}

		private function shellExit(event:NativeProcessExitEvent):void
		{
			if (customProcess)
			{
				startShell(false);
				_message = "Subversion installation completed successfully.";
				dispatchEvent(new Event(EVENT_INSTALL_COMPLETE));
			}
		}

		private function shellData(event:ProgressEvent):void
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			_message = output.readUTFBytes(output.bytesAvailable);

			dispatchEvent(new Event(EVENT_INSTALL_PROGRESS));
		}
	}
}
