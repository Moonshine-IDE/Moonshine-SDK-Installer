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
package moonshine.components;

import moonshine.haxeScripts.valueObjects.PackageVO;
import feathers.text.TextFormat;
import actionScripts.valueObjects.HelperConstants;
import openfl.display.DisplayObject;
import moonshine.events.HelperEvent;
import moonshine.components.renderers.PackageRenderer;
import moonshine.components.renderers.ComponentRenderer;
import feathers.layout.HorizontalLayoutData;
import openfl.display.StageScaleMode;
import feathers.core.ToggleGroup;
import feathers.skins.RectangleSkin;
import moonshine.haxeScripts.valueObjects.ComponentVO;
import feathers.data.ListViewItemState;
import feathers.controls.AssetLoader;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.controls.Radio;
import feathers.layout.HorizontalLayout;
import feathers.controls.Check;
import feathers.events.TriggerEvent;
import feathers.controls.Label;
import feathers.controls.Button;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.SDKInstallerTheme;
import openfl.events.Event;

class HelperView extends LayoutGroup {
	public static final EVENT_FILTER_TYPE_CHANGED = "eventFilterTypeChanged";
	public static final EVENT_SHOW_ONLY_NEEDS_SETUP_CHANGED = "eventShowOnlyNeedsSetupChanged";

