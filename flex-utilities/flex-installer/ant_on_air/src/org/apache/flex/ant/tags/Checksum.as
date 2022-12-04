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
    import org.apache.flex.crypto.MD5Stream;
    
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    
    import mx.utils.StringUtil;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Checksum extends TaskHandler
    {
		private static var DEFAULT_READBUFFER_SIZE:int = 2 * 1024 * 1024;
		
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["checksum"] = Checksum;
        }
        
        public function Checksum()
        {
            super();
        }
        
        private function get file():String
        {
            return getAttributeValue("@file");
        }
        
        private function get toDir():String
        {
            return getNullOrAttributeValue("@todir");
        }
        
        private function get fileExt():String
        {
            var val:String = getNullOrAttributeValue("@fileext");
            return val == null ? ".md5" : val;
        }
        
        private function get property():String
        {
            return getNullOrAttributeValue("@property");
        }
        
        private function get verifyproperty():String
        {
            return getNullOrAttributeValue("@verifyproperty");
        }
        
        private function get readbuffersize():int
        {
            var val:String = getNullOrAttributeValue("@readbuffersize");
            return val == null ? DEFAULT_READBUFFER_SIZE : int(val);
        }
        
        private var md5:MD5Stream;
        private var fs:FileStream;
        private var totalLength:int;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            try {
                var f:File = File.applicationDirectory.resolvePath(this.file);
            } 
            catch (e:Error)
            {
                ant.output(this.file);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                dispatchEvent(new Event(Event.COMPLETE));
                return true;							
            }
            
            if (!f.exists)
                return true;
            
            fs = new FileStream();
            fs.open(f, FileMode.READ);
            totalLength = fs.bytesAvailable;
            md5 = new MD5Stream();
            md5.resetFields();
            return getSum();
        }
        
        private function getSum():Boolean
        {
            if (fs.bytesAvailable < DEFAULT_READBUFFER_SIZE)
            {
                sumComplete();
                return true;
            }
            md5.update(fs, DEFAULT_READBUFFER_SIZE);
            ant.functionToCall = getSum;
            ant.progressClass = this;
            ant.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 
                fs.position, fs.position + fs.bytesAvailable));
            return false;
        }
        
        private var sum:String;
        
        private function sumComplete():void
        {
            sum = md5.complete(fs, totalLength);
            fs.close();
            if (verifyproperty && property)
            {
                if (sum == property)
                    context[verifyproperty] = "true";
                else
                    context[verifyproperty] = "false";
            }
            else if (!toDir && property)
            {
                context[property] = sum;				
            }
            else
            {
                var sumFile:File = getSumFile();
                if (sumFile)
                {
                    var fs:FileStream = new FileStream();
                    if (verifyproperty)
                    {
                        fs.open(sumFile, FileMode.READ);
                        var expected:String = fs.readUTFBytes(fs.bytesAvailable);
                        expected = StringUtil.trim(expected);
                        fs.close();                
                        if (sum != expected)
                            context[verifyproperty != null ? verifyproperty : property] = "false";
                        else
                            context[verifyproperty != null ? verifyproperty : property] = "true";
                    }
                    else
                    {
                        fs.open(sumFile, FileMode.WRITE);
                        fs.writeUTFBytes(sum);
                        fs.close();                
                    }
                }            
            }
            ant.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 
                totalLength, totalLength));
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function getSumFile():File
        {
            try {
                var sumFile:File;
				if (toDir)
					sumFile = File.applicationDirectory.resolvePath(toDir);
				else
				{
					var f:File = File.applicationDirectory.resolvePath(this.file);
					sumFile = f.parent;
				}
            } 
            catch (e:Error)
            {
                ant.output(toDir);
                ant.output(e.message);
                if (failonerror)
				{					
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}				
                return null;							
            }
            
            if (sumFile.isDirectory)
            {
                var fileName:String = file + fileExt;
                var c:int = fileName.indexOf("?");
                if (c != -1)
                    fileName = fileName.substring(0, c);
                c = fileName.lastIndexOf("/");
                if (c != -1)
                    fileName = fileName.substr(c + 1);
                sumFile = sumFile.resolvePath(fileName);
            }
            return sumFile;
        }
    }
}