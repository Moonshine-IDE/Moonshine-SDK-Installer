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
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.IValueTagHandler;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Available extends TaskHandler implements IValueTagHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["available"] = Available;
        }
        
        public function Available()
        {
            super();
        }
        
        private function get file():String
        {
            return getNullOrAttributeValue("@file");
        }
        
        private function get type():String
        {
            return getNullOrAttributeValue("@type");
        }
        
        private function get property():String
        {
            return getNullOrAttributeValue("@property");
        }
        
        private function get value():String
        {
            return getNullOrAttributeValue("@value");
        }
        
        public function getValue(context:Object):Object
        {
            this.context = context;
            
            if (this.file == null) return false;
            
            try
            {
                var file:File = new File(this.file);
            } 
            catch (e:Error)
            {
                return false;							
            }
            
            if (!file.exists)
                return false;
            
            if (type == "dir" && !file.isDirectory)
                return false;
            
            return true;
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            var avail:Object = getValue(context);
            if (avail)
            {
                if (!context.hasOwnProperty(property))
                    context[property] = value != null ? value : true;
            }			
            return true;
        }
        
    }
}