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
package org.apache.flex.ant.tags.supportClasses
{
    import flash.events.EventDispatcher;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.xml.ITagHandler;
    import org.apache.flex.xml.XMLTagProcessor;
    
    /**
     *   The lowest-level base class for ITagHandlers for Ant.
     */
    public class TagHandler extends EventDispatcher implements ITagHandler
    {
        /**
         *  Constructor
         */
        public function TagHandler()
        {
        }
        
        /**
         *  The Ant instance.  Often used for getValue() and output() methods. 
         */
        protected var ant:Ant;
        
        /**
         *  The context object.  Contains the properties that currently apply.
         */
        protected var context:Object;
        
        /**
         *  Set the context
         */
        public function setContext(context:Object):void
        {
            this.context = context;
        }
        
        /**
         *  The xml node for this tag
         */
        protected var xml:XML;
        
        /**
         *  @see org.apache.flex.xml.ITagHandler 
         */
        public function init(xml:XML, xmlProcessor:XMLTagProcessor):void
        {
            ant = xmlProcessor as Ant;
            this.xml = xml;
        }
        
        protected function getAttributeValue(name:String):String
        {
            return ant.getValue(xml[name].toString(), context);	
        }
        
        protected function getNullOrAttributeValue(name:String):String
        {
            var xmlList:XMLList = xml[name];
            if (xmlList.length() == 0)
                return null;
            
            return ant.getValue(xml[name].toString(), context);	
        }
        
    }
}