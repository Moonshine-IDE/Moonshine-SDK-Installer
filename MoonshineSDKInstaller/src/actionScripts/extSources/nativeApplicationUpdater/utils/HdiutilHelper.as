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
package actionScripts.extSources.nativeApplicationUpdater.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="error",type="flash.events.ErrorEvent")]
	
	public class HdiutilHelper extends EventDispatcher
	{
		private var dmg:File;
		
		private var result:Function;
		
		private var error:Function;
		
		private var hdiutilProcess:NativeProcess;
		
		public var mountPoint:String;
		
		public function HdiutilHelper(dmg:File)
		{
			this.dmg = dmg;
			this.result = result;
			this.error = error;
		}
		
		public function attach():void
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = new File("/usr/bin/hdiutil");
			
			var args:Vector.<String> = new Vector.<String>();
			args.push("attach", "-plist", dmg.nativePath);
			info.arguments = args;
			
			hdiutilProcess = new NativeProcess();
			hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
			hdiutilProcess.start(info);
		}
		
		private function hdiutilProcess_outputHandler(event:ProgressEvent):void
		{
			hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, hdiutilProcess_errorHandler);
			hdiutilProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, hdiutilProcess_outputHandler);
			hdiutilProcess.exit();
			
			// Storing current XML settings
			var xmlSettings:Object = XML.settings();
			// Setting required custom XML settings
			XML.setSettings(
				{
					ignoreWhitespace : true,
					ignoreProcessingInstructions : true,
					ignoreComments : true,
					prettyPrinting : false
				});
			
			var plist:XML = new XML(hdiutilProcess.standardOutput.readUTFBytes(event.bytesLoaded));
			var dicts:XMLList = plist.dict.array.dict;
			
			// INFO: for some reason E4X didn't work
			for each(var dict:XML in dicts)
			{
				for each(var element:XML in dict.elements())
				{
					if (element.name() == "key" && element.text() == "mount-point")
					{
						mountPoint = dict.child(element.childIndex() + 1);
						break;
					}
				}
			}
			
			// Reverting back original XML settings
			XML.setSettings(xmlSettings);
			
			if (mountPoint)
				dispatchEvent(new Event(Event.COMPLETE));
			else
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Couldn't find mount point!"));
		}
		
		private function hdiutilProcess_errorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, event.text, event.errorID));
		}
	}
}