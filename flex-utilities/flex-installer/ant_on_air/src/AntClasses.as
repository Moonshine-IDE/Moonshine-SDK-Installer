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
package
{
    public class AntClasses
    {
        public function AntClasses()
        {
            import org.apache.flex.ant.Ant; Ant;
            import org.apache.flex.ant.tags.Project; Project;
			import org.apache.flex.ant.tags.And; And;
			import org.apache.flex.ant.tags.AntTask; AntTask;
			import org.apache.flex.ant.tags.AntCall; AntCall;
            import org.apache.flex.ant.tags.Available; Available;
            import org.apache.flex.ant.tags.Checksum; Checksum;
            import org.apache.flex.ant.tags.Condition; Condition;
            import org.apache.flex.ant.tags.Contains; Contains;
            import org.apache.flex.ant.tags.Copy; Copy;
            import org.apache.flex.ant.tags.Delete; Delete;
            import org.apache.flex.ant.tags.Echo; Echo;
            import org.apache.flex.ant.tags.Equals; Equals;
			import org.apache.flex.ant.tags.Exec; Exec;
            import org.apache.flex.ant.tags.Fail; Fail;
            import org.apache.flex.ant.tags.FileSet; FileSet;
            import org.apache.flex.ant.tags.FileSetExclude; FileSetExclude;
            import org.apache.flex.ant.tags.FileSetInclude; FileSetInclude;
            import org.apache.flex.ant.tags.Get; Get;
			import org.apache.flex.ant.tags.HasFreeSpace; HasFreeSpace;
            import org.apache.flex.ant.tags.Input; Input;
			import org.apache.flex.ant.tags.IsFalse; IsFalse;
			import org.apache.flex.ant.tags.IsReference; IsReference;
            import org.apache.flex.ant.tags.IsSet; IsSet;
			import org.apache.flex.ant.tags.IsTrue; IsTrue;
            import org.apache.flex.ant.tags.LoadProperties; LoadProperties;
			import org.apache.flex.ant.tags.Matches; Matches;
            import org.apache.flex.ant.tags.Mkdir; Mkdir;
            import org.apache.flex.ant.tags.Move; Move;
            import org.apache.flex.ant.tags.Not; Not;
			import org.apache.flex.ant.tags.Or; Or;
            import org.apache.flex.ant.tags.OS; OS;
			import org.apache.flex.ant.tags.Param; Param;
            import org.apache.flex.ant.tags.Property; Property;
            import org.apache.flex.ant.tags.PropertyFile; PropertyFile;
            import org.apache.flex.ant.tags.Replace; Replace;
			import org.apache.flex.ant.tags.Touch; Touch;
            import org.apache.flex.ant.tags.TStamp; TStamp;
            import org.apache.flex.ant.tags.Untar; Untar;
            import org.apache.flex.ant.tags.Unzip; Unzip;
            import org.apache.flex.ant.tags.XmlProperty; XmlProperty;
        }
    }
}