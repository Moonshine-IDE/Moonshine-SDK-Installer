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
package org.apache.flex.ant.tags
{
    import com.probertson.utils.GZIPEncoder;
    import de.ketzler.utils.SimpleUntar;
    
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.filesystem.File;
    import flash.system.Capabilities;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Untar extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["untar"] = Untar;
        }
        
        public function Untar()
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
        
        private function get overwrite():Boolean
        {
            return getAttributeValue("@overwrite") == "true";
        }
        
        private function get compression():String
        {
            return getNullOrAttributeValue("@compression");
        }
        
        private var destFile:File;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            try {
                var srcFile:File = File.applicationDirectory.resolvePath(src);
            } 
            catch (e:Error)
            {
                ant.output(src);
                ant.output(e.message);
				if (failonerror)
				{
					ant.project.failureMessage = e.message;
					ant.project.status = false;
				}
                return true;							
            }
            
            try {
                destFile = File.applicationDirectory.resolvePath(dest);
                if (!destFile.exists)
                    destFile.createDirectory();
            } 
            catch (e:Error)
            {
                ant.output(dest);
                ant.output(e.message);
				if (failonerror)
				{
					ant.project.failureMessage = e.message;
					ant.project.status = false;
				}
                return true;							
            }
            
            return untar(srcFile);
        }
        
        private var _process:NativeProcess;
        
        private function untar(source:File):Boolean 
        {
            if (Capabilities.os.indexOf("Win") != -1)
            {
                winUntar(source);
                return true;
            }
            
            var tar:File;
            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            var arguments:Vector.<String> = new Vector.<String>();
            
            if (Capabilities.os.indexOf("Linux") != -1)
                tar = new File("/bin/tar");
            else
                tar = new File("/usr/bin/tar");	
            
            arguments.push("xf");
            arguments.push(source.nativePath);
            arguments.push("-C");
            arguments.push(destFile.nativePath);
            
            startupInfo.executable = tar;
            startupInfo.arguments = arguments;
            
            var s:String = ResourceManager.getInstance().getString('ant', 'UNZIP');
            s = s.replace("%1", source.nativePath);
            s = s.replace("%2", destFile.nativePath);
            ant.output(ant.formatOutput("untar", s));
            
            _process = new NativeProcess();
            _process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unTarFileProgress);
            _process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unTarError);
            _process.addEventListener(NativeProcessExitEvent.EXIT, unTarComplete);
            _process.start(startupInfo);
            
            return false;

        }
        
        private function unTarError(event:Event):void {
            var output:String = _process.standardError.readUTFBytes(_process.standardError.bytesAvailable);
            ant.output(output);
			if (failonerror)
			{
				ant.project.failureMessage = output;
				ant.project.status = false;
			}
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function unTarFileProgress(event:Event):void {
            var output:String = _process.standardOutput.readUTFBytes(_process.standardOutput.bytesAvailable);
            ant.output(output);
        }
        
        private function unTarComplete(event:NativeProcessExitEvent):void {
            _process.closeInput();
            _process.exit(true);
            dispatchEvent(new Event(Event.COMPLETE));
        }
     
        private function winUntar(source:File):void
        {
            if (compression == "gzip")
            {
                var tarName:String = source.nativePath + ".tar";
                var tarFile:File = File.applicationDirectory.resolvePath(tarName);
                var gz:GZIPEncoder = new GZIPEncoder();
                gz.uncompressToFile(source, tarFile);
                source = tarFile;
            }
            var su:SimpleUntar = new SimpleUntar();
            su.sourcePath = source.nativePath;
            su.targetPath = destFile.nativePath;
            su.extract();
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}