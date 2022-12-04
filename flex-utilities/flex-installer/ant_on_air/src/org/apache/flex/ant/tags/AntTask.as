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
    import flash.events.KeyboardEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class AntTask extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["ant"] = AntTask;
        }
        
        public function AntTask()
        {
            super();
        }
        
        private function get file():String
        {
            return getAttributeValue("@antfile");
        }
        
        private function get dir():String
        {
            return getAttributeValue("@dir");
        }
        
        private function get target():String
        {
            return getAttributeValue("@target");
        }
        
        private var subant:Ant;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            // I think properties set in the sub-script to not affect the main script
            // so clone the properties here
            var subContext:Object = {};
            for (var p:String in context)
                subContext[p] = context[p];
            if (subContext.hasOwnProperty("targets"))
                delete subContext["targets"];
            if (target)
                subContext["targets"] = target;
            
            subant = new Ant();
            subant.parentAnt = ant;
            subant.output = ant.output;
            var file:File = File.applicationDirectory;
            try {
                file = file.resolvePath(dir + File.separator + this.file);
            } 
            catch (e:Error)
            {
                ant.output(dir + File.separator + this.file);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                return true;							
            }
            
            if (!subant.processXMLFile(file, subContext, true))
            {
                subant.addEventListener("statusChanged", statusHandler);
                subant.addEventListener(Event.COMPLETE, completeHandler);
                subant.addEventListener(ProgressEvent.PROGRESS, progressEventHandler);
                // redispatch keyboard events off of ant so input task can see them
                ant.addEventListener(KeyboardEvent.KEY_DOWN, ant_keyDownHandler);
                return false;
            }
            else
                completeHandler(null);
            return true;
        }
        
        private function completeHandler(event:Event):void
        {
            event.target.removeEventListener("statusChanged", statusHandler);
            event.target.removeEventListener(Event.COMPLETE, completeHandler);
            event.target.removeEventListener(ProgressEvent.PROGRESS, progressEventHandler);
            ant.removeEventListener(KeyboardEvent.KEY_DOWN, ant_keyDownHandler);
            
            dispatchEvent(event);
        }
        
        private function statusHandler(event:Event):void
        {
            event.target.removeEventListener("statusChanged", statusHandler);
            event.target.removeEventListener(Event.COMPLETE, completeHandler);
            event.target.removeEventListener(ProgressEvent.PROGRESS, progressEventHandler);
            ant.removeEventListener(KeyboardEvent.KEY_DOWN, ant_keyDownHandler);
            ant.project.status = subant.project.status;
            ant.project.failureMessage = subant.project.failureMessage;
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        private function progressEventHandler(event:ProgressEvent):void
        {
            ant.dispatchEvent(event);
        }
        
        private function ant_keyDownHandler(event:KeyboardEvent):void
        {
            subant.dispatchEvent(event);
        }
        
    }
}