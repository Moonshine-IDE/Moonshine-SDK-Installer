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

package org.apache.flex.utilities.common
{

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

public class InternetUtil
{

	//--------------------------------------------------------------------------
	//
	//    Class properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    instance
	//----------------------------------
	
	private static var _instance:InternetUtil;
	
	public static function get instance():InternetUtil
	{
		if (!_instance)
			_instance = new InternetUtil(new SE());
		
		return _instance;
	}
	
	//--------------------------------------------------------------------------
	//
	//    Class methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    getTLDFromURL
	//----------------------------------
	
	public static function getTLDFromURL(url:String):String
	{
		var array:Array;
		
		var result:String = url;
		
		if (result.indexOf(Constants.URL_PREFIX) > -1)
			result = result.split("/")[2];

		array = result.split(".");
		array.shift();

		return array.join(".");
	}
	
	//--------------------------------------------------------------------------
	//
	//    Constructor
	//
	//--------------------------------------------------------------------------
	
	public function InternetUtil(se:SE) {}
		
	//--------------------------------------------------------------------------
	//
	//    Variables
	//
	//--------------------------------------------------------------------------
	
	private var _callback:Function;
	
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
	//    result
	//----------------------------------
	
	private var _result:String;
	
	public function get result():String
	{
		return _result;
	}
	
	//--------------------------------------------------------------------------
	//
	//    Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    fetchResultHandler
	//----------------------------------
	
	private function fetchResultHandler(event:Event):void
	{
		_errorOccurred = event is IOErrorEvent;
		
		if (!_errorOccurred)
			_result = _urlLoader.data;
		else
			_errorMessage = String(IOErrorEvent(event).text);
		
		_callback();
	}
	
	//----------------------------------
	//    fetch
	//----------------------------------
	
	public function fetch(fetchURL:String, fetchCompleteHandler:Function, args:String = null):void
	{
		_callback = fetchCompleteHandler;
		
		_errorMessage = "";
		_errorOccurred = false;
		_result = "";
		
		_urlLoader = new URLLoader();
		_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		_urlLoader.addEventListener(Event.COMPLETE, fetchResultHandler);
		_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, fetchResultHandler);
		_urlLoader.load(new URLRequest(fetchURL + ((args) ? "?" + args : "")));
	}
	
}
}

class SE {}