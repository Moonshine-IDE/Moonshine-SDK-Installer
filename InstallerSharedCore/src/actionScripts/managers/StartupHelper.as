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
package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.Parser;
	import actionScripts.valueObjects.HelperConstants;
	
	import moonshine.events.HelperEvent;

	[Event(name="EVENT_CONFIG_LOADED", type="moonshine.events.HelperEvent")]
	[Event(name="EVENT_CONFIG_ERROR", type="moonshine.events.HelperEvent")]
	public class StartupHelper extends EventDispatcher
	{
		public static const EVENT_CONFIG_LOADED:String = "eventConfigLoaded";
		public static const EVENT_CONFIG_ERROR:String = "eventConfigError";

		private static var isLocalPathConfigured:Boolean;
		
		public static function setLocalPathConfig():void
		{
			if (isLocalPathConfigured) return;

			if (HelperConstants.IS_MACOS)
			{
				// for macOS ~/Downloads directory
				HelperConstants.DEFAULT_INSTALLATION_PATH = HelperUtils.getMacOSDownloadsDirectory();
			}
			else
			{
				// Windows download directory
				if (HelperConstants.CUSTOM_PATH_SDK_WINDOWS)
				{
					HelperConstants.DEFAULT_INSTALLATION_PATH = new File(HelperConstants.CUSTOM_PATH_SDK_WINDOWS);
				}
				else
				{
					// not sure about how network sharing case will return
					// thus a generic check let's be in place
					var tmpRootDirectories:Array = File.getRootDirectories();
					HelperConstants.DEFAULT_INSTALLATION_PATH = (tmpRootDirectories.length > 0) ? 
						tmpRootDirectories[0].resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME) : 
						File.userDirectory.resolvePath(HelperConstants.DEFAULT_SDK_FOLDER_NAME);
				}
				
				// determine if choosing custom sdk path is allow-able
				if ((!HelperConstants.CUSTOM_PATH_SDK_WINDOWS && !HelperConstants.DEFAULT_INSTALLATION_PATH.exists) || 
					(HelperConstants.CUSTOM_PATH_SDK_WINDOWS && !FileUtils.isPathExists(HelperConstants.CUSTOM_PATH_SDK_WINDOWS)))
				{
					HelperConstants.IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH = true;
				}
			}

			isLocalPathConfigured = true;
		}
		
		public function loadMoonshineConfig():void
		{
			var configFile:String = File.applicationDirectory.nativePath + "/helperResources/data/moonshineHelperConfig.xml";
			FileUtils.readFromFileAsync(new File(configFile), FileUtils.DATA_FORMAT_STRING, onMoonshineConfigLoaded, onMoonshineConfigError);
		}
		
		protected function onMoonshineConfigLoaded(value:Object):void
		{
			var config:XML = new XML(value);
			if (config) Parser.parseHelperConfig(config);
			
			dispatchEvent(new HelperEvent(EVENT_CONFIG_LOADED));
		}
		
		protected function onMoonshineConfigError(value:String):void
		{
			dispatchEvent(new HelperEvent(EVENT_CONFIG_ERROR, value));
		}
	}
}