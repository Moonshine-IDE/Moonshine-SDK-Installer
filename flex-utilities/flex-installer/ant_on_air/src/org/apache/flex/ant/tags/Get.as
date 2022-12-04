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
package org.apache.flex.ant.tags
{
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.LocalConnection;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.utils.ByteArray;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    import flash.net.URLStream;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Get extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["get"] = Get;
        }
        
        private static const DOWNLOADS_SOURCEFORGE_NET:String = "http://downloads.sourceforge.net/";
        private static const SOURCEFORGE_NET:String = "http://sourceforge.net/";
        private static const DL_SOURCEFORGE_NET:String = ".dl.sourceforge.net/";
        private static const USE_MIRROR:String = "use_mirror=";
        
        public function Get()
        {
            super();
        }
        
        private function get src():String
        {
            return getAttributeValue("@src");
        }
        
        private function get dest():String
        {
            return getAttributeValue("@dest");
        }
        
        private function get skipexisting():Boolean
        {
            return getAttributeValue("@skipexisting") == "true";
        }
        
		private function get ignoreerrors():Boolean
		{
			return getAttributeValue("@ignoreerrors") == "true";
		}
		
        private var urlStream:URLStream;
        
        private var lastProgress:ProgressEvent;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            // try forcing GC before each step
            try {
                var lc1:LocalConnection = new LocalConnection();
                var lc2:LocalConnection = new LocalConnection();
                
                lc1.connect("name");
                lc2.connect("name");
            }
            catch (error:Error)
            {
            }
            
            var destFile:File = getDestFile();
            if(destFile.exists)
            {
                if (skipexisting)
                {
                    return true;
                }
                //delete the file if it exists already
                destFile.deleteFile();
            }
            var s:String = ResourceManager.getInstance().getString('ant', 'GETTING');
            s = s.replace("%1", src);
            ant.output(ant.formatOutput("get", s));
            s = ResourceManager.getInstance().getString('ant', 'GETTO');
            s = s.replace("%1", getDestFile().nativePath);
            ant.output(ant.formatOutput("get", s));
            
            var actualSrc:String = src;
            var urlRequest:URLRequest = new URLRequest(actualSrc);
            urlRequest.followRedirects = false;
            urlRequest.manageCookies = false;
            urlRequest.userAgent = "Java";	// required to get sourceforge redirects to do the right thing
            urlStream = new URLStream();
            urlStream.load(urlRequest);
            urlStream.addEventListener(Event.COMPLETE, completeHandler);
            urlStream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, statusHandler);
            urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
            urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            return false;
        }
        
        private function statusHandler(event:HTTPStatusEvent):void
        {
            if (event.status >= 300 && event.status < 400)
            {
                // redirect response
                
                urlStream.close();
                
                // remove handlers from old request
                urlStream.removeEventListener(Event.COMPLETE, completeHandler);
                urlStream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, statusHandler);
                urlStream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
                urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
                urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                
                var newlocation:String;
                for each (var header:URLRequestHeader in event.responseHeaders)
                {
                    if (header.name == "Location")
                    {
                        newlocation = header.value;
                        break;
                    }
                }
                if (newlocation)
                {
                    var srcIndex:int = src.indexOf(DOWNLOADS_SOURCEFORGE_NET);
                    var sfIndex:int = newlocation.indexOf(SOURCEFORGE_NET);
                    var mirrorIndex:int = newlocation.indexOf(USE_MIRROR);
                    if (srcIndex == 0 && sfIndex == 0 && mirrorIndex != -1 && event.status == 307)
                    {
                        // SourceForge redirects AIR requests differently from Ant requests.
                        // We can't control some of the additional headers that are sent
                        // but that appears to make the difference.  Just pick out the
                        // mirror and use it against dl.sourceforge.net
                        var mirror:String = newlocation.substring(mirrorIndex + USE_MIRROR.length);
                        newlocation = "http://" + mirror + DL_SOURCEFORGE_NET;
                        newlocation += src.substring(DOWNLOADS_SOURCEFORGE_NET.length);
                    }
                    ant.output(ant.formatOutput("get", "Redirected to: " + newlocation));
                    var urlRequest:URLRequest = new URLRequest(newlocation);
                    var refHeader:URLRequestHeader = new URLRequestHeader("Referer", src);
                    urlRequest.requestHeaders.push(refHeader);
                    urlRequest.manageCookies = false;
                    urlRequest.followRedirects = false;
                    urlRequest.userAgent = "Java";	// required to get sourceforge redirects to do the right thing
                    urlStream = new URLStream();
                    urlStream.load(urlRequest);
                    urlStream.addEventListener(Event.COMPLETE, completeHandler);
                    urlStream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, statusHandler);
                    urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
                    urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
                    urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
                }
            }
        }
        
        private function ioErrorEventHandler(event:IOErrorEvent):void
        {
            if (lastProgress)
                ant.output("ioError at: " + lastProgress.bytesLoaded + " of " + lastProgress.bytesTotal);
            
            ant.output(event.toString());
			if (!ignoreerrors)
			{
				ant.project.failureMessage = ant.formatOutput("get", event.toString());
	            ant.project.status = false;
			}
            dispatchEvent(new Event(Event.COMPLETE));
            event.preventDefault();
			urlStream = null;
        }
        
        private function securityErrorHandler(event:SecurityErrorEvent):void
        {
            ant.output(event.toString());
			if (!ignoreerrors)
			{
				ant.project.failureMessage = ant.formatOutput("get", event.toString());
    	        ant.project.status = false;
			}
            dispatchEvent(new Event(Event.COMPLETE));
            event.preventDefault();
			urlStream = null;
        }
        
        private function progressHandler(event:ProgressEvent):void
        {
            var bytes:ByteArray = new ByteArray();
            urlStream.readBytes(bytes, 0, urlStream.bytesAvailable);
            var destFile:File = getDestFile();
            if (destFile)
            {
                var fs:FileStream = new FileStream();
                fs.open(destFile, FileMode.APPEND);
                fs.writeBytes(bytes);
                fs.close();
            }

            lastProgress = event;
            ant.progressClass = this;
            ant.dispatchEvent(event);
        }
        
        private function completeHandler(event:Event):void
        {
            dispatchEvent(new Event(Event.COMPLETE));
			urlStream = null;
        }
        
        private function getDestFile():File
        {
            try {
                var destFile:File = File.applicationDirectory.resolvePath(dest);
            } 
            catch (e:Error)
            {
                ant.output(dest);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = ant.formatOutput("get", e.message);
                    ant.project.status = false;
				}
                return null;							
            }
            
            if (destFile.isDirectory)
            {
                var fileName:String = src;
                var c:int = fileName.indexOf("?");
                if (c != -1)
                    fileName = fileName.substring(0, c);
                c = fileName.lastIndexOf("/");
                if (c != -1)
                    fileName = fileName.substr(c + 1);
                try {
                    destFile = destFile.resolvePath(fileName);
                } 
                catch (e:Error)
                {
                    ant.output(fileName);
                    ant.output(e.message);
                    if (failonerror)
					{
						ant.project.failureMessage = ant.formatOutput("get", e.message);						
                        ant.project.status = false;
					}
                    return null;							
                }
                
            }
            return destFile;
        }
    }
}