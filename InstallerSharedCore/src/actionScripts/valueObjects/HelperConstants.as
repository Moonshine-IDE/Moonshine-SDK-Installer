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
package actionScripts.valueObjects
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	
	import actionScripts.utils.HelperUtils;
	
	[Bindable] public class HelperConstants
	{
		[Embed(source="/helperResources/images/bg_listDivider.png")]
		public static const BG_LIST_DIVIDER:Class;
		[Embed(source="/helperResources/images/bg_listDivider_white.png")]
		public static const BG_LIST_DIVIDER_WHITE:Class;
		
		public static const SUCCESS:String = "success";
		public static const ERROR:String = "error";
		public static const WARNING:String = "warning";
		public static const START:String = "start";
		public static const MOONSHINE_NOTIFIER_FILE_NAME:String = ".MoonshineHelperNewUpdate.xml";
		public static const INSTALLER_COOKIE:String = "moonshine-installer-local";
		public static const DEFAULT_SDK_FOLDER_NAME:String = "MoonshineSDKs";
		public static const HAXE_MAC_SYMLINK_COMMANDS:Array = [
			"ln -s -F -f $NEKO_HOME/libneko.dylib $HAXE_HOME/libneko.dylib",
			"ln -s -F -f $NEKO_HOME/libneko.2.dylib $HAXE_HOME/libneko.2.dylib",
			"ln -s -F -f $NEKO_HOME/libneko.2.3.0.dylib $HAXE_HOME/libneko.2.3.0.dylib",
			"ln -s -F -f $NEKO_HOME/std.ndll $HAXE_HOME/std.ndll",
			"ln -s -F -f $NEKO_HOME/mod_neko2.ndll $HAXE_HOME/mod_neko2.ndll",
			"ln -s -F -f $NEKO_HOME/mysql.ndll $HAXE_HOME/mysql.ndll",
			"ln -s -F -f $NEKO_HOME/regexp.ndll $HAXE_HOME/regexp.ndll",
			"ln -s -F -f $NEKO_HOME/mysql5.ndll $HAXE_HOME/mysql5.ndll",
			"ln -s -F -f $NEKO_HOME/zlib.ndll $HAXE_HOME/zlib.ndll",
			"ln -s -F -f $NEKO_HOME/sqlite.ndll $HAXE_HOME/sqlite.ndll",
			"ln -s -F -f $NEKO_HOME/mod_tora2.ndll $HAXE_HOME/mod_tora2.ndll",
			"ln -s -F -f $NEKO_HOME/ui.ndll $HAXE_HOME/ui.ndll",
			"ln -s -F -f $NEKO_HOME/ssl.ndll $HAXE_HOME/ssl.ndll"
		];
		public static const HAXE_WIN_SYMLINK_COMMANDS:Array = [
			"mklink /H $NEKO_HOME/std.ndll $HAXE_HOME/std.ndll",
			"mklink /H $NEKO_HOME/mod_neko2.ndll $HAXE_HOME/mod_neko2.ndll",
			"mklink /H $NEKO_HOME/mysql.ndll $HAXE_HOME/mysql.ndll",
			"mklink /H $NEKO_HOME/regexp.ndll $HAXE_HOME/regexp.ndll",
			"mklink /H $NEKO_HOME/mysql5.ndll $HAXE_HOME/mysql5.ndll",
			"mklink /H $NEKO_HOME/zlib.ndll $HAXE_HOME/zlib.ndll",
			"mklink /H $NEKO_HOME/sqlite.ndll $HAXE_HOME/sqlite.ndll",
			"mklink /H $NEKO_HOME/mod_tora2.ndll $HAXE_HOME/mod_tora2.ndll",
			"mklink /H $NEKO_HOME/ui.ndll $HAXE_HOME/ui.ndll",
			"mklink /H $NEKO_HOME/ssl.ndll $HAXE_HOME/ssl.ndll"
		];
		
		public static var IS_MACOS:Boolean = !NativeApplication.supportsSystemTrayIcon;
		public static var IS_RUNNING_IN_MOON:Boolean;
		public static var IS_INSTALLER_READY:Boolean;
		public static var DEFAULT_INSTALLATION_PATH:File;
		public static var CONFIG_ADOBE_AIR_VERSION:String;
		public static var CONFIG_HARMAN_AIR_VERSION:String;
		public static var CONFIG_HARMAN_AIR_OBJECT:Object;
		public static var WINDOWS_64BIT_DOWNLOAD_DIRECTORY:String;
		public static var INSTALLER_UPDATE_CHECK_URL:String;
		public static var CUSTOM_PATH_SDK_WINDOWS:String;
		public static var IS_CUSTOM_WINDOWS_PATH:Boolean;
		public static var IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH:Boolean;
		public static var IS_DETECTION_IN_PROCESS:Boolean;
		public static var SYSTEM_ARCH:String;
		
		public static function get HELPER_STORAGE():File
		{
			if (IS_MACOS) 
			{
				// on sandbox File.userDirectory returns an strage path, i.e.
				// /Users/$user/Library/Containers/com.moonshine-ide/Data
				// thus, we need to determine more practical path out of it
				DEFAULT_INSTALLATION_PATH = HelperUtils.getMacOSDownloadsDirectory();
				return DEFAULT_INSTALLATION_PATH;
			}
			
			return File.userDirectory.resolvePath("AppData/Roaming/net.prominic.MoonshineSDKInstaller/Local Store");
		}
	}
}