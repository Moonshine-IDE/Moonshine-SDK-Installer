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
package actionScripts.managers
{
	import flash.net.SharedObject;
	
	import actionScripts.utils.FileUtils;
	import actionScripts.valueObjects.HelperConstants;

	public class CookieManager
	{
		private static var instance:CookieManager;
		
		private var cookie:SharedObject;
		
		public static function getInstance():CookieManager
		{	
			if (!instance) instance = new CookieManager();
			return instance;
		}
		
		public function loadLocalStorage():void
		{
			cookie = SharedObject.getLocal(HelperConstants.INSTALLER_COOKIE);
			
			// look for custom Windows path
			if (cookie.data.hasOwnProperty('customWindowsPath'))
			{
				if (FileUtils.isPathExists(cookie.data.customWindowsPath))
				{
					HelperConstants.CUSTOM_PATH_SDK_WINDOWS = cookie.data.customWindowsPath;
					HelperConstants.IS_CUSTOM_WINDOWS_PATH = (HelperConstants.CUSTOM_PATH_SDK_WINDOWS != "");
				}
			}
		}
		
		public function setWindowsCustomPath(value:String):void
		{
			cookie.data["customWindowsPath"] = value;
			cookie.flush();
		}
	}
}