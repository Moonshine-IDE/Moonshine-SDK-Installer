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
    
    import mx.utils.StringUtil;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.filesetClasses.Reference;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    import org.apache.flex.xml.ITagHandler;
    
    [Mixin]
    public class Project extends TaskHandler
    {
        /** Message priority of &quot;error&quot;. */
        public static const MSG_ERR:int = 0;
        /** Message priority of &quot;warning&quot;. */
        public static const MSG_WARN:int = 1;
        /** Message priority of &quot;information&quot;. */
        public static const MSG_INFO:int = 2;
        /** Message priority of &quot;verbose&quot;. */
        public static const MSG_VERBOSE:int = 3;
        /** Message priority of &quot;debug&quot;. */
        public static const MSG_DEBUG:int = 4;
        
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["project"] = Project;
        }
        
        public function Project()
        {
        }
        
        private var _status:Boolean;
        /**
         *  true if tasks completed successfully.
         *  Do not monitor this property to determine if the project is done executing.
         *  This property is set to true and a failing task sets it to false.
         */
        public function get status():Boolean
        {
            return _status;
        }
        
        public function set status(value:Boolean):void
        {
            if (_status != value)
            {
                _status = value;
                ant.dispatchEvent(new Event("statusChanged"));
            }
        }
        
		private var _failureMessage:String;
		/**
		 *  null if tasks completed successfully.
		 *  if status == false, then this will be
		 *  set if a <fail> message set status to false
		 *  or some other condition set status to false.
		 *  
		 */
		public function get failureMessage():String
		{
			return _failureMessage;
		}
		
		public function set failureMessage(value:String):void
		{
			if (_failureMessage != value)
			{
				_failureMessage = value;
				ant.dispatchEvent(new Event("failureMessageChanged"));
			}
		}
		
        public function get basedir():String
        {
            return getAttributeValue("@basedir");
        }
        
        public function get defaultTarget():String
        {
            return getAttributeValue("@default");
        }
        
        public var refids:Object = {};
        
        private var targets:Array;
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            this.callbackMode = callbackMode;
            
            status = true;
            
            if (context.targets == null)
                context.targets = defaultTarget;
            
            targets = context.targets.split(",");
            
            // execute all children in order except for targets
            return executeChildren();
        }
        
        private var current:int = 0;
        
        private function executeChildren():Boolean
        {
            if (!status)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return true;                
            }
            
            if (current == numChildren)
                return executeTargets();
            
            while (current < numChildren)
            {
                var child:ITagHandler = getChildAt(current++);
                if (child is Target)
                    continue;
                if (child is TaskHandler)
                {
                    var task:TaskHandler = TaskHandler(child);
                    if (!task.execute(callbackMode, context))
                    {
                        task.addEventListener(Event.COMPLETE, childCompleteHandler);
                        return false;
                    }
                    if (!status)
                    {
                        dispatchEvent(new Event(Event.COMPLETE));
                        return true;                                        
                    }
                }
            }
            return executeTargets();
        }
        
        private function executeTargets():Boolean
        {
            while (targets.length > 0)
            {
                var targetName:String = targets.shift();
                if (!executeTarget(targetName))
                    return false;
                if (!status)
                {
                    dispatchEvent(new Event(Event.COMPLETE));
                    return true;
                }
                
            }
            if (targets.length == 0)
                dispatchEvent(new Event(Event.COMPLETE));
            
            return true;
        }
        
        public function getTarget(targetName:String):Target
        {
            targetName = StringUtil.trim(targetName);
            var n:int = numChildren;
            for (var i:int = 0; i < n; i++)
            {
                var child:ITagHandler = getChildAt(i);
                if (child is Target)
                {
                    var t:Target = child as Target;
                    if (t.name == targetName)
                    {
                        return t;
                    }
                }
            }
            trace("missing target: ", targetName);
            throw new Error("missing target: " + targetName);
            return null;            
        }
        
        public function executeTarget(targetName:String):Boolean
        {
            var t:Target = getTarget(targetName);
            if (!t.execute(callbackMode, context))
            {
                t.addEventListener(Event.COMPLETE, completeHandler);
                return false;
            }
            return true;
        }
        
        private function completeHandler(event:Event):void
        {
            event.target.removeEventListener(Event.COMPLETE, completeHandler);
            executeTargets();
        }
        
        private function childCompleteHandler(event:Event):void
        {
            event.target.removeEventListener(Event.COMPLETE, childCompleteHandler);
            executeChildren();
        }
        
        private var references:Object = {};
        
        public function addReference(referenceName:String, value:Object):void
        {
            references[referenceName] = value;
        }
        public function getReference(referenceName:String):Reference
        {
            if (references.hasOwnProperty(referenceName))
                return references[referenceName];
            
            return null;
        }
    }
}