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
package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.interfaces.IHelperMoonshineBridge;
	import actionScripts.locator.HelperModel;
	import actionScripts.utils.EnvironmentUtils;
	
	import moonshine.events.HelperEvent;

	public class InstallerItemsManager extends EventDispatcher
	{
		private static var instance:InstallerItemsManager;
		
		public static function getInstance():InstallerItemsManager 
		{	
			if (!instance) instance = new InstallerItemsManager();
			return instance;
		}
		
		public var startupHelper:StartupHelper = new StartupHelper();
		public var detectionManager:DetectionManager = new DetectionManager();
		public var dependencyCheckUtil:IHelperMoonshineBridge;
		public var environmentUtil:EnvironmentUtils;
		
		private var model:HelperModel = HelperModel.getInstance();
		
		public function loadItemsAndDetect():void
		{
			if (!model.components)
			{
				model.moonshineBridge = dependencyCheckUtil;
				detectionManager.addEventListener(HelperEvent.COMPONENT_DOWNLOADED, onComponentDetected, false, 0, true);
				detectionManager.addEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDetected, false, 0, true);
				detectionManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentsTested, false, 0, true);
				
				CookieManager.getInstance().loadLocalStorage();
				
				attachStartupHelperListeners(true);
				StartupHelper.setLocalPathConfig();
				startupHelper.loadMoonshineConfig();
			}
			else
			{
				detectOnly();
			}
		}
		
		public function detectOnly():void
		{
			detectionManager.environmentUtil = environmentUtil;
			detectionManager.detect();
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function attachStartupHelperListeners(attach:Boolean):void
		{
			if (attach)
			{
				startupHelper.addEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
				startupHelper.addEventListener(StartupHelper.EVENT_CONFIG_ERROR, onConfigError);
			}
			else
			{
				startupHelper.removeEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
				startupHelper.removeEventListener(StartupHelper.EVENT_CONFIG_ERROR, onConfigError);
			}
		}
		
		private function onConfigLoaded(event:HelperEvent):void
		{
			dispatchEvent(event);
			attachStartupHelperListeners(false);
			
			var timeoutValue:uint = setTimeout(function():void
			{
				clearTimeout(timeoutValue);
				detectionManager.environmentUtil = environmentUtil;
				detectionManager.detect();
			}, 1000);
		}
		
		private function onConfigError(event:HelperEvent):void
		{
			// TODO: Show error
			attachStartupHelperListeners(false);
		}
		
		private function onComponentNotDetected(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onAllComponentsTested(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onComponentDetected(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
	}
}