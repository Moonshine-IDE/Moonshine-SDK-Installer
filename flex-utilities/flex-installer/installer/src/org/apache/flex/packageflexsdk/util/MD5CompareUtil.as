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

package org.apache.flex.packageflexsdk.util
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.OutputProgressEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import org.apache.flex.crypto.MD5Stream;
import org.apache.flex.utilities.common.Constants;

[Event(name="progress", type="flash.events.ProgressEvent")]

public class MD5CompareUtil extends EventDispatcher
{

	//--------------------------------------------------------------------------
	//
	//    Class constants
	//
	//--------------------------------------------------------------------------
	
	public static const MD5_DOMAIN:String = "https://www.apache.org/dist/";
	
	public static const MD5_POSTFIX:String = ".md5";
	
    public static const CHUNK_SIZE:int = 2 * 1024 * 1024;
    
	//--------------------------------------------------------------------------
	//
	//    Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    instance
	//----------------------------------
	
	private static var _instance:MD5CompareUtil;
	
	public static function get instance():MD5CompareUtil
	{
		if (!_instance)
			_instance = new MD5CompareUtil(new SE());
		
		return _instance;
	}
	
	//--------------------------------------------------------------------------
	//
	//    Constructor
	//
	//--------------------------------------------------------------------------
	
	public function MD5CompareUtil(se:SE) {}
		
	//--------------------------------------------------------------------------
	//
	//    Variables
	//
	//--------------------------------------------------------------------------
	
	private var _callback:Function;
	
	private var _file:File;
	
	private var _fileStream:FileStream;
	
	private var _remoteMD5Value:String;
	
	private var _md5Stream:MD5Stream;
	
	private var _urlLoader:URLLoader;
	
	//--------------------------------------------------------------------------
	//
	//    Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    errorMessage
	//----------------------------------
	
	private var _errorMessage:String = "";

	public function get errorMessage():String
	{
		return _errorMessage;
	}

	//----------------------------------
	//    errorOccurred
	//----------------------------------
	
	private var _errorOccurred:Boolean;

	public function get errorOccurred():Boolean
	{
		return _errorOccurred;
	}

	//----------------------------------
	//    fileIsVerified
	//----------------------------------
	
	private var _fileIsVerified:Boolean;

	public function get fileIsVerified():Boolean
	{
		return _fileIsVerified;
	}
	
	private var _validMD5:Boolean;

	public function get validMD5():Boolean
	{
		return _validMD5;
	}

	//--------------------------------------------------------------------------
	//
	//    Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    compareSignatures
	//----------------------------------
	
	private function compareSignatures():void
	{
		_md5Stream = new MD5Stream();
		
		_fileStream = new FileStream();
		_fileStream.readAhead = CHUNK_SIZE;
		_fileStream.addEventListener(Event.COMPLETE, fileStreamOpenHandler);
		_fileStream.addEventListener(ProgressEvent.PROGRESS, fileStreamOpenHandler);
		_fileStream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOpenHandler);
		_fileStream.openAsync(_file, FileMode.READ); 
	}
	
	//----------------------------------
	//    fileStreamOpenHandler
	//----------------------------------
	
	private function fileStreamOpenHandler(event:Event):void
	{
		if (event is ProgressEvent)
		{
			_md5Stream.update(_fileStream, Math.floor(_fileStream.bytesAvailable / 64) * 64);
			
			dispatchEvent(event.clone());
		}
		else
		{
			if (event.type == Event.COMPLETE)
			{
				_fileIsVerified = (_md5Stream.complete(_fileStream, _file.size) == _remoteMD5Value);
                _fileStream.close();
				
				removeEventListeners();
				_callback();
			}
		}
	}
	
	//----------------------------------
	//    urlLoaderResultHandler
	//----------------------------------
	
	private function urlLoaderResultHandler(event:Event):void
	{
		_errorOccurred = event is IOErrorEvent;
		
		if (!_errorOccurred)
		{
			_remoteMD5Value = String(_urlLoader.data);
			
			/** 
			 * We need only the first line; split for both Unix and Windows 
			 * style line delimiters
			 */
			_remoteMD5Value = _remoteMD5Value.split("\n")[0];
			_remoteMD5Value = _remoteMD5Value.split("\r")[0];
			
			// Valid MD5 hashes are 32 hexidecimal characters
			_validMD5 = (_remoteMD5Value.search(new RegExp("[a-fA-F0-9]{32}")) == 0);

			compareSignatures();
		}
		else
		{
			_errorMessage = String(IOErrorEvent(event).text);
		}
	}
	
	//----------------------------------
	//    verifyMD5
	//----------------------------------
	
	public function verifyMD5(localSDKZipFile:File, remoteSDKZipPath:String, 
							  onVerificationComplete:Function):void
	{
		_file = localSDKZipFile;
		
		_callback = onVerificationComplete;
		
		_urlLoader = new URLLoader();
		_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		_urlLoader.addEventListener(Event.COMPLETE, urlLoaderResultHandler);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderResultHandler);
		if (remoteSDKZipPath.substr(0, Constants.URL_PREFIX.length) != Constants.URL_PREFIX &&
			remoteSDKZipPath.substr(0, Constants.FILE_PREFIX.length) != Constants.FILE_PREFIX &&
			remoteSDKZipPath.search("http") != 0)
		{
			_urlLoader.load(new URLRequest(MD5_DOMAIN + remoteSDKZipPath + MD5_POSTFIX));
		}
		else
		{
			_urlLoader.load(new URLRequest(remoteSDKZipPath + MD5_POSTFIX));
		}
	}
	
	private function removeEventListeners():void
	{
		_fileStream.removeEventListener(Event.COMPLETE, fileStreamOpenHandler);
		_fileStream.removeEventListener(ProgressEvent.PROGRESS, fileStreamOpenHandler);
		_fileStream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, fileStreamOpenHandler);
		_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderResultHandler);
		_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderResultHandler);
	}
	
}
}

class SE {}
