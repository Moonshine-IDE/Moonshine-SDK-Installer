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
	import moonshine.haxeScripts.valueObjects.ComponentVO;
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
			if (HelperConstants.IS_WINDOWS) findMoonshineProcessWindows();
			else sendUpdateNotificationToMoonshine();
		}
		
		private function onNotifierFileWriteError(value:String):void
		{
			Alert.show("Error notifying Moonshine-IDE.\n"+ value, "Error!");
		}
		
		private function toXML():XML
		{
			var root:XML = new XML(<root/>);
			var items:XML = new XML(<items/>);
			
			for each (var item:ComponentVO in model.components.array)
			{
				if (item.isAlreadyDownloaded)
				{
					var itemXml:XML = new XML(<item/>);
					itemXml.@id = item.id;
					itemXml.@type = item.id;
					
					var pathXML:XML = new XML(<path/>);
					pathXML.appendChild(item.installToPath);
					
					var validationXML:XML = new XML(<pathValidation/>);
					if (item.pathValidation) validationXML.appendChild(item.pathValidation.join(","));
					
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
				npInfo.executable = File.documentsDirectory.resolvePath( "/bin/bash" );
				arg.push('-c');
				arg.push('/usr/bin/osascript "'+ scpt.nativePath +'" ""');
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
			var data:String = StringUtil.trim(output.readUTFBytes(output.bytesAvailable));
			data = data.replace(/^\s*[\r\n]/gm, "");
			var paths:Array = data.split("\r");
			
			var searchString:String = "executablepath=";
			var pathIndex:int;
			paths.forEach(function(path:String, index:int, arr:Array):void {
				pathIndex = path.toLowerCase().indexOf(searchString);
				if (pathIndex != -1)
				{
					data = StringUtil.trim(path.substr(pathIndex + searchString.length, path.length));
					sendUpdateNotificationToMoonshine(data);
				}
			});
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