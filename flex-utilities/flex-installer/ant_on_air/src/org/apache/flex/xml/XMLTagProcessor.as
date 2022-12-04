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
package org.apache.flex.xml
{
    import flash.events.EventDispatcher;

    /**
     *  Base class for processing XML Tags 
     */
    public class XMLTagProcessor extends EventDispatcher
    {
        /**
         *  Constructor
         */
        public function XMLTagProcessor()
        {
        }
        
        /**
         *  Find the associated class for the XML tag and generate
         *  and instance of it.
         * 
         *  @param xml XML The XML node.
         *  @param context Object An object containing useful information.
         *  @return ITagHandler An instance representing this XML node
         */
        public function processXMLTag(xml:XML):ITagHandler
        {
            var tag:String = xml.name().toString();
            var c:Class = tagMap[tag];
            if (!c)
            {
                trace("no processor for ", tag);
                throw new Error("no processor for " + tag);
            }
            var o:ITagHandler = new c() as ITagHandler;
            o.init(xml, this);
            return o;
        }
        
        /**
         *  Loop through the children of a node and process them
         *  
         *  @param xml XML The XML node.
         *  @param context Object An object containing useful information.
         *  @param parentTag IParentTagHandler The parent for the instances that are created.
         */
        public function processChildren(xml:XML, parentTag:IParentTagHandler):void
        {
            parentTag.removeChildren();
            
            var xmlList:XMLList = xml.children();
            var n:int = xmlList.length();
            for (var i:int = 0; i < n; i++)
            {
                var kind:String = xmlList[i].nodeKind();
                if (kind == "text")
                    ITextTagHandler(parentTag).setText(xmlList[i].toString());
                else
                {
                    var tagHandler:ITagHandler = processXMLTag(xmlList[i]);
                    parentTag.addChild(tagHandler);
                }
            }
        }
        
        public var tagMap:Object = {};
        
    }
}