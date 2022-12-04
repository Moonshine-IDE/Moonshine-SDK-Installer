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
package org.apache.flex.ant.tags.filesetClasses
{
    // an approximation of the Java StringTokenizer
    public class StringTokenizer
    {
        public function StringTokenizer(s:String, delims:String = "\t\r\n\f", returnDelims:Boolean = false)
        {
            tokens = new Vector.<String>();
            var c1:int = 0;
            var c2:int = 0;
            var n:int = s.length;
            while (c2 < n)
            {
                var c:String = s.charAt(c2);
                if (delims.indexOf(c) != -1)
                {
                    tokens.push(s.substring(c1, c2));
                    c1 = c2;
                    while (c2 < n)
                    {
                        c = s.charAt(c2);
                        if (delims.indexOf(c) == -1)
                        {
                            if (returnDelims)
                                tokens.push(s.substring(c1, c2))
                            c1 = c2;
                            break;
                        }
                        c2++;
                    }
                    if (returnDelims && c1 < c2)
                    {
                        tokens.push(s.substring(c1, c2));
                        c1 = c2;
                    }
                }
                c2++;
            }
            if (c1 < n)
                tokens.push(s.substring(c1))
        }
        
        private var tokens:Vector.<String>;
        private var index:int = 0;
        
        public function hasMoreTokens():Boolean
        {
            return index < tokens.length;    
        }
        
        public function nextToken():String
        {
            return tokens[index++];
        }
    }
}