	public function new() 
	{
		if (!HelperConstants.IS_RUNNING_IN_MOON)
		{
			// in Moonshine the theme will be extended
			SDKInstallerTheme.initializeTheme();
		}
		
		super();

		this.bySoftwareRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ComponentRenderer();
			itemRenderer.addEventListener(HelperEvent.OPEN_COMPONENT_LICENSE, onLicenseViewRequested);
			itemRenderer.addEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged, false, 0, true);
			return itemRenderer;
		}, (itemRenderer:ComponentRenderer, state:ListViewItemState) -> {
			state.data.addEventListener("isUpdated", this.onItemBeingUpdated, false, 0, true);
		},
		(itemRenderer:ComponentRenderer, state:ListViewItemState) -> {
			state.data.removeEventListener("isUpdated", this.onItemBeingUpdated);
			itemRenderer.resetFields();
		}, 
		(itemRenderer:ComponentRenderer) -> {
			itemRenderer.removeEventListener(HelperEvent.OPEN_COMPONENT_LICENSE, onLicenseViewRequested);
			itemRenderer.removeEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged);
		});

		this.byFeatureRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new PackageRenderer();
			itemRenderer.addEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged, false, 0, true);
			return itemRenderer;
		}, this.byFeatureRecyclerUpdateFn,
			(itemRenderer:PackageRenderer, state:ListViewItemState) -> {
				itemRenderer.resetFields();
			}, 
			(itemRenderer:PackageRenderer) -> {
				itemRenderer.removeEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged);
			});
	}

	public function setListPropertiesBySoftwareType(withCollection:ArrayCollection<ComponentVO>):Void {
		this.itemsListView.itemRendererRecycler = this.bySoftwareRecycler;

		this.collectionBySoftware = withCollection;
		this.setInvalid(InvalidationFlag.DATA);
	}

	public function setListPropertiesByFeatureType(withCollection:ArrayCollection<PackageVO>):Void {
		this.itemsListView.itemRendererRecycler = this.byFeatureRecycler;

		this.collectionByFeature = withCollection;
		this.setInvalid(InvalidationFlag.DATA);
	}

	private var _filterTypeIndex:Int = HelperConstants.IS_RUNNING_IN_MOON ? 0 : 1;

	@:flash.property
	public var filterTypeIndex(get, never):Int;

	private function get_filterTypeIndex():Int {
		return this._filterTypeIndex;
	}

	private var _checkShowOnlyNeedsSetup:Bool;

	@:flash.property
	public var checkShowOnlyNeedsSetup(get, never):Bool;

	private function get_checkShowOnlyNeedsSetup():Bool {
		return this._checkShowOnlyNeedsSetup;
	}

	private var itemsListView:ListView;
	private var allDownloadedLayout:LayoutGroup;
	private var downloadThirdPartyButton:Button;
	private var sdkInstallerInstallationMessageLabel:Label;
	private var checkShowFeaturesNeedsSetup:Check;
	private var radioByFeature:Radio;
	private var radioBySoftware:Radio;
	private var filterByGroup = new ToggleGroup();
	private var collectionBySoftware:ArrayCollection<ComponentVO> = new ArrayCollection();
	private var collectionByFeature:ArrayCollection<PackageVO> = new ArrayCollection();

	private var byFeatureRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;
	private var bySoftwareRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;

	private var byFeatureRecyclerUpdateFn = (itemRenderer:PackageRenderer, state:ListViewItemState) -> {
		//itemRenderer.updateItemState(cast(state.data, PackageVO));
	};

	override private function initialize():Void {
		this.variant = SDKInstallerTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;

		// root container
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = CENTER;
		viewLayout.paddingBottom = 4.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		var optionsViewContainer = new LayoutGroup();
		optionsViewContainer.layoutData = new VerticalLayoutData(100, null);
		optionsViewContainer.layout = new AnchorLayout();
		this.addChild(optionsViewContainer);

		this.checkShowFeaturesNeedsSetup = new Check();
		this.checkShowFeaturesNeedsSetup.text = "Only show features that need setup";
		this.checkShowFeaturesNeedsSetup.addEventListener(Event.CHANGE, onCheckShowFeaturesNeedsSetupChange, false, 0, true);
		optionsViewContainer.addChild(this.checkShowFeaturesNeedsSetup);

		var radioContainerLayoutData = new AnchorLayoutData();
		radioContainerLayoutData.top = 0;
		radioContainerLayoutData.right = 0;

		var radioContainer = new LayoutGroup();
		radioContainer.layout = new HorizontalLayout();
		cast(radioContainer.layout, HorizontalLayout).gap = 6;
		radioContainer.layoutData = radioContainerLayoutData;
		optionsViewContainer.addChild(radioContainer);

		this.radioByFeature = new Radio();
		this.radioByFeature.text = "By Feature";
		this.radioByFeature.toggleGroup = this.filterByGroup;
		this.radioBySoftware = new Radio();
		this.radioBySoftware.text = "By Software";
		this.radioBySoftware.toggleGroup = this.filterByGroup;
		radioContainer.addChild(this.radioByFeature);
		radioContainer.addChild(this.radioBySoftware);

		if (!HelperConstants.IS_RUNNING_IN_MOON) this.filterByGroup.selectedIndex = 1;
		this.onFilterTypeChanged(null);

		this.filterByGroup.addEventListener(Event.CHANGE, onFilterTypeChanged, false, 0, true);

		this.itemsListView = new ListView();
		this.itemsListView.layoutData = new VerticalLayoutData(100, 100);
		this.addChild(this.itemsListView);

		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffffff);
		backgroundSkin.border = SolidColor(1.0, 0x999999);

		var allDownloadedLayoutLayout = new VerticalLayout();
		allDownloadedLayoutLayout.horizontalAlign = CENTER;
		allDownloadedLayoutLayout.verticalAlign = MIDDLE;
		allDownloadedLayoutLayout.gap = 4.0;

		this.allDownloadedLayout = new LayoutGroup();
		this.allDownloadedLayout.layout = allDownloadedLayoutLayout;
		this.allDownloadedLayout.backgroundSkin = backgroundSkin;
		this.allDownloadedLayout.layoutData = new VerticalLayoutData(100, 100);
		this.allDownloadedLayout.includeInLayout = this.allDownloadedLayout.visible = false;
		this.addChild(this.allDownloadedLayout);

		var lblCongratulation = new Label("Congratulations!");
		lblCongratulation.textFormat = new TextFormat(SDKInstallerTheme.DEFAULT_FONT_NAME, 16, 0xe252d3, true, true);
		this.allDownloadedLayout.addChild(lblCongratulation);

		var lblSecond = new Label("You have all features installed!");
		this.allDownloadedLayout.addChild(lblSecond);

		var successIcon = new LayoutGroup();
		successIcon.variant = SDKInstallerTheme.IMAGE_VARIANT_SUCCESS_TICK;
		successIcon.width = 53;
		successIcon.height = 50;
		this.allDownloadedLayout.addChild(successIcon);

		var lblThird = new Label("Time to go coding!");
		this.allDownloadedLayout.addChild(lblThird);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) 
		{
			if (this._filterTypeIndex == 0) {
				this.itemsListView.dataProvider = this.collectionByFeature;
			} else {
				this.itemsListView.dataProvider = this.collectionBySoftware;
			}

			this.updateShowNeedsInstallVisibility();
		}

		super.update();
	}

	public function refreshFilteredDataProvider():Void
	{
		if ((this._filterTypeIndex == 1) && this._checkShowOnlyNeedsSetup)
		{
			cast(this.itemsListView.dataProvider, ArrayCollection<Dynamic>).refresh();
			this.updateAllSuccessMessageVisibility();
		}
	}

	public function setHelperReady():Void
	{
		if (this.itemsListView.dataProvider != null)
		{
			// update icon/button states once the installer is ready
			cast(this.itemsListView.dataProvider, ArrayCollection<Dynamic>).updateAll();
		}
	}

	private function onItemBeingUpdated(event:Event):Void
	{
		var tmpIndex = this.collectionBySoftware.indexOf(event.target);
		if (tmpIndex != -1)
		{
			this.collectionBySoftware.updateAt(tmpIndex);
		}

		this.refreshFilteredDataProvider();
	}

	private function itemsListView_changeHandler(event:Event):Void {
		/*if (this.itemsListView.selectedItem == null) {
			return;
		}*/
		// this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_REFERENCE));
	}

	private function onFilterTypeChanged(event:Event):Void {
		if (this.filterTypeIndex != this.filterByGroup.selectedIndex) {
			this._filterTypeIndex = this.filterByGroup.selectedIndex;
			dispatchEvent(new Event(EVENT_FILTER_TYPE_CHANGED));

			this.updateShowNeedsInstallVisibility();
		}
	}

	private function onCheckShowFeaturesNeedsSetupChange(event:Event):Void {
		var check = cast(event.currentTarget, Check);
		if (this._checkShowOnlyNeedsSetup != check.selected) {
			this._checkShowOnlyNeedsSetup = check.selected;
			dispatchEvent(new Event(EVENT_SHOW_ONLY_NEEDS_SETUP_CHANGED));

			this.updateAllSuccessMessageVisibility();
		}
	}

	private function updateShowNeedsInstallVisibility():Void {
		this.checkShowFeaturesNeedsSetup.visible = (this._filterTypeIndex == 1);
	}

	private function updateAllSuccessMessageVisibility():Void
	{
		if ((this._filterTypeIndex == 1) && this._checkShowOnlyNeedsSetup && (this.collectionBySoftware.length == 0))
		{
			this.itemsListView.includeInLayout = this.itemsListView.visible = false;
			this.allDownloadedLayout.includeInLayout = this.allDownloadedLayout.visible = true;
		}
		else if (!this.itemsListView.includeInLayout)
		{
			this.allDownloadedLayout.includeInLayout = this.allDownloadedLayout.visible = false;
			this.itemsListView.includeInLayout = this.itemsListView.visible = true;
		}	
	}

	private function onLicenseViewRequested(event:HelperEvent):Void {
		this.dispatchEvent(event);
	}

	private function onDownloadVariantChanged(event:HelperEvent):Void {
		this.dispatchEvent(event);
	}
}
