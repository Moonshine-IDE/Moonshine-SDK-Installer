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

import moonshine.haxeScripts.valueObjects.ComponentVariantVO;
import feathers.controls.dataRenderers.IDataRenderer;
import openfl.events.Event;
import actionScripts.utils.Parser;
import feathers.controls.PopUpListView;
import feathers.controls.Button;
import openfl.events.MouseEvent;
import feathers.events.TriggerEvent;
import moonshine.events.HelperEvent;
import actionScripts.valueObjects.HelperConstants;
import actionScripts.utils.HelperUtils;
import actionScripts.utils.FileUtils;
import feathers.layout.HorizontalLayoutData;
import moonshine.haxeScripts.valueObjects.ComponentVO;
import feathers.controls.Label;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.controls.AssetLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.core.InvalidationFlag;
import moonshine.theme.SDKInstallerTheme;

class ComponentRenderer extends LayoutGroup implements IDataRenderer
{
	private var assetDownloaded:LayoutGroup;
	private var assetNote:LayoutGroup;
	private var assetError:LayoutGroup;
	private var assetDownload:Button;
	private var assetReDownload:Button;
	private var assetQueued:LayoutGroup;
	private var assetConfigure:Button;
	private var assetDownloading:LayoutGroup;
	private var stateData:ComponentVO;
	private var assetLogo:AssetLoader;
	private var lblTitle:Label;
	private var lblSize:Label;
	private var lblDescription:Label;
	private var lblCreatedOn:Label;
	private var cmbVariants:PopUpListView;

	@:flash.property
	public var data(get, set):Dynamic;

	private function get_data():Dynamic {
		return this.stateData;
	}

	private function set_data(value:Dynamic):Dynamic {
		if(this.stateData == value) {
			return this.stateData;
		}
		this.stateData = cast(value, ComponentVO);
		setInvalid(InvalidationFlag.DATA);
		return stateData;
	}

	public function new() {
		super();
	}

	public function updateItemState(stateData:ComponentVO):Void {
		this.stateData = stateData;
		this.setInvalid(InvalidationFlag.DATA);
	}

