package actionScripts.utils
{
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;

	import components.HelperInstaller;

	import flash.desktop.NativeProcess;

	import flash.desktop.NativeProcessStartupInfo;

	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;

	import spark.components.Alert;

	public class SVNMacPortsInstaller extends EventDispatcher
	{
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
				Alert.show("This requires MacPorts to be installed.\nPlease install MacPorts separately.\nInstallation terminates.", "!Error");
				return;
			}

			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			var command:String = "do shell script \"sudo "+ macPort.installToPath +"/port -N install subversion\" with administrator privileges";
			customInfo.arguments = Vector.<String>(["-e", command]);
			customProcess = new NativeProcess();
			//customInfo.workingDirectory = new File(svn.installToPath);
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
				//dispatchEvent(new GeneralEvent(EVENT_INSTALL_ERROR, data));
			}
		}

		private function shellExit(event:NativeProcessExitEvent):void
		{
			if (customProcess)
			{
				startShell(false);
				//dispatchEvent(new GeneralEvent(EVENT_INSTALL_COMPLETES));
			}
		}

		private function shellData(event:ProgressEvent):void
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			//dispatchEvent(new GeneralEvent(EVENT_INSTALL_OUTPUT, data));
			trace("stdOut: "+ data);
		}
	}
}
