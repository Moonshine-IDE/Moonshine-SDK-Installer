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
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    
    import org.apache.flex.ant.tags.FileSet;
    
    /**
     *  The base class for ITagHandlers that do work with filesets
     */
    public class FileSetTaskHandler extends TaskHandler
    {
        public function FileSetTaskHandler()
        {
        }
        
        private var current:int = 0;
        private var currentFile:int;
        private var currentList:Vector.<String>;
        private var currentDir:File;
        private var totalFiles:int;
        private var thisFile:int;
        
        /**
         *  Do the work.
         *  TaskHandlers lazily create their children
         *  and attributes so
         *  super.execute() should be called before
         *  doing any real work. 
         */
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            totalFiles = 0;
            thisFile = 0;
            for (var i:int = 0; i < numChildren; i++)
            {
                var fs:FileSet = getChildAt(i) as FileSet;
                if (fs)
                {
                    try
                    {
                        var list:Vector.<String> = fs.getValue(context) as Vector.<String>;
                        if (list)
                        {
                            totalFiles += list.length;
                        }
                    }
                    catch (e:Error)
                    {
                        if (failonerror)
                        {
							ant.project.failureMessage = e.message;
                            ant.project.status = false;
                            return true;
                        }
                    }
                }
            }
            if (numChildren)
                outputTotal(totalFiles);
            actOnFileSets();
            return !callbackMode;
        }
        
        protected function outputTotal(total:int):void
        {
            
        }
        
        private function actOnFileSets():void
        {
            if (current == numChildren)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }
            
            while (current < numChildren)
            {
                var fs:FileSet = getChildAt(current++) as FileSet;
                if (fs)
                {
                    var list:Vector.<String> = fs.getValue(context) as Vector.<String>;
                    if (list)
                    {
                        try {
                            currentDir = new File(fs.dir);
                        } 
                        catch (e:Error)
                        {
                            ant.output(fs.dir);
                            ant.output(e.message);
							if (failonerror)
							{
								ant.project.failureMessage = e.message;
								ant.project.status = false;
							}
                            dispatchEvent(new Event(Event.COMPLETE));
                            return;							
                        }
                        currentFile = 0;
                        currentList = list;
                        actOnList();
                        if (callbackMode)
                            return;
                    }
                }
            }
            
            if (current == numChildren)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }
        }
        
        private function actOnList():void
        {
            if (currentFile == currentList.length)
            {
                ant.functionToCall = actOnFileSets;
                ant.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, thisFile, totalFiles));
                return;
            }
            
            while (currentFile < currentList.length)
            {
                ant.progressClass = this;
                var fileName:String = currentList[currentFile++];
                ant.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, thisFile, totalFiles));
                actOnFile(currentDir.nativePath, fileName);
                thisFile++;
                if (callbackMode)
                {
                    ant.functionToCall = actOnList;
                    return;
                }
            }
        }
        
        protected function actOnFile(dir:String, fileName:String):void
        {
            
        }
    }
}