////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.utils.IDataInput;
	
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import moonshine.events.HelperEvent;

	[Event(name="ENV_READ_COMPLETED", type="moonshine.events.HelperEvent")]
	[Event(name="ENV_READ_ERROR", type="moonshine.events.HelperEvent")]
	public class JavaVersionReader extends NativeProcessBase
	{
		public static const ENV_READ_COMPLETED:String = "ENV_READ_COMPLETED";
		public static const ENV_READ_ERROR:String = "ENV_READ_ERROR";
		
		public var component:ComponentVO;
		
		private var errorCloseData:String;
		private var outputData:String = "";
		private var onComplete:Function;
		
		public function readVersion(javaPath:String=null, onComplete:Function=null):void
		{
			if (!FileUtils.isPathExists(javaPath))
			{
				this.dispatchEvent(new HelperEvent(ENV_READ_ERROR, "Invalid Java Path"));
				return;
			}
			
			this.onComplete = onComplete;
			
			var tmpArgs:Vector.<String> = javaPath ? 
				new <String>[HelperUtils.getEncodedForShell(javaPath +"/bin/java"), HelperUtils.getEncodedForShell("-version")] :
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
				onComplete = null;
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
			if (onComplete != null)
			{
				onComplete(version);
			}
		}
	}
}