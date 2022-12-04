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
    import org.apache.flex.ant.Ant;
    import org.apache.flex.ant.tags.filesetClasses.DirectoryScanner;
    import org.apache.flex.ant.tags.filesetClasses.exceptions.BuildException;
    import org.apache.flex.ant.tags.supportClasses.IValueTagHandler;
    import org.apache.flex.ant.tags.supportClasses.NamedTagHandler;
    import org.apache.flex.ant.tags.supportClasses.ParentTagHandler;
    
    [Mixin]
    public class FileSet extends ParentTagHandler implements IValueTagHandler
    {
        public static function init(mf:Object):void
        {
            Ant.antTagProcessors["fileset"] = FileSet;
        }
        
        public function FileSet()
        {
            super();
        }
        
        public function get dir():String
        {
            return getNullOrAttributeValue("@dir");
        }
        
        private var _value:Vector.<String>;
        
        public function getValue(context:Object):Object
        {
            if (_value) return _value;
            this.context = context;
            
            ant.processChildren(xml, this);
            var ds:DirectoryScanner = new DirectoryScanner();
            var n:int = numChildren;
            var includes:Vector.<String> = new Vector.<String>();
            var excludes:Vector.<String> = new Vector.<String>();
            for (var i:int = 0; i < n; i++)
            {
                var tag:NamedTagHandler = getChildAt(i) as NamedTagHandler;
                tag.setContext(context);
                if (tag is FileSetInclude)
                    includes.push(tag.name);
                else if (tag is FileSetExclude)
                    excludes.push(tag.name);
                else
                    throw new BuildException("Unsupported Tag at index " + i);
            }
            ds.setIncludes(includes);
            ds.setExcludes(excludes);
            if (dir != null)
                ds.setBasedir(dir);
            ds.scan();
            _value = ds.getIncludedFiles();
            return _value;
        }
        
    }
}