	override private function initialize():Void {
		this.minHeight = 100;
		this.variant = SDKInstallerTheme.THEME_VARIANT_ROW_ITEM_BODY_WITH_WHITE_BACKGROUND;

		var viewLayout = new HorizontalLayout();
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 4.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		var imageContainer = new LayoutGroup();
		imageContainer.height = this.height;
		imageContainer.width = 136;
		imageContainer.layout = new AnchorLayout();
		this.addChild(imageContainer);

		var assetLoaderLayoutData = new AnchorLayoutData();
		assetLoaderLayoutData.horizontalCenter = 0.0;
		assetLoaderLayoutData.verticalCenter = 0.0;

		this.assetLogo = new AssetLoader();
		this.assetLogo.layoutData = assetLoaderLayoutData;
		imageContainer.addChild(this.assetLogo);

		var titleDesContainerLayout = new VerticalLayout();
		titleDesContainerLayout.verticalAlign = MIDDLE;
		titleDesContainerLayout.horizontalAlign = JUSTIFY;

		var titleDesContainer = new LayoutGroup();
		titleDesContainer.layout = titleDesContainerLayout;
		titleDesContainer.layoutData = new HorizontalLayoutData(100, null);
		this.addChild(titleDesContainer);

		var titleAndSizeContainer = new LayoutGroup();
		titleAndSizeContainer.layoutData = new HorizontalLayoutData(100, null);
		titleAndSizeContainer.layout = new HorizontalLayout();
		cast(titleAndSizeContainer.layout, HorizontalLayout).gap = 10;
		cast(titleAndSizeContainer.layout, HorizontalLayout).verticalAlign = MIDDLE;
		titleDesContainer.addChild(titleAndSizeContainer);

		this.lblTitle = new Label();
		this.lblTitle.variant = SDKInstallerTheme.THEME_VARIANT_LABEL_COMPONENT_TITLE;
		titleAndSizeContainer.addChild(this.lblTitle);

		this.lblSize = new Label();
		titleAndSizeContainer.addChild(this.lblSize);

		this.lblDescription = new Label();
		this.lblDescription.variant = SDKInstallerTheme.THEME_VARIANT_SMALLER_LABEL_12;
		this.lblDescription.layoutData = new HorizontalLayoutData(100, null);
		this.lblDescription.wordWrap = true;
		titleDesContainer.addChild(this.lblDescription);

		var licenseAndCreatedOnContainer = new LayoutGroup();
		licenseAndCreatedOnContainer.layout = new HorizontalLayout();
		licenseAndCreatedOnContainer.layoutData = new HorizontalLayoutData(100, null);
		titleDesContainer.addChild(licenseAndCreatedOnContainer);

		if (!HelperConstants.IS_RUNNING_IN_MOON)
		{
			var license = new Label();
			license.text = "License Agreement";
			license.variant = SDKInstallerTheme.THEME_VARIANT_SMALLER_LABEL_12;
			license.buttonMode = true;
			license.mouseChildren = false;
			license.variant = SDKInstallerTheme.THEME_VARIANT_TEXT_LINK;
			license.addEventListener(MouseEvent.CLICK, onLicenseViewRequested, false, 0, true);
			licenseAndCreatedOnContainer.addChild(license);
		}
		
		this.lblCreatedOn = new Label();
		this.lblCreatedOn.variant = SDKInstallerTheme.THEME_VARIANT_SMALLER_LABEL_12;
		licenseAndCreatedOnContainer.addChild(this.lblCreatedOn);

		this.cmbVariants = new PopUpListView();
		this.cmbVariants.itemToText = (item:ComponentVariantVO) -> item.title;
		this.cmbVariants.includeInLayout = this.cmbVariants.visible = false;
		this.addChild(this.cmbVariants);

		var stateImageContainer = new LayoutGroup();
		stateImageContainer.layoutData = new HorizontalLayoutData(null, 100);
		stateImageContainer.layout = new HorizontalLayout();
		cast(stateImageContainer.layout, HorizontalLayout).verticalAlign = MIDDLE;
		cast(stateImageContainer.layout, HorizontalLayout).gap = 10;
		this.addChild(stateImageContainer);

		this.assetNote = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_NOTE_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetNote.width = 46;
		this.assetNote.height = 44;
		stateImageContainer.addChild(this.assetNote);

		this.assetError = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_ERROR_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetError.width = 34;
		this.assetError.height = 44;
		stateImageContainer.addChild(this.assetError);

		this.assetDownloaded = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_DOWNLOADED_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetDownloaded.width = 42;
		this.assetDownloaded.height = 46;
		stateImageContainer.addChild(this.assetDownloaded);

		this.assetDownload = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_DOWNLOAD_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetDownload.width = 49;
		this.assetDownload.height = 48;
		this.assetDownload.addEventListener(TriggerEvent.TRIGGER, this.onDownloadButtonClicked, false, 0, true);
		stateImageContainer.addChild(this.assetDownload);

		this.assetReDownload = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetReDownload.width = 61;
		this.assetReDownload.height = 48;
		this.assetReDownload.addEventListener(TriggerEvent.TRIGGER, this.onDownloadButtonClicked, false, 0, true);
		stateImageContainer.addChild(this.assetReDownload);

		this.assetQueued = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_QUEUED_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetQueued.width = 38;
		this.assetQueued.height = 46;
		stateImageContainer.addChild(this.assetQueued);

		this.assetConfigure = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_CONFIGURE_ICON_WITH_LABEL, assetLoaderLayoutData);
		this.assetConfigure.width = 47;
		this.assetConfigure.height = 49;
		this.assetConfigure.addEventListener(TriggerEvent.TRIGGER, this.onConfigureButtonClicked, false, 0, true);
		stateImageContainer.addChild(this.assetConfigure);

