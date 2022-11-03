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
    import flash.events.Event;
    import flash.filesystem.File;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.FileSetTaskHandler;
    import org.apache.flex.xml.ITagHandler;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Copy extends FileSetTaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["copy"] = Copy;
        }
        
        public function Copy()
        {
            super();
        }
        
        private function get fileName():String
        {
            return getAttributeValue("@file");
        }
        
        private function get toFileName():String
        {
            var val:String = getNullOrAttributeValue("@toFile");
            if (val != null)
                return val;
            return getNullOrAttributeValue("@tofile");
            
        }
        
        private function get toDirName():String
        {
            return getAttributeValue("@todir");
        }
        
        private function get overwrite():Boolean
        {
            return getAttributeValue("@overwrite") == "true";
        }
        
        private var mapper:GlobMapper;
        
        private function mapFileName(name:String):String
        {
            var from:String = mapper.from;
            if (from.indexOf(".*") == -1)
                from = from.replace("*", ".*");
            var regex:RegExp = new RegExp(from);
            var results:Array = name.match(regex);
            if (results && results.length == 1)
            {
                name = mapper.to.replace("*", results[0]);
                return name;
            }
            return null;
        }
        
        private var searchedForMapper:Boolean;
        
        override protected function actOnFile(dir:String, fileName:String):void
        {
            if (!searchedForMapper)
            {
                // look for a mapper
                for (var i:int = 0; i < numChildren; i++)
                {
                    var child:ITagHandler = getChildAt(i);
                    if (child is GlobMapper)
                    {
                        mapper = child as GlobMapper;
                        mapper.setContext(context);
                        break;
                    }
                }
                searchedForMapper = true;
            }
            
            var srcName:String;
            if (dir)
                srcName = dir + File.separator + fileName;
            else
                srcName = fileName;
            try {
                var srcFile:File = File.applicationDirectory.resolvePath(srcName);
            } 
            catch (e:Error)
            {
                ant.output(srcName);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                return;							
            }
            
            
            if (mapper)
            {
                fileName = mapFileName(fileName);
                if (fileName == null)
                    return;
            }
            
            var destName:String;
            if (toDirName)
                destName = toDirName + File.separator + fileName;
            else
                destName = toFileName;
            try {
                var destFile:File = File.applicationDirectory.resolvePath(destName);
            } 
            catch (e:Error)
            {
                ant.output(destName);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                return;							
            }
            
            try {
                srcFile.copyTo(destFile, overwrite);
            }
            catch (e:Error)
            {
                ant.output(destName);
                ant.output(e.message);
                if (failonerror)
                {
                    ant.project.failureMessage = e.message;
                    ant.project.status = false;
                }
                return;							
            }
        }
        
        override protected function outputTotal(total:int):void
        {
            var s:String = ResourceManager.getInstance().getString('ant', 'COPYFILES');
            s = s.replace("%1", total.toString());
            s = s.replace("%2", toDirName);
            ant.output(ant.formatOutput("copy", s));
        }
        
        private var srcFile:File;
        private var destFile:File;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            var retVal:Boolean = super.execute(callbackMode, context);
            if (numChildren > 0)
                return retVal;
            
            try {
                srcFile = File.applicationDirectory.resolvePath(fileName);
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
            
            try {
                destFile = File.applicationDirectory.resolvePath(toFileName);
            } 
            catch (e:Error)
            {
                ant.output(toFileName);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                return true;							
            }
            
            //var destDir:File = destFile.parent;
            //var resolveName:String = destFile.nativePath.substr(destFile.nativePath.lastIndexOf(File.separator) + 1);
            //destDir.resolvePath(resolveName);
            
            var s:String = ResourceManager.getInstance().getString('ant', 'COPY');
            s = s.replace("%1", "1");
            s = s.replace("%2", destFile.nativePath);
            ant.output(ant.formatOutput("copy", s));
            if (callbackMode)
            {
                ant.functionToCall = doCopy;
                return false;
            }
            
            try {
                doCopy();
            }
            catch (e:Error)
            {
                ant.output(toFileName);
                ant.output(e.message);
                if (failonerror)
                {
                    ant.project.failureMessage = e.message;
                    ant.project.status = false;
                }
            }
            return true;
        }
        
        protected function doCopy():void
        {
            try
            {
                srcFile.copyTo(destFile, overwrite);
            } catch (e:Error)
            {
                ant.output("Copy problem: "+ srcFile.nativePath +" ("+ (srcFile.exists ? "exists" : "not-exist") +"), to: "+ destFile.nativePath +" ("+ (destFile.exists ? "exists" : "not-exist") +")\n"+ e.message);
            }

            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}