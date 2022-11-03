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
package actionScripts.ui.menu
{
	import __AS3__.vec.Vector;
	
	public class MenuItem extends Object
	{
		public function MenuItem(label:String , items:Array=null, event:String=null,
								 mac_key:*=null, mac_mod:Array=null,
								 win_key:*=null, win_mod:Array=null,
								 lnx_key:*=null, lnx_mod:Array=null,
								 parent:Array=null)
		{
			this.label = label;
			
			if(!label)
			{
				isSeparator = true;
			}
			
			if (items) 
			{
				this.items = Vector.<MenuItem>(items);
			}
			
			this.event = event;
			
			this.mac_key = mac_key;
			this.mac_mod = mac_mod;
			
			this.win_key = win_key;
			this.win_mod = win_mod;
			
			this.lnx_key = lnx_key;
			this.lnx_mod = lnx_mod;
		}
		
		
		public var label:String;
		
		public var items:Vector.<MenuItem>;
		
		public var event:String;
		
		public var mac_key:*;
		public var mac_mod:Array;
		
		public var win_key:*;
		public var win_mod:Array;
		
		public var lnx_key:*;
		public var lnx_mod:Array;
		
		public var data:*;
		
		public var isSeparator:Boolean;
		public var parents:Array; 
	}
}