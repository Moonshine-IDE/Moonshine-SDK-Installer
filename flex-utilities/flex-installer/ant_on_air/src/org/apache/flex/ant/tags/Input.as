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
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    
    [Mixin]
    public class Input extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["input"] = Input;
        }

        public function Input()
        {
            super();
        }
        
        private function get text():String
		{
			return getAttributeValue("@message");
		}
		
        private function get validArgs():Array
		{
			var val:String = getNullOrAttributeValue("@validargs");
			return val == null ? null : val.split(",");
		}
		
        private function get property():String
		{
			return getAttributeValue("@addproperty");
		}
		
        private function get defaultValue():String
		{
			return getAttributeValue("@defaultvalue");
		}
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
			var s:String = "";
            if (text)
                s += ant.getValue(text, context);
            if (validArgs)
                s += " (" + validArgs + ")";
			ant.output(ant.formatOutput("input", s));
            ant.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            return false;
        }
        
        // consumer should re-dispatch keyboard events from ant instance
        private function keyDownHandler(event:KeyboardEvent):void
        {
            var val:String;
            
            if (validArgs == null && event.keyCode == Keyboard.ENTER)
                val = defaultValue;
            else if (validArgs.indexOf(String.fromCharCode(event.charCode)) != -1)
                val = String.fromCharCode(event.charCode);
            
            if (val != null)
            {
                ant.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
                if (!context.hasOwnProperty(property))
                    context[property] = val;
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
    }
}