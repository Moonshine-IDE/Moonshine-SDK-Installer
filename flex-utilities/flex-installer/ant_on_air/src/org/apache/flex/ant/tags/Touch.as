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
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    import mx.resources.ResourceManager;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [ResourceBundle("ant")]
    [Mixin]
    public class Touch extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["touch"] = Touch;
        }
        
        public function Touch()
        {
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
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
            
            var s:String = ResourceManager.getInstance().getString('ant', 'TOUCH');
            s = s.replace("%1", f.nativePath);
            ant.output(ant.formatOutput("touch", s));
            
            var fs:FileStream = new FileStream();
            fs.open(f, FileMode.APPEND);
            fs.close();
            return true;
        }
        
        private function get fileName():String
        {
            return getAttributeValue("@file");
        }        
        
    } 
}