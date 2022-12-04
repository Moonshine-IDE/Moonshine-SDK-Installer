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
    import flash.system.Capabilities;
    import flash.utils.IDataInput;
    
    import mx.utils.StringUtil;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Exec extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["exec"] = Exec;
        }
        
        public function Exec()
        {
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            var thisOS:String = Capabilities.os.toLowerCase();
            var osArr:Array = osFamily.split(",");
            var ok:Boolean = false;
            for each (var p:String in osArr)
            {
                if (p.toLowerCase() == "windows")
                    p = "win";
                if (thisOS.indexOf(p.toLowerCase()) != -1)
                {
                    ok = true;
                    break;
                }
            }
            if (!ok) return true;
            
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
            if (numChildren > 0)
            {
                var cmdline:String = fileName;
                for (var i:int = 0; i < numChildren; i++)
                {
                    var arg:Arg = getChildAt(i) as Arg;
                    arg.setContext(context);
                    cmdline += " " + quoteIfNeeded(arg.value);
                }
                args.push(cmdline);
            }
            else
                args.push(fileName);
            nativeProcessStartupInfo.arguments = args;
            if (dir)
            {
                var wd:File;
                wd = File.applicationDirectory;
                wd = wd.resolvePath(dir);
                nativeProcessStartupInfo.workingDirectory = wd;
            }
            
            process = new NativeProcess();
            process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData); 
            process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onOutputErrorData); 
            process.start(nativeProcessStartupInfo);
            process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);
            
            return false;
        }
        
        private function get dir():String
        {
            return getNullOrAttributeValue("@dir");
        }
        
        private function get fileName():String
        {
            return getAttributeValue("@executable");
        }
        
        private function get osFamily():String
        {
            return getAttributeValue("@osfamily");
        }
        
        private function get outputProperty():String
        {
            return getAttributeValue("@outputproperty");
        }

        override public function get failonerror():Boolean
        {
            var val:String = getNullOrAttributeValue("@failonerror");
            //if omitted, defaults to false
            return val == null ? false : val == "true";
        }
        
        private var process:NativeProcess;
        
        private function exitHandler(event:NativeProcessExitEvent):void
        {
            if(event.exitCode !== 0 && failonerror)
            {
                ant.project.failureMessage = "Exec task failed: " + fileName;
                ant.project.status = false;
            }
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
            if (outputProperty)
                context[outputProperty] = StringUtil.trim(data);
        }
      
        private function quoteIfNeeded(s:String):String
        {
            // has spaces but no quotes
            if (s.indexOf(" ") != -1 && s.indexOf('"') == -1)
                return '"' + s + '"';
            return s;
        }
    } 
}