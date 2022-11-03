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
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    import org.apache.flex.xml.ITagHandler;
    import org.as3commons.zip.Zip;
    import org.as3commons.zip.ZipEvent;
    import org.as3commons.zip.ZipFile;
    import flash.system.Capabilities;
    import flash.desktop.NativeProcess;
    import flash.events.ProgressEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.desktop.NativeProcessStartupInfo;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Unzip extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["unzip"] = Unzip;
        }
        
        public function Unzip()
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
        
        private var srcFile:File;
        private var destFile:File;
        private var patternSet:PatternSet;
        private var _process:NativeProcess;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            if (numChildren > 0)
            {
                // look for a patternset
                for (var i:int = 0; i < numChildren; i++)
                {
                    var child:ITagHandler = getChildAt(i);
                    if (child is PatternSet)
                    {
                        patternSet = child as PatternSet;
                        patternSet.setContext(context);
                        break;
                    }
                }
            }
            
            try {
                srcFile = File.applicationDirectory.resolvePath(src);
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
            
            
            var s:String = ResourceManager.getInstance().getString('ant', 'UNZIP');
            s = s.replace("%1", srcFile.nativePath);
            s = s.replace("%2", destFile.nativePath);
            ant.output(ant.formatOutput("unzip", s));
            ant.functionToCall = dounzip;
            return false;
        }
        
        private function dounzip():void
        {
            if (unzip(srcFile))
            {
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private function winUnzip(source:File):void {
            var executable:File = new File("C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe");
            var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            var arguments:Vector.<String> = new <String>["-NoProfile"];

			var command:String = "& {";
			command += "Param([string]$zipPath,[string]$outPath)"
            //newer versions of PowerShell support the Expand-Archive cmdlet
            //command += "if (Get-Command Expand-Archive -errorAction SilentlyContinue) {";
            //command += "Expand-Archive -Path \"" + source.nativePath + "\" -DestinationPath \"" + destFile.nativePath + "\" -Force;";
            //older versions of PowerShell must fall back to COM object APIs
            //command += "} else {"
            command += "$shell = New-Object -ComObject shell.application;$zip = $shell.NameSpace($zipPath);New-Item -path $outPath -type directory -force;$shell.NameSpace($outPath).CopyHere($zip.items(), 4 + 16);[Environment]::Exit(0);";
            //command += "}" //end else
			command += "}"; //end $ {
			command += " ";
			command += "\"";
			command += source.nativePath;
			command += "\"";
			command += " ";
			command += "\"";
			command += destFile.nativePath;
			command += "\"";
			arguments.push("-Command");
			arguments.push(command);
            
            startupInfo.executable = executable;
            startupInfo.arguments = arguments;

            _process = new NativeProcess();
            _process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, unzipFileProgress);
            _process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, unzipError);
            _process.addEventListener(NativeProcessExitEvent.EXIT, unzipComplete);
            _process.start(startupInfo);
        }
        
        private function unzip(fileToUnzip:File):Boolean {
            if ((fileToUnzip.extension.toLowerCase() == "zip") &&
                    (Capabilities.os.indexOf("Win") != -1))
            {
                winUnzip(fileToUnzip);
                return false;
            }
            var zipFileBytes:ByteArray = new ByteArray();
            var fs:FileStream = new FileStream();
            var fzip:Zip = new Zip();
            
            fs.open(fileToUnzip, FileMode.READ);
            fs.readBytes(zipFileBytes);
            fs.close();
            
            fzip.addEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
            fzip.addEventListener(Event.COMPLETE, onUnzipComplete, false, 0, true);
            fzip.addEventListener(ErrorEvent.ERROR, onUnzipError, false, 0, true);
            
            // synchronous, so no progress events
            fzip.loadBytes(zipFileBytes);
            return true;
        }
        
        private function isDirectory(f:ZipFile):Boolean {
            if (f.filename.substr(f.filename.length - 1) == "/" || f.filename.substr(f.filename.length - 1) == "\\") {
                return true;
            }
            return false;
        }
        
        private function onFileLoaded(e:ZipEvent):void {
            try {
                var fzf:ZipFile = e.file;
                if (patternSet)
                {
                    if (!(patternSet.matches(fzf.filename)))
                        return;
                }
                var f:File = destFile.resolvePath(fzf.filename);
                var fs:FileStream = new FileStream();
                
                if (isDirectory(fzf)) {
                    // Is a directory, not a file. Dont try to write anything into it.
                    return;
                }
                
                fs.open(f, FileMode.WRITE);
                fs.writeBytes(fzf.content);
                fs.close();
				
				// attempt to shrink bytearray so memory doesn't store every uncompressed byte
				fzf.setContent(null, false);
                
            } catch (error:Error) {
				ant.output(error.message);
				if (failonerror)
				{
					ant.project.failureMessage = error.message;
					ant.project.status = false;
				}
            }
        }
        
        private function onUnzipComplete(event:Event):void {
            var fzip:Zip = event.target as Zip;
            fzip.close();
            fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
            fzip.removeEventListener(Event.COMPLETE, onUnzipComplete);            
            fzip.removeEventListener(ErrorEvent.ERROR, onUnzipError);            
        }
        
        private function onUnzipError(event:Event):void {
            var fzip:Zip = event.target as Zip;
            fzip.close();
            fzip.removeEventListener(ZipEvent.FILE_LOADED, onFileLoaded);
            fzip.removeEventListener(Event.COMPLETE, onUnzipComplete);            
            fzip.removeEventListener(ErrorEvent.ERROR, onUnzipError);
			if (failonerror)
			{
				ant.project.failureMessage = event.toString();
				ant.project.status = false;
			}
        }
        
        private function unzipError(event:Event):void {
            var output:String = _process.standardError.readUTFBytes(_process.standardError.bytesAvailable);
            ant.output(output);
			if (failonerror)
			{
				ant.project.failureMessage = output;
				ant.project.status = false;
			}
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function unzipFileProgress(event:Event):void {
            var output:String = _process.standardOutput.readUTFBytes(_process.standardOutput.bytesAvailable);
            ant.output(output);
        }
        
        private function unzipComplete(event:NativeProcessExitEvent):void {
            _process.closeInput();
            _process.exit(true);
            _process = null;
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}