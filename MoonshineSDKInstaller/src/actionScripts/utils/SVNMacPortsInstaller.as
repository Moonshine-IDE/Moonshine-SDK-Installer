////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import moonshine.haxeScripts.valueObjects.ComponentVO;

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
				var errorMessage:String = "Subversion requires MacPorts for installation.\nPlease install MacPorts separately.";
				Alert.OK_LABEL = "OK";
				Alert.show(errorMessage, "Error!");
				_message = errorMessage;
				dispatchEvent(new Event(EVENT_INSTALL_TERMINATES));
				return;
			}

			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = File.documentsDirectory.resolvePath("/usr/bin/osascript");

			_message = "Subversion installation in-progress. Please wait.";
			dispatchEvent(new Event(EVENT_INSTALL_PROGRESS));

			var command:String = "do shell script \"sudo "+ macPort.installToPath +"/port -N install subversion\" with prompt \"Moonshine SDK Installer requires admin privileges to install Subversion with MacPorts.\" with administrator privileges";
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
