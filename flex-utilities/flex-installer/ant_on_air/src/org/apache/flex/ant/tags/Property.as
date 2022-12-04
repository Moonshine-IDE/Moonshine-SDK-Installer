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
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.system.Capabilities;
    import flash.utils.IDataInput;
    
    import mx.utils.StringUtil;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Property extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["property"] = Property;
        }
        
        public function Property()
        {
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            if (name && (value || location || refid) && !context.hasOwnProperty(name))
            {
                if (value)
                    context[name] = value;
                else if (refid)
                    context[name] = context[ant.project.refids[refid]];
                else
                    context[name] = location;
            }
            else if (fileName != null)
            {
                try {
                    var f:File = new File(fileName);
                } 
                catch (e:Error)
                {
                    ant.output(fileName);
                    ant.output(e.message);
                    if (failonerror)
					{
						ant.project.failureMessage = e.message;
                        ant.project.status = false;
					}
                    return true;							
                }
                
                if (f.exists)
                {
                    var fs:FileStream = new FileStream();
                    fs.open(f, FileMode.READ);
                    var data:String = fs.readUTFBytes(fs.bytesAvailable);
                    var propLines:Array = data.split("\n");
                    var collectingParts:Boolean;
                    var val:String;
                    var key:String;
                    for each (var line:String in propLines)
                    {
                        if (line.charAt(line.length - 1) == "\r")
                            line = line.substr(0, line.length - 1);
                        if (collectingParts)
                        {
                            if (line.charAt(line.length - 1) == "\\")
                                val += line.substr(0, line.length - 1);
                            else
                            {
                                collectingParts = false;
                                val += line;
                                val = StringUtil.trim(val);
                                val = val.replace(/\\n/g, "\n");
                                if (!context.hasOwnProperty(key))
                                    context[key] = ant.getValue(val, context);
                            }
                            continue;
                        }
                        var parts:Array = line.split("=");
                        if (parts.length >= 2)
                        {
                            key = StringUtil.trim(parts[0]);
                            if (parts.length == 2)
                                val = parts[1];
                            else
                            {
                                parts.shift();
                                val = parts.join("=");
                            }
                            if (val.charAt(val.length - 1) == "\\")
                            {
                                collectingParts = true;
                                val = val.substr(0, val.length - 1);
                            }
                            else if (!context.hasOwnProperty(key))
                                context[key] = ant.getValue(StringUtil.trim(val), context);
                        }
                        
                    }
                    fs.close();                
                }
            }
            else if (envPrefix != null)
            {
                requestEnvironmentVariables();
                return false;
            }
            return true;
        }
        
        private function get fileName():String
        {
            return getNullOrAttributeValue("@file");
        }
        
        private function get refid():String
        {
            return getNullOrAttributeValue("@refid");
        }
        
        private function get value():String
        {
            return getNullOrAttributeValue("@value");
        }
        
        private function get location():String
        {
            return getNullOrAttributeValue("@location");
        }
        
        private function get envPrefix():String
        {
            return getNullOrAttributeValue("@environment");
        }
        
        private var process:NativeProcess;
        
        public function requestEnvironmentVariables():void
        {
            var file:File = File.applicationDirectory;
            if (Capabilities.os.toLowerCase().indexOf('win') == -1)
                file = new File("/bin/bash");
            else
                file = file.resolvePath("C:\\Windows\\System32\\cmd.exe");
            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            nativeProcessStartupInfo.executable = file;
            var args:Vector.<String> = new Vector.<String>();
            if (Capabilities.os.toLowerCase().indexOf('win') == -1)
                args.push("-c");
            else
                args.push("/c");
            args.push("set");
            nativeProcessStartupInfo.arguments = args;
            process = new NativeProcess();
            process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData); 
            process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onOutputErrorData); 
            process.start(nativeProcessStartupInfo);
            process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);
        }
        
        private function exitHandler(event:NativeProcessExitEvent):void
        {
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function onOutputErrorData(event:ProgressEvent):void 
        { 
            var stdError:IDataInput = process.standardError; 
            var data:String = stdError.readUTFBytes(process.standardError.bytesAvailable); 
            trace("Got Error Output: ", data); 
        }
        
        private function onOutputData(event:ProgressEvent):void 
        { 
            var stdOut:IDataInput = process.standardOutput; 
            var data:String = stdOut.readUTFBytes(process.standardOutput.bytesAvailable); 
            trace("Got: ", data); 
            var propLines:Array;
            if (Capabilities.os.indexOf('Mac OS') > -1)
                propLines = data.split("\n");
            else
                propLines = data.split("\r\n");
            var prefix:String = envPrefix;
            for each (var line:String in propLines)
            {
                var parts:Array = line.split("=");
                if (parts.length >= 2)
                {
                    var key:String = envPrefix + "." + StringUtil.trim(parts[0]);
                    var val:String;
                    if (parts.length == 2)
                        val = parts[1];
                    else
                    {
                        parts.shift();
                        val = parts.join("=");
                    }
                    if (!context.hasOwnProperty(key))
                        context[key] = val;
                }
            }
        }
        
    } 
}