		this.assetDownloading = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_DOWNLOADING_ICON, assetLoaderLayoutData);
		this.assetDownloading.width = 40;
		this.assetDownloading.height = 40;
		stateImageContainer.addChild(this.assetDownloading);

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
		this.assetLogo.source = null;
		this.cmbVariants.removeEventListener(Event.CHANGE, onVariantChange);
		this.cmbVariants.dataProvider = null;
		this.cmbVariants.includeInLayout = this.cmbVariants.visible = false;
	}

	private function getNewAssetButtonForStateIcons(variant:String, layoutData:AnchorLayoutData):Button {
		var tmpAsset = new Button();
		tmpAsset.useHandCursor = true;
		tmpAsset.layoutData = layoutData;
		tmpAsset.visible = false;
		tmpAsset.includeInLayout = false;
		tmpAsset.variant = variant;

		return tmpAsset;
	}

	private function getNewAssetLayoutForStateIcons(variant:String, layoutData:AnchorLayoutData):LayoutGroup {
		var tmpAsset = new LayoutGroup();
		tmpAsset.useHandCursor = true;
		tmpAsset.layoutData = layoutData;
		tmpAsset.visible = false;
		tmpAsset.includeInLayout = false;
		tmpAsset.variant = variant;

		return tmpAsset;
	}

	private function updateFields():Void 
	{
		this.lblTitle.text = this.stateData.title;
		this.lblDescription.text = this.stateData.description;
		this.assetLogo.source = this.stateData.imagePath;

		if ((this.stateData.variantCount != 1) && !this.stateData.isDownloading && !this.stateData.isSelectedToDownload) {
			this.cmbVariants.includeInLayout = this.cmbVariants.visible = true;
			this.cmbVariants.dataProvider = this.stateData.downloadVariants;
			this.cmbVariants.selectedIndex = this.stateData.selectedVariantIndex;
			this.cmbVariants.addEventListener(Event.CHANGE, onVariantChange, false, 0, true);
		} else {
			this.cmbVariants.dataProvider = null;
			this.cmbVariants.includeInLayout = this.cmbVariants.visible = false;
			this.cmbVariants.removeEventListener(Event.CHANGE, onVariantChange);
		}

		if (this.stateData.variantCount != 1)
		{
			this.lblSize.text = "("+ this.stateData.downloadVariants.get(this.stateData.selectedVariantIndex).displayVersion + 
				", "+ HelperUtils.getSizeFix(this.stateData.sizeInMb) +")";
		}
		else
		{
			this.lblSize.text = "("+ this.stateData.displayVersion +", "+ HelperUtils.getSizeFix(this.stateData.sizeInMb) +")";
		}

		if (this.stateData.isAlreadyDownloaded && (this.stateData.createdOn != null)) {
			this.lblCreatedOn.includeInLayout = true;
			this.lblCreatedOn.visible = true;
			this.lblCreatedOn.text = (HelperConstants.IS_RUNNING_IN_MOON ? "" : " | ") + "Installed: " + this.stateData.createdOn.toString();
		} else {
			this.lblCreatedOn.includeInLayout = false;
			this.lblCreatedOn.visible = false;
		}

		this.updateItemIconState();
	}

	private function updateItemIconState():Void 
	{
		this.assetDownloading.visible = this.stateData.isDownloading;
		this.assetDownloading.includeInLayout = this.stateData.isDownloading;

		if (this.stateData.isAlreadyDownloaded) {
			this.assetDownloaded.visible = true;
			this.assetDownloaded.includeInLayout = true;
			if (this.stateData.createdOn != null) 
			{
				this.assetDownloaded.toolTip = "Installed: " + this.stateData.createdOn.toString();
			}
		} else {
			this.assetDownloaded.visible = false;
			this.assetDownloaded.includeInLayout = false;
		}

		if ((this.stateData.oldInstalledVersion != null) || (this.stateData.hasWarning != null)) {
			this.assetNote.visible = true;
			this.assetNote.includeInLayout = true;
			this.assetNote.toolTip = (this.stateData.oldInstalledVersion != null) ? "Version Mismatch" : this.stateData.hasWarning;
		} else {
			this.assetNote.visible = false;
			this.assetNote.includeInLayout = false;
		}

		if (this.stateData.hasError != null) {
			this.assetError.visible = true;
			this.assetError.includeInLayout = true;
			this.assetError.toolTip = this.stateData.hasError;
		} else {
			this.assetError.visible = false;
			this.assetError.includeInLayout = false;
		}

		if (this.stateData.isSelectedToDownload && !this.stateData.isDownloading) {
			this.assetQueued.visible = true;
			this.assetQueued.includeInLayout = true;
		} else {
			this.assetQueued.visible = false;
			this.assetQueued.includeInLayout = false;
		}

		if (this.stateData.isDownloadable && !this.stateData.isAlreadyDownloaded && !this.stateData.isDownloading && !this.stateData.isDownloaded
			&& !this.stateData.isSelectedToDownload) {
			this.assetDownload.visible = true;
			this.assetDownload.includeInLayout = true;
			this.assetDownload.toolTip = this.stateData.hasError;
			this.assetDownload.enabled = HelperConstants.IS_RUNNING_IN_MOON
				|| (!HelperConstants.IS_RUNNING_IN_MOON && HelperConstants.IS_INSTALLER_READY);
			this.assetDownload.alpha = this.assetDownload.enabled ? 1.0 : 0.5;
		} else {
			this.assetDownload.visible = false;
			this.assetDownload.includeInLayout = false;
		}

		if ((this.stateData.downloadVariants != null)
			&& this.stateData.downloadVariants.get(this.stateData.selectedVariantIndex).isReDownloadAvailable
			&& this.stateData.isAlreadyDownloaded
			&& !this.stateData.isDownloading
			&& !this.stateData.isSelectedToDownload
			&& this.stateData.isDownloadable) {
			this.assetReDownload.visible = true;
			this.assetReDownload.includeInLayout = true;
			this.assetReDownload.toolTip = this.stateData.hasError;
			this.assetReDownload.enabled = HelperConstants.IS_RUNNING_IN_MOON
				|| (!HelperConstants.IS_RUNNING_IN_MOON && HelperConstants.IS_INSTALLER_READY);
			this.assetReDownload.alpha = this.assetReDownload.enabled ? 1.0 : 0.5;
		} else {
			this.assetReDownload.visible = false;
			this.assetReDownload.includeInLayout = false;
		}

		if ((!this.stateData.isAlreadyDownloaded && HelperConstants.IS_RUNNING_IN_MOON) || 
			((this.stateData.hasWarning != null) && HelperConstants.IS_RUNNING_IN_MOON)) 
		{
			this.assetConfigure.visible = true;
			this.assetConfigure.includeInLayout = true;
		} else {
			this.assetConfigure.visible = false;
			this.assetConfigure.includeInLayout = false;
		}
	}

	private function onDownloadButtonClicked(event:TriggerEvent):Void {
		if ((this.stateData.downloadVariants != null) && this.stateData.downloadVariants.length > 1) {
			HelperUtils.updateComponentByVariant(this.stateData,
				cast(this.stateData.downloadVariants.get(this.stateData.selectedVariantIndex), ComponentVariantVO));
		}

		this.dispatchEvent(new HelperEvent(HelperEvent.DOWNLOAD_COMPONENT, this.stateData, true));
	}

	private function onConfigureButtonClicked(event:TriggerEvent):Void
	{
		this.dispatchEvent(new HelperEvent(HelperEvent.OPEN_MOON_SETTINGS, this.stateData, true));
	}

	private function onLicenseViewRequested(event:MouseEvent):Void {
		this.dispatchEvent(new HelperEvent(HelperEvent.OPEN_COMPONENT_LICENSE, this.stateData));
	}

	private function onVariantChange(event:Event):Void 
	{
		if (!this.cmbVariants.selectedItem) return;

		var tmpVariant = cast(this.cmbVariants.selectedItem, ComponentVariantVO);
		var installToPath = Parser.getInstallDirectoryPath(this.stateData.type, tmpVariant.version);
		this.stateData.selectedVariantIndex = this.cmbVariants.selectedIndex;
		this.stateData.isDownloaded = this.stateData.isAlreadyDownloaded = HelperUtils.isValidSDKDirectoryBy(
			this.stateData.type, installToPath, this.stateData.pathValidation
			);
		this.stateData.sizeInMb = tmpVariant.sizeInMb;
		this.stateData.createdOn = FileUtils.getCreationDateForPath(installToPath);

		this.dispatchEvent(new HelperEvent(HelperEvent.DOWNLOAD_VARIANT_CHANGED,
			{ComponentVariantVO: tmpVariant, ComponentVO: this.stateData, newIndex: this.stateData.selectedVariantIndex}));
	}
}
