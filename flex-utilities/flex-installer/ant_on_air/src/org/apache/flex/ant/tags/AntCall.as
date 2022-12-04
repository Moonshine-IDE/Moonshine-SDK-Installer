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
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class AntCall extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["antcall"] = AntCall;
        }
        
        public function AntCall()
        {
            super();
        }
        
        private function get target():String
        {
            return getAttributeValue("@target");
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            // I think properties set in the sub-script to not affect the main script
            // so clone the properties here
            var subContext:Object = {};
            for (var p:String in context)
                subContext[p] = context[p];
            
            if (numChildren > 0)
            {
                for (var i:int = 0; i < numChildren; i++)
                {
                    var param:Param = getChildAt(i) as Param;
                    param.setContext(context);
                    subContext[param.name] = param.value;
                }
            }
            var t:Target = ant.project.getTarget(target);
            if (!t.execute(callbackMode, subContext))
            {
                t.addEventListener(Event.COMPLETE, completeHandler);
                return false;
            }
            return true;
        }
        
        private function completeHandler(event:Event):void
        {
            event.target.removeEventListener(Event.COMPLETE, completeHandler);
            dispatchEvent(event);
        }
    }
}