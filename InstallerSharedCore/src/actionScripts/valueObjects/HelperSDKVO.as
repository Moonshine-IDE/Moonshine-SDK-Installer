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
package actionScripts.valueObjects
{
	import flash.filesystem.File;
	import moonshine.haxeScripts.valueObjects.ComponentTypes;

	public class HelperSDKVO
	{
		private static const JS_SDK_COMPILER_NEW:String = "js/bin/mxmlc";
		private static const JS_SDK_COMPILER_OLD:String = "bin/mxmlc";
		private static const FLEX_SDK_COMPILER:String = "bin/fcsh";
		
		public function HelperSDKVO()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var version:String;
		public var build:String;
		public var status:String;
		public var path:File;
		public var name:String;
		
		private var _type:String;
		public function get type():String
		{
			if (!_type) _type = getType();
			return _type;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function getType():String
		{
			// flex
			var compilerExtension:String = HelperConstants.IS_MACOS ? "" : ".bat";
			var compilerFile:File = path.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/libs/spark.swc").exists || 
					path.resolvePath("frameworks/libs/flex.swc").exists) return ComponentTypes.TYPE_FLEX;
			}
			
			// royale
			compilerFile = path.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/royale-config.xml").exists) return ComponentTypes.TYPE_ROYALE;
			}
			
			// feathers
			compilerFile = path.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/libs/feathers.swc").exists) return ComponentTypes.TYPE_FEATHERS;
			}
			
			// flexjs
			compilerFile = path.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
			if (compilerFile.exists)
			{
				if (name.toLowerCase().indexOf("flexjs") != -1) return ComponentTypes.TYPE_FLEXJS;
			}
			else 
			{
				compilerFile = path.resolvePath(JS_SDK_COMPILER_OLD + compilerExtension);
				if (compilerFile.exists)
				{
					if (name.toLowerCase().indexOf("flexjs") != -1) return ComponentTypes.TYPE_FLEXJS;
				}
			}
			
			return null;
		}
	}
}