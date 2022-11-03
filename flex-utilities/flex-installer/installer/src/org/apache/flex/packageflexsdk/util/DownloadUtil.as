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

package org.apache.flex.packageflexsdk.util
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;

	public class DownloadUtil
	{
		public static function download(url:String, completeFunction:Function, errorFunction:Function=null, progressFunction:Function=null):void
		{
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(url);
			req.idleTimeout = 60000;
			
			loader.dataFormat = URLLoaderDataFormat.BINARY; 
			loader.addEventListener(Event.COMPLETE, completeFunction,false,0,true);
			
			if (errorFunction != null)
			{
				loader.addEventListener(ErrorEvent.ERROR,errorFunction,false,0,true);
				loader.addEventListener(IOErrorEvent.IO_ERROR,errorFunction,false,0,true);
			}
			if(progressFunction != null)
			{
				loader.addEventListener(ProgressEvent.PROGRESS, progressFunction,false,0,true);
			}
			
			loader.load(req);
		}
		
		public static function invokeNativeProcess(args:Vector.<String>):void
		{
			var os:String = Capabilities.os.toLowerCase();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var cmdExe:File = (os.indexOf("win") > -1) ? new File("C:\\Windows\\System32\\cmd.exe") : null;
			if (cmdExe && cmdExe.exists)
			{
				info.executable = cmdExe;
				info.arguments = args;
			}
			var installProcess:NativeProcess = new NativeProcess();
			installProcess.start(info);
		}
		
		public static function executeFile(file:File,completeFunction:Function=null):void
		{
			var os:String = Capabilities.os.toLowerCase();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = file;
			var process:NativeProcess = new NativeProcess();
			if(completeFunction != null)
			{
				process.addEventListener(NativeProcessExitEvent.EXIT, completeFunction,false,0,true);
			}
			process.addEventListener(NativeProcessExitEvent.EXIT, handleNativeProcessComplete,false,0,true);
			process.start(info);
		}
		
		protected static function handleNativeProcessComplete(event:NativeProcessExitEvent):void
		{
			var process:NativeProcess = NativeProcess(event.target);
			process.closeInput();
			process.exit(true);
		}
	}
}