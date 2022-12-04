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
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	import moonshine.haxeScripts.valueObjects.ComponentVO;

	public class LinkVerifierAS extends NativeProcess
	{
		private var loader:URLLoader;
		private var resultHandler:Function;
		private var component:ComponentVO;

		/**
		 * resultHandler --> BOOL, ComponentVO
		 * Example,
		 * function myResultHandler(success:Boolean, component:ComponentVO)
		 */
		public function LinkVerifierAS(component:ComponentVO,
									   resultHandler:Function,
									   directURL:String=null)
		{
			super();
			
			this.resultHandler = resultHandler;
			this.component = component;

			loader = new URLLoader();
			configureListeners(loader);

			var request:URLRequest = new URLRequest(directURL ? directURL : component.downloadURL);
			request.method = URLRequestMethod.HEAD;
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}

		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}

		private function removeListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
			dispatcher.removeEventListener(Event.OPEN, openHandler);
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}

		private function completeHandler(event:Event):void
		{
			relayResult(true);
		}

		private function openHandler(event:Event):void
		{
			trace("openHandler: " + event);
		}

		private function progressHandler(event:ProgressEvent):void
		{
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + event.text);
			relayResult(false);
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			trace("httpStatusHandler: " + event.status);
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace("ioErrorHandler: " + event.text);
			relayResult(false);
		}
		
		private function relayResult(value:Boolean):void
		{
			if (resultHandler != null) 
				resultHandler(value, component);

			dispose();
		}
		
		private function dispose():void
		{
			removeListeners(loader);
			resultHandler = null;
			component = null;
			loader = null;
		}
	}
}