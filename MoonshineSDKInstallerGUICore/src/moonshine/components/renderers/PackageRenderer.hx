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
package moonshine.components.renderers;

import openfl.events.Event;
import feathers.controls.dataRenderers.IDataRenderer;
import moonshine.events.HelperEvent;
import openfl.display.DisplayObject;
import feathers.data.ListViewItemState;
import moonshine.haxeScripts.valueObjects.ComponentVO;
import feathers.utils.DisplayObjectRecycler;
import feathers.controls.ListView;
import feathers.layout.HorizontalLayoutData;
import moonshine.haxeScripts.valueObjects.PackageVO;
import feathers.controls.Label;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.controls.AssetLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import moonshine.theme.SDKInstallerTheme;
import feathers.core.InvalidationFlag;

class PackageRenderer extends LayoutGroup implements IDataRenderer {
	private var lblTitle:Label;
	private var lblDescription:Label;
	private var stateData:PackageVO;
	private var stateImageContainer:LayoutGroup;
	private var lstDependencyTypes:ListView;
	private var packageDependencyRendererRecycler:DisplayObjectRecycler<Dynamic, ListViewItemState, DisplayObject>;

	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this.stateData;
	}

	private function set_data(value:Dynamic):Dynamic {
		if(this.stateData == value) {
			return this.stateData;
		}
		this.stateData = cast(value, PackageVO);
		setInvalid(InvalidationFlag.DATA);
		return stateData;
	}

	public function new() {
		super();

		this.packageDependencyRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new PackageDependencyRenderer();
			itemRenderer.addEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged, false, 0, true);
			return itemRenderer;
		}, (itemRenderer:PackageDependencyRenderer, state:ListViewItemState) -> {
			state.data.addEventListener("isUpdated", this.onItemBeingUpdated, false, 0, true);
		},
		(itemRenderer:PackageDependencyRenderer, state:ListViewItemState) -> {
			state.data.removeEventListener("isUpdated", this.onItemBeingUpdated);
			itemRenderer.resetFields();
		}, 
		(itemRenderer:PackageDependencyRenderer) -> {
			itemRenderer.removeEventListener(HelperEvent.DOWNLOAD_VARIANT_CHANGED, onDownloadVariantChanged);
		});
	}

	override private function initialize():Void {
		this.minHeight = 100;
		this.variant = SDKInstallerTheme.THEME_VARIANT_ROW_ITEM_BODY_WITH_WHITE_BACKGROUND;

		var viewLayout = new HorizontalLayout();
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.paddingTop = 1.0;
		viewLayout.paddingRight = 0.0;
		viewLayout.paddingBottom = 1.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		var titleDesContainerLayout = new VerticalLayout();
		titleDesContainerLayout.verticalAlign = MIDDLE;

		var titleDesContainer = new LayoutGroup();
		titleDesContainer.layout = titleDesContainerLayout;
		titleDesContainer.layoutData = new HorizontalLayoutData(100, 100);
		this.addChild(titleDesContainer);

		this.lblTitle = new Label();
		this.lblTitle.variant = SDKInstallerTheme.THEME_VARIANT_LABEL_COMPONENT_TITLE;
		titleDesContainer.addChild(this.lblTitle);

		this.lblDescription = new Label();
		this.lblDescription.variant = SDKInstallerTheme.THEME_VARIANT_SMALLER_LABEL_12;
		this.lblDescription.layoutData = new VerticalLayoutData(100, null);
		this.lblDescription.wordWrap = true;
		titleDesContainer.addChild(this.lblDescription);

		this.lstDependencyTypes = new ListView();
		this.lstDependencyTypes.variant = ListView.VARIANT_BORDERLESS;
		this.lstDependencyTypes.itemRendererRecycler = this.packageDependencyRendererRecycler;
		this.lstDependencyTypes.layoutData = new HorizontalLayoutData(100, null);
		this.lstDependencyTypes.visible = this.lstDependencyTypes.includeInLayout = false;
		this.addChild(this.lstDependencyTypes);

		this.stateImageContainer = new LayoutGroup();
		this.stateImageContainer.width = 50;
		this.stateImageContainer.visible = false;
		this.stateImageContainer.includeInLayout = false;
		this.stateImageContainer.layout = new HorizontalLayout();
		this.addChild(this.stateImageContainer);

		var assetLoaderLayoutData = new AnchorLayoutData();
		assetLoaderLayoutData.horizontalCenter = 0.0;
		assetLoaderLayoutData.verticalCenter = 0.0;

		var assetTick = new LayoutGroup();
		assetTick.width = 42;
		assetTick.height = 46;
		assetTick.variant = SDKInstallerTheme.IMAGE_VARIANT_DOWNLOADED_ICON_WITH_LABEL;
		assetTick.layoutData = assetLoaderLayoutData;
		this.stateImageContainer.addChild(assetTick);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		if (dataInvalid) {
			if (this.stateData != null) {
				this.updateFields();
			} else {
				this.resetFields();
			}
		}

		super.update();
	}

	public function resetFields():Void {
		this.lblTitle.text = "";
		this.lblDescription.text = "";

		this.stateImageContainer.includeInLayout = false;
		this.stateImageContainer.visible = false;

		//this.lstDependencyTypes.dataProvider = null;
		this.lstDependencyTypes.visible = this.lstDependencyTypes.includeInLayout = false;
	}

	private function updateFields():Void {
		this.lblTitle.text = this.stateData.title;
		this.lblDescription.text = this.stateData.description;

		this.stateImageContainer.includeInLayout = this.stateData.isIntegrated;
		this.stateImageContainer.visible = this.stateData.isIntegrated;

		if (this.stateData.dependencyTypes != null) {
			this.lstDependencyTypes.visible = this.lstDependencyTypes.includeInLayout = true;
			this.lstDependencyTypes.dataProvider = this.stateData.dependencyTypes;
			this.lstDependencyTypes.height = this.stateData.dependencyTypes.length * 40;
		} else {
			this.lstDependencyTypes.dataProvider = null;
			this.lstDependencyTypes.visible = this.lstDependencyTypes.includeInLayout = false;
		}
	}

	private function onItemBeingUpdated(event:Event):Void
	{
		if (this.stateData != null)
		{
			var tmpIndex = this.stateData.dependencyTypes.indexOf(event.target);
			if (tmpIndex != -1)
			{
				this.stateData.dependencyTypes.updateAt(tmpIndex);
			}
		}	
	}

	private function onDownloadVariantChanged(event:HelperEvent):Void {
		dispatchEvent(event);
	}
}
