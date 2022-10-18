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
    import flash.net.LocalConnection;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Target extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["target"] = Target;
        }
        
        public function Target()
        {
        }
        
        private function get ifProperty():String
        {
            return getNullOrAttributeValue("@if");
        }
        
        private function get unlessProperty():String
        {
            return getNullOrAttributeValue("@unless");
        }
        
        public function get depends():String
        {
            return getNullOrAttributeValue("@depends");
        }
        
        private var dependsList:Array;
        
        private function processDepends():Boolean
        {
            if (dependsList.length == 0)
            {
                continueOnToSteps();
                return true;
            }
            
            while (dependsList.length > 0)
            {
                var depend:String = dependsList.shift();
                var t:Target = ant.project.getTarget(depend);
                if (!t.execute(callbackMode, context))
                {
                    t.addEventListener(Event.COMPLETE, dependCompleteHandler);
                    return false;
                }
            }
            
            return continueOnToSteps();
        }
        
        private function dependCompleteHandler(event:Event):void
        {
            event.target.removeEventListener(Event.COMPLETE, dependCompleteHandler);
            if (!ant.project.status)
            {
                if (!inExecute)
                    dispatchEvent(new Event(Event.COMPLETE));
                return;
            }
            processDepends();
        }
        
        private var inExecute:Boolean;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            current = 0;
            inExecute = true;
            this.callbackMode = callbackMode;
            if (depends)
            {
                dependsList = depends.split(",");
                if (!processDepends())
                {
                    inExecute = false;
                    return false;
                }
            }
            
            var ok:Boolean = continueOnToSteps();
            inExecute = false;
            return ok;
        }
        
        private function continueOnToSteps():Boolean
        {
            if (!ant.project.status)
                return true;
            ant.output("\n" + name + ":");
            return processSteps();
        }
        
        private var current:int = 0;
        
        private function processSteps():Boolean
        {
            // try forcing GC before each step
            try {
                var lc1:LocalConnection = new LocalConnection();
                var lc2:LocalConnection = new LocalConnection();
                
                lc1.connect("name");
                lc2.connect("name");
            }
            catch (error:Error)
            {
            }
            

            if (ifProperty != null)
            {
                if (!context.hasOwnProperty(ifProperty))
                {
                    dispatchEvent(new Event(Event.COMPLETE));
                    return true;
                }
            }
            
            if (unlessProperty != null)
            {
                if (context.hasOwnProperty(unlessProperty))
                {
                    dispatchEvent(new Event(Event.COMPLETE));
                    return true;
                }
            }
            
            if (current == numChildren)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return true;
            }
            
            while (current < numChildren)
            {
                var step:TaskHandler = getChildAt(current++) as TaskHandler;
                if (!step.execute(callbackMode, context))
                {
                    step.addEventListener(Event.COMPLETE, completeHandler);
                    return false;
                }
                if (!ant.project.status)
                {
                    if (!inExecute)
                        dispatchEvent(new Event(Event.COMPLETE));
                    return true;
                }
                if (callbackMode)
                {
                    ant.functionToCall = processSteps;
                    return false;
                }
            }
            dispatchEvent(new Event(Event.COMPLETE));
            return true;
        }
        
        private function completeHandler(event:Event):void
        {
            event.target.removeEventListener(Event.COMPLETE, completeHandler);
            if (!ant.project.status)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return;                
            }
            if (callbackMode)
                ant.functionToCall = processSteps;
            else
                processSteps();
        }
    }
}