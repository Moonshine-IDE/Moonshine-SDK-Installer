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
package actionScripts.ui.menu
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	
	[Event(name="EVENT_ABOUT", type="flash.events.Event")]
	[Event(name="MENU_QUIT_EVENT", type="flash.events.Event")]
	public class MenuManager extends EventDispatcher
	{
		protected var windowMenus:Vector.<MenuItem> = new Vector.<MenuItem>();
		protected var macMenu:MenuItem = new MenuItem("Moonshine SDK Installer");
		
		private var eventToMenuMapping:Dictionary = new Dictionary();
		private var lookup:Object = {};
		
		public function MenuManager()
		{
			windowMenus.splice(0, 0, macMenu);
			macMenu.items = new Vector.<MenuItem>();
			macMenu.items.push(new MenuItem("About Moonshine SDK Installer", null, "EVENT_ABOUT", "a", [Keyboard.COMMAND], "a", [Keyboard.ALTERNATE]));
			
			windowMenus[0].items.push(new MenuItem(null));
			windowMenus[0].items.push(new MenuItem("Quit", null, "MENU_QUIT_EVENT", "q", [Keyboard.COMMAND], "f4", [Keyboard.ALTERNATE]));
			
			var nm:NativeMenu = new NativeMenu();
			addMenus(windowMenus, nm);
			
			FlexGlobals.topLevelApplication.nativeApplication.menu = nm;
			//FlexGlobals.topLevelApplication.nativeWindow.menu = nm;
		}
		
		private function addMenus(items:Vector.<MenuItem>, parentMenu:*):void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				var item:MenuItem = items[i];
				
				if (item && item.items)
				{
					var newMenu:NativeMenu = new NativeMenu();
					if (!newMenu)
						continue;
					addMenus(item.items, newMenu);
					parentMenu.addSubmenu(newMenu, item.label);
				}
				else if (item)
				{
					var menuItem:NativeMenuItem = createNewMenuItem(item);;
					if (menuItem)
						parentMenu.addItem(menuItem);
				}
			}
		}
		
		private function createNewMenuItem(item:MenuItem):*
		{
			var nativeMenuItem:NativeMenuItem;
			var shortcut:KeyboardShortcut = buildShortcut(item);
			
			// in case of AIR
			nativeMenuItem = new NativeMenuItem(item.label, item.isSeparator);
			if (item["mac_key"])
				nativeMenuItem.keyEquivalent = item["mac_key"];
			if (item["mac_mod"])
				nativeMenuItem.keyEquivalentModifiers = item["mac_mod"];
			if (item.event)
			{
				// TODO : don't like this
				nativeMenuItem.data = {
					eventData:item.data,
						event:item.event
				};
				eventToMenuMapping[item.event] = nativeMenuItem;
				nativeMenuItem.addEventListener(Event.SELECT, redispatch, false, 0, true);
			}
			
			if (shortcut)
				registerShortcut(shortcut);
			
			return nativeMenuItem;
		}
		
		private function registerShortcut(shortcut:KeyboardShortcut):void
		{
			lookup[getKeyConfigFromShortcut(shortcut)] = shortcut.event;
		}
		
		private function getKeyConfigFromShortcut(shortcut:KeyboardShortcut):String
		{
			var config:Array = [];
			
			if (shortcut.cmdKey || shortcut.ctrlKey)
				config.push("C");
			if (shortcut.altKey)
				config.push("A");
			if (shortcut.shiftKey)
				config.push("S");
			config.push(shortcut.keyCode);
			
			return config.join(" ");
		}
		
		private function getKeyConfigFromEvent(e:KeyboardEvent):String
		{
			var config:Array = [];
			if (e.ctrlKey || e.keyCode == 22) // keycode == 22 - CHECK COMMAND KEY VALUE FOR MACOS
				config.push("C");
			if (e.altKey)
				config.push("A");
			if (e.shiftKey)
				config.push("S");
			config.push(e.keyCode);
			return config.join(" ");
			
		}
		
		private function buildShortcut(item:MenuItem):KeyboardShortcut
		{
			var key:String
			var mod:Array
			var event:String
			
			if (item["mac_key"])
				key = item["mac_key"];
			if (item["mac_mod"])
				mod = item["mac_mod"];
			if (item.event)
				event = item.event
			if (event && key)
				return new KeyboardShortcut(event, key, mod);
			return null;
		}
		
		protected function redispatch(event:Event):void
		{
			if (event.target && event.target.data)
			{
				var eventType:String = event.target.data.event as String;
				if (eventType)
				{
					dispatchEvent(new Event(eventType)); // use to stop pending event from shortcut					
				}
			}
		}
	}
}