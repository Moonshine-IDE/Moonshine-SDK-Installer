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
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import spark.components.Alert;
	
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	public class LinkVerifier extends NativeProcess
	{
		private var customProcess:NativeProcess;
		private var resultHandler:Function;
		private var component:ComponentVO;
		private var isSuccessOrError:Boolean;
		
		/**
		 * resultHandler --> BOOL, ComponentVO
		 * Example,
		 * function myResultHandler(success:Boolean, component:ComponentVO)
		 */
		public function LinkVerifier(component:ComponentVO, 
									 resultHandler:Function, 
									 directURL:String=null)
		{
			super();
			
			this.resultHandler = resultHandler;
			this.component = component;
			
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.executable = HelperConstants.IS_WINDOWS ? 
				new File("c:\\Windows\\System32\\cmd.exe") :
				File.documentsDirectory.resolvePath("/bin/bash");
			
			var command:String = "curl --head --fail "+ (directURL ? directURL : component.downloadURL);
			if (HelperConstants.IS_WINDOWS)
			{
				npInfo.arguments = Vector.<String>(["/c", command]);
			}
			else
			{
				npInfo.arguments = Vector.<String>(["-c", command]);
			}
			
			startShell(true);
			customProcess.start(npInfo);
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
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
			}
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			isSuccessOrError = true;

			Alert.show("DATA:\n" + data);
			
			relayResult(true);
		}
		
		private function shellError(event:ProgressEvent):void
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				isSuccessOrError = true;
				Alert.show("ERROR:\n" + data);

				/*if (data.match(/certificate/))
				{
					// any certificate related error treat that as Okay
					relayResult(true);
				}
				else
				{
					Alert.show("Link verification failed:\n"+ data, "Error!");
					relayResult(false);
				}*/

				dispose();
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				Alert.show("EXIT:");
				// in case of invalid link process doesn't 
				// returns anything either as data or error.
				// testing by a flag help to understand to
				// verify invalid link in that case
				if (!isSuccessOrError)
				{
					relayResult(false);
				}
				
				dispose();
			}
		}
		
		private function relayResult(value:Boolean):void
		{
			if (resultHandler != null) 
				resultHandler(value, component);
		}
		
		private function dispose():void
		{
			startShell(false);
			
			resultHandler = null;
			component = null;
			isSuccessOrError = true;
		}
	}
}