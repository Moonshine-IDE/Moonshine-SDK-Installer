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

public class Constants
{

	//--------------------------------------------------------------------------
	//
	//    Class Constants
	//
	//--------------------------------------------------------------------------
	
	public static const APACHE_FLEX_URL:String = "https://flex.apache.org/";
	
	public static const ARCHIVE_EXTENSION_MAC:String = ".tar.gz";
	public static const ARCHIVE_EXTENSION_WIN:String = ".zip";
	
	public static const APPLICATION_EXTENSION_MAC:String = ".dmg";
	public static const APPLICATION_EXTENSION_WIN:String = ".exe";
	public static const APPLICATION_EXTENSION_LINUX:String = ".deb";
	
	public static const CONFIG_XML_NAME:String = "installer/sdk-installer-config-4.0.xml";
	public static const DISCLAIMER_PATH:String = "about-binaries.html";
	public static const INSTALLER_TRACK_SUCCESS:String = "track-installer.html";
	public static const INSTALLER_TRACK_FAILURE:String = "track-installer.html?failure=true";
	
	
	public static const SDK_BINARY_FILE_NAME_PREFIX:String = "apache-flex-sdk-";
	
	public static const URL_PREFIX:String = "http://";
	public static const FILE_PREFIX:String = "file://";
    public static const HTTPS_PREFIX:String = "https://";
	
	public static const SOURCEFORGE_DL_URL:String = ".dl.sourceforge.net/project/";
	public static const SOURCEFORGE_DOWNLOAD_URL:String = "http://downloads.sourceforge.net/project/" +
		"";
	
	//--------------------------------------------------------------------------
	//
	//    Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    instance
	//----------------------------------
	
	private static var _instance:Constants;
	
	public static function get instance():Constants
	{
		if (!_instance)
			_instance = new Constants(new SE());
		
		return _instance;
	}
	
	//--------------------------------------------------------------------------
	//
	//    Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Constants(se:SE) {}
	
}
}

class SE {}