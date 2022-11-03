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

package org.apache.flex.packageflexsdk.model
{
	import flash.system.Capabilities;
	
	import org.apache.flex.packageflexsdk.resource.ViewResourceConstants;
	
	public class OS
	{
		public const WINDOWS:String = "windows";
		public const MAC:String = "mac";
		public const LINUX:String = "linux";
		
		public var os:String = null;
		
		public function OS()
		{
			setOS();
		}
		
		public function isWindows():Boolean {
			return os == WINDOWS;
		}
		
		public function isMac():Boolean {
			return os == MAC;
		}
		
		public function isLinux():Boolean {
			return os == LINUX;
		}
		
		public function isOther():Boolean {
			return !(isWindows() || isMac() || isLinux());
		}
		
		private function setOS():void {
			var operatingSystem:String = Capabilities.os;
			
			if (operatingSystem.search("Mac OS") != -1) {
				os = MAC;
			} else if (operatingSystem.search("Windows") != -1) {
				os = WINDOWS;
			} else if (operatingSystem.search("Linux") != -1) {
				os = LINUX;
			}
		}
	}
}
