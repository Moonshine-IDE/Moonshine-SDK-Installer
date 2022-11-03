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
	
	import actionScripts.valueObjects.EnvironmentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import moonshine.events.HelperEvent;
	
	[Event(name="ENV_READ_COMPLETED", type="moonshine.events.HelperEvent")]
	[Event(name="ENV_READ_ERROR", type="moonshine.events.HelperEvent")]
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