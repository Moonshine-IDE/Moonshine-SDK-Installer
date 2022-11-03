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

package org.apache.flex.utilities.common
{

import flash.system.Capabilities;

import mx.controls.Alert;

public class Tools
{

	//--------------------------------------------------------------------------
	//
	//    Class constants
	//
	//--------------------------------------------------------------------------
	
	private static const PLATFORM_MAC:String = "Mac";
	private static const PLATFORM_WIN:String = "Windows";
	private static const PLATFORM_LINUX:String = "Linux";
	
	//--------------------------------------------------------------------------
	//
	//    Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    instance
	//----------------------------------
	
	private static var _instance:Tools;
	
	public static function get instance():Tools
	{
		if (!_instance)
			_instance = new Tools(new SE());
		
		return _instance;
	}
	
	//--------------------------------------------------------------------------
	//
	//    Class methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    warnPlatformNotSupported
	//----------------------------------
	
	public static function getApplicationExtension():String
	{
		var platform:String = Capabilities.os.split(" ")[0];
		
		if (platform == PLATFORM_WIN)
			return Constants.APPLICATION_EXTENSION_WIN;
		else if (platform == PLATFORM_MAC)
			return Constants.APPLICATION_EXTENSION_MAC;
		else if (platform == PLATFORM_LINUX)
			return Constants.APPLICATION_EXTENSION_LINUX;
		else
			throw(new Error("PlatformNotSupported"));
	}
	
	//--------------------------------------------------------------------------
	//
	//    Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Tools(se:SE) {}
	
}
}

class SE {}
