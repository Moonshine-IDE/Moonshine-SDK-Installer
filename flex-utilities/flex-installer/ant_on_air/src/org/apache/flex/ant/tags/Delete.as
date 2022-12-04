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
    import flash.filesystem.File;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.FileSetTaskHandler;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Delete extends FileSetTaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["delete"] = Delete;
        }
        
        public function Delete()
        {
            super();
        }
        
        private function get fileName():String
        {
            return getAttributeValue("@file");
        }
        
        private function get dirName():String
        {
            return getAttributeValue("@dir");
        }
        
        override protected function actOnFile(dir:String, fileName:String):void
        {
            var srcName:String;
            if (dir)
                srcName = dir + File.separator + fileName;
            else
                srcName = fileName;
            try {
                var delFile:File = File.applicationDirectory.resolvePath(srcName);
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
                return;							
            }
            
            if (delFile.isDirectory)
                delFile.deleteDirectory(true);
            else
                delFile.deleteFile();
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            var retVal:Boolean = super.execute(callbackMode, context);
            if (numChildren > 0)
                return retVal;
            
            var s:String;
            
            if (fileName)
            {
                try {
                    var delFile:File = File.applicationDirectory.resolvePath(fileName);
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
                
                s = ResourceManager.getInstance().getString('ant', 'DELETEFILE');
                s = s.replace("%1", delFile.nativePath);
                ant.output(ant.formatOutput("delete", s));
                delFile.deleteFile();
            }
            else if (dirName)
            {
                try {
                    var delDir:File = File.applicationDirectory.resolvePath(dirName);
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
                
                s = ResourceManager.getInstance().getString('ant', 'DELETEDIR');
                s = s.replace("%1", delDir.nativePath);
                ant.output(ant.formatOutput("delete", s));
                delDir.deleteDirectory(true);
            }            
            return true;
        }
        
    }
}