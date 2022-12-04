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
    import flash.errors.IOError;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.supportClasses.TaskHandler;
    import org.apache.flex.xml.ITagHandler;
    
    [Mixin]
    public class Replace extends TaskHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["replace"] = Replace;
        }
        
        public function Replace()
        {
            super();
        }
        
        private function get file():String
        {
            return getAttributeValue("@file");
        }
        
        private function get token():String
        {
            return getNullOrAttributeValue("@token");
        }
        
        private function get value():String
        {
            return getAttributeValue("@value");
        }
        
        override public function execute(callbackMode:Boolean, context:Object):Boolean
        {
            super.execute(callbackMode, context);
            
            try {
                var f:File = File.applicationDirectory.resolvePath(file);
                if(!f.exists)
                {
                    throw new IOError("File not found: " + f.nativePath);
                }
            } 
            catch (e:Error)
            {
                ant.output(file);
                ant.output(e.message);
                if (failonerror)
				{
					ant.project.failureMessage = e.message;
                    ant.project.status = false;
				}
                return true;							
            }
            
            var fs:FileStream = new FileStream();
            fs.open(f, FileMode.READ);
            var s:String = fs.readUTFBytes(fs.bytesAvailable);
            fs.close();
            var tokens:Vector.<String> = new Vector.<String>();
            var reps:Vector.<String> = new Vector.<String>();
            if (token != null)
            {
                tokens.push(token);
                reps.push(value);
            }
            if (numChildren > 0)
            {
                for (var i:int = 0; i < numChildren; i++)
                {
                    var child:ITagHandler = getChildAt(i);
                    if(child is ReplaceFilter)
                    {
                        var rf:ReplaceFilter = child as ReplaceFilter;
                        rf.setContext(context);
                        tokens.push(rf.token);
                        reps.push(rf.value);
                    }
                    else if(child is ReplaceToken)
                    {
                        var rt:ReplaceToken = child as ReplaceToken;
                        rt.setContext(context);
                        tokens.push(rt.text);
                    }
                    else if(child is ReplaceValue)
                    {
                        var rv:ReplaceValue = child as ReplaceValue;
                        rv.setContext(context);
                        reps.push(rv.text);
                    }
                }
            }
            var n:int = tokens.length;
            var c:int = 0;
            for (i = 0; i < n; i++)
            {
                var cur:int = 0;
                // only look at the portion we haven't looked at yet.
                // otherwise certain kinds of replacements can
                // cause infinite looping, like replacing
                // 'foo' with 'food'
                do
                {
                    c = s.indexOf(tokens[i], cur) 
                    if (c != -1)
                    {
                        var firstHalf:String = s.substr(0, c);
                        var secondHalf:String = s.substr(c);
                        s = firstHalf + secondHalf.replace(tokens[i], reps[i]);
                        cur = c + reps[i].length;
                    }
                } while (c != -1)
            }
            fs.open(f, FileMode.WRITE);
            fs.writeUTFBytes(s);
            fs.close();
            return true;
        }
    }
}