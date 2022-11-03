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
package actionScripts.ui.views
{
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import actionScripts.interfaces.IHelperMoonshineBridge;
	import actionScripts.locator.HelperModel;
	import actionScripts.managers.InstallerItemsManager;
	import actionScripts.managers.StartupHelper;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.utils.EnvironmentUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.Parser;
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import moonshine.components.HelperView;
	import moonshine.events.HelperEvent;
	import moonshine.haxeScripts.valueObjects.ComponentVariantVO;

	public class HelperViewWrapper extends FeathersUIWrapper
	{
		//--------------------------------------------------------------------------
		//
		//  VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var dependencyCheckUtil:IHelperMoonshineBridge;
		public var environmentUtil:EnvironmentUtils;
		public var isRunningInsideMoonshine:Boolean;
		public var itemsManager:InstallerItemsManager = InstallerItemsManager.getInstance();
		
		public function get isConfigurationLoaded():Boolean
		{
			return (model.components != null);
		}
		
		private var model:HelperModel = HelperModel.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  CLASS API
		//
		//--------------------------------------------------------------------------
		
		public function HelperViewWrapper(feathersUIControl:HelperView=null)
		{
			super(feathersUIControl);
		}
		
		override public function initialize():void
		{
			super.initialize();
			HelperConstants.IS_RUNNING_IN_MOON = isRunningInsideMoonshine;
			
			//if (!HelperConstants.IS_RUNNING_IN_MOON) rgType.selectedIndex = 1;
			
			if (!model.components)
			{
				itemsManager.dependencyCheckUtil = dependencyCheckUtil;
				itemsManager.environmentUtil = environmentUtil;
				itemsManager.addEventListener(HelperEvent.COMPONENT_DOWNLOADED, onComponentDetected, false, 0, true);
				itemsManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentsDetected, false, 0, true);
				itemsManager.addEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
				itemsManager.loadItemsAndDetect();
			}
			else
			{
				onConfigLoaded(null);
			}
			
			this.feathersUIControl.addEventListener(
				HelperView.EVENT_FILTER_TYPE_CHANGED, onFilterTypeChanged, false, 0, true
			);
			this.feathersUIControl.addEventListener(
				HelperView.EVENT_SHOW_ONLY_NEEDS_SETUP_CHANGED, onFilterChange, false, 0, true
			);
			this.feathersUIControl.addEventListener(
				HelperEvent.OPEN_COMPONENT_LICENSE, onComponentLicenseViewRequest, false, 0, true
			);
			this.feathersUIControl.addEventListener(
				HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged, false, 0, true
			);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------

		public function setHelperReady():void
		{
			(this.feathersUIControl as HelperView).setHelperReady();
		}

		public function checkForUpdate():void
		{
			if (model.components && !HelperConstants.IS_DETECTION_IN_PROCESS)
			{
				itemsManager.detectOnly();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function filterSearch(filter:Boolean=true):void
		{
			if (!filter)
			{
				//model.packages.filterFunction = null;
				model.components.filterFunction = null;
				//model.packages.refresh();
				model.components.refresh();
				return;
			}
			
			if ((this.feathersUIControl as HelperView).filterTypeIndex == 0)
			{
				/*model.packages.filterFunction = filterPackages;
				model.packages.refresh();*/
			}
			else
			{
				model.components.filterFunction = filterComponents;
				model.components.refresh();
			}
		}
		
		private function filterPackages(item:Object):Boolean
		{
			return !item.isIntegrated;
		}
		
		private function filterComponents(item:Object):Boolean
		{
			return !item.isAlreadyDownloaded;
		}
		
		private function onConfigLoaded(event:HelperEvent):void
		{
			itemsManager.removeEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
			onFilterTypeChanged(null);
			
			// pre-filter-out pre-installed items on SDK Installer view
			if (!isRunningInsideMoonshine)
			{
				model.packages.filterFunction = filterPackages;
				model.packages.refresh();
			}
		}
		
		private function onFilterTypeChanged(event:Event):void
		{
			if ((this.feathersUIControl as HelperView).filterTypeIndex == 0)
			{
				(this.feathersUIControl as HelperView).setListPropertiesByFeatureType(model.packages);
			}
			else
			{
				(this.feathersUIControl as HelperView).setListPropertiesBySoftwareType(model.components);
			}
			
			// update filter state
			onFilterChange(null);
		}
		
		private function onFilterChange(event:Event):void
		{
			filterSearch((this.feathersUIControl as HelperView).checkShowOnlyNeedsSetup);
		}
		
		private function onComponentLicenseViewRequest(event:HelperEvent):void
		{
			var stateData:ComponentVO = event.data as ComponentVO;
			if (stateData.type == ComponentTypes.TYPE_FLEX || stateData.type == ComponentTypes.TYPE_FLEX_HARMAN ||
				stateData.type == ComponentTypes.TYPE_SVN || 
				(HelperConstants.IS_MACOS && stateData.type == ComponentTypes.TYPE_GIT)) 
			{
				dispatchEvent(event);
			}
			else 
			{
				navigateToURL(new URLRequest(stateData.licenseUrl), "_blank");
			}
		}
		
		private function onComponentDetected(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onAllComponentsDetected(event:HelperEvent):void
		{
			itemsManager.removeEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentsDetected);
			dispatchEvent(event);
		}
		
		private function onDownloadVariantChanged(event:HelperEvent):void
		{
			var tmpVariant:ComponentVariantVO = event.data.ComponentVariantVO;
			var tmpComponent:ComponentVO = event.data.ComponentVO;
			var installToPath:String = Parser.getInstallDirectoryPath(tmpComponent.type, tmpVariant.version);
			tmpComponent.selectedVariantIndex = event.data.newIndex;
			tmpComponent.isDownloaded = tmpComponent.isAlreadyDownloaded = HelperUtils.isValidSDKDirectoryBy(tmpComponent.type, installToPath, tmpComponent.pathValidation);
			tmpComponent.sizeInMb = tmpVariant.sizeInMb;
			
			this.dispatchEvent(new HelperEvent(HelperEvent.DOWNLOAD_VARIANT_CHANGED));
		}
	}
}