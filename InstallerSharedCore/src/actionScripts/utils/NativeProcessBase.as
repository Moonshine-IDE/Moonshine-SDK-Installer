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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.valueObjects.HelperConstants;
	
	public class NativeProcessBase extends EventDispatcher
	{
		protected var nativeProcess:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		protected function get running():Boolean
		{
			return (nativeProcess && nativeProcess.running);
		}
		
		public function dispose():void
		{
			removeNativeProcessEventListeners();
			stop();
			
			nativeProcess = null;
			nativeProcessStartupInfo = null;
		}
		
		public function start(args:Vector.<String>, buildDirectory:File=null):void
		{
			if (running)
			{
				//warning("Build is running. Wait for finish...");
				return;
			}
			
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcess = new NativeProcess();
			
			if (HelperConstants.IS_MACOS)
			{
				// we want one liner command on macOS
				// unlike on Windows
				args = new <String>["-c", args.join(" ")];
			}
			else
			{
				args.unshift("/c");
			}
			
			nativeProcessStartupInfo.executable = HelperConstants.IS_MACOS ? new File("/bin/bash") : new File("c:\\Windows\\System32\\cmd.exe");
			nativeProcessStartupInfo.arguments = args;
			if (buildDirectory) nativeProcessStartupInfo.workingDirectory = buildDirectory;
			
			addNativeProcessEventListeners();
			nativeProcess.start(nativeProcessStartupInfo);
		}
		
		public function stop(forceStop:Boolean = false):void
		{
			if (running || forceStop)
			{
				nativeProcess.exit(forceStop);
			}
		}
		
		protected function stopConsoleBuildHandler(event:Event):void
		{
			
		}
		
		protected function startConsoleBuildHandler(event:Event):void
		{
			
		}
		
		protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
		{
			trace(getDataFromBytes(nativeProcess.standardOutput));
		}
		
		protected function onNativeProcessIOError(event:IOErrorEvent):void
		{
			trace(event.text);
		}
		
		protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
		{
			trace(getDataFromBytes(nativeProcess.standardError));
		}
		
		protected function onNativeProcessStandardInputClose(event:Event):void
		{
			
		}
		
		protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			removeNativeProcessEventListeners();
		}
		
		protected function getDataFromBytes(data:IDataInput):String
		{
			return data.readUTFBytes(data.bytesAvailable);
		}
		
		protected function addNativeProcessEventListeners():void
		{
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
			nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, onNativeProcessStandardInputClose);
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
		}
		
		protected function removeNativeProcessEventListeners():void
		{
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onNativeProcessStandardOutputData);
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onNativeProcessStandardErrorData);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onNativeProcessIOError);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, onNativeProcessIOError);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onNativeProcessIOError);
			nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, onNativeProcessExit);
		}
	}
}
