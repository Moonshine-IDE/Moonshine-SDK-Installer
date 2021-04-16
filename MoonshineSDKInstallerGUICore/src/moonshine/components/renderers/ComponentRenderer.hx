package moonshine.components.renderers;

import moonshine.events.HelperEvent;
import openfl.events.MouseEvent;
import actionScripts.valueObjects.HelperConstants;
import actionScripts.utils.HelperUtils;
import feathers.layout.HorizontalLayoutData;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ComponentVariantVO;
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

class ComponentRenderer extends LayoutGroup {
	private var assetDownloaded:AssetLoader;
	private var assetNote:AssetLoader;
	private var assetError:AssetLoader;
	private var assetDownload:AssetLoader;
	private var assetReDownload:AssetLoader;
	private var assetQueued:AssetLoader;
	private var assetConfigure:AssetLoader;
	private var stateData:ComponentVO;
	private var assetLogo:AssetLoader;
	private var lblTitle:Label;
	private var lblDescription:Label;
	private var lblCreatedOn:Label;

	public function new() {
		super();
	}

	public function updateItemState(stateData:ComponentVO):Void {
		this.stateData = stateData;
		this.setInvalid(InvalidationFlag.DATA);
	}

	override private function initialize():Void {
		this.height = 100;
		this.variant = SDKInstallerTheme.THEME_VARIANT_BODY_WITH_WHITE_BACKGROUND;

		var viewLayout = new HorizontalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 4.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		var imageContainer = new LayoutGroup();
		imageContainer.variant = SDKInstallerTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
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
		titleDesContainer.variant = SDKInstallerTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
		titleDesContainer.layoutData = new HorizontalLayoutData(100, null);
		this.addChild(titleDesContainer);

		this.lblTitle = new Label();
		titleDesContainer.addChild(this.lblTitle);

		this.lblDescription = new Label();
		this.lblDescription.layoutData = new HorizontalLayoutData(100, null);
		this.lblDescription.wordWrap = true;
		titleDesContainer.addChild(this.lblDescription);

		var licenseAndCreatedOnContainer = new LayoutGroup();
		licenseAndCreatedOnContainer.layout = new HorizontalLayout();
		licenseAndCreatedOnContainer.layoutData = new HorizontalLayoutData(100, null);
		titleDesContainer.addChild(licenseAndCreatedOnContainer);

		var license = new Label();
		license.text = "License Agreement";
		license.buttonMode = true;
		license.mouseChildren = false;
		license.variant = SDKInstallerTheme.THEME_VARIANT_TEXT_LINK;
		license.addEventListener(MouseEvent.CLICK, onLicenseViewRequested, false, 0, true);
		licenseAndCreatedOnContainer.addChild(license);

		this.lblCreatedOn = new Label();
		licenseAndCreatedOnContainer.addChild(this.lblCreatedOn);

		var stateImageContainer = new LayoutGroup();
		stateImageContainer.layoutData = new HorizontalLayoutData(null, 100);
		stateImageContainer.layout = new HorizontalLayout();
		cast(stateImageContainer.layout, HorizontalLayout).verticalAlign = MIDDLE;
		this.addChild(stateImageContainer);

		this.assetNote = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoNote.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetNote);

		this.assetError = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoErrorLabel.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetError);

		this.assetDownloaded = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoTickLabel.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetDownloaded);

		this.assetDownload = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoDownloadLabel.png", assetLoaderLayoutData);
		this.assetDownload.buttonMode = true;
		this.assetDownload.addEventListener(MouseEvent.CLICK, this.onDownloadButtonClicked, false, 0, true);
		stateImageContainer.addChild(this.assetDownload);

		this.assetReDownload = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoReDownload.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetReDownload);

		this.assetQueued = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoQueuedLabel.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetQueued);

		this.assetConfigure = this.getNewAssetLoaderForStateIcons("/helperResources/images/icoConfigure.png", assetLoaderLayoutData);
		stateImageContainer.addChild(this.assetConfigure);

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

	private function getNewAssetLoaderForStateIcons(srcPath:String, layoutData:AnchorLayoutData):AssetLoader {
		var tmpAsset = new AssetLoader();
		tmpAsset.layoutData = layoutData;
		tmpAsset.visible = false;
		tmpAsset.includeInLayout = false;
		tmpAsset.source = srcPath;

		return tmpAsset;
	}

	private function updateFields():Void {
		this.lblTitle.text = this.stateData.title;
		this.lblDescription.text = this.stateData.description;
		this.assetLogo.source = this.stateData.imagePath;

		if (this.stateData.isAlreadyDownloaded && (this.stateData.createdOn != null)) {
			this.lblCreatedOn.includeInLayout = true;
			this.lblCreatedOn.visible = true;
			this.lblCreatedOn.text = " | Installed: (to be calculated)";
		} else {
			this.lblCreatedOn.includeInLayout = false;
			this.lblCreatedOn.visible = false;
		}

		this.updateItemIconState();
	}

	private function resetFields():Void {
		this.lblTitle.text = "";
		this.lblDescription.text = "";
		this.assetLogo.source = null;
		this.assetDownloaded.source = null;
	}

	private function updateItemIconState():Void {
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
			this.assetDownload.alpha = this.assetDownload.enabled ? 1.0 : 0.8;
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
			this.assetReDownload.alpha = this.assetReDownload.enabled ? 1.0 : 0.8;
		} else {
			this.assetReDownload.visible = false;
			this.assetReDownload.includeInLayout = false;
		}

		if (!this.stateData.isAlreadyDownloaded && HelperConstants.IS_RUNNING_IN_MOON) {
			this.assetConfigure.visible = true;
			this.assetConfigure.includeInLayout = true;
		} else {
			this.assetConfigure.visible = false;
			this.assetConfigure.includeInLayout = false;
		}
	}

	private function onDownloadButtonClicked(event:MouseEvent):Void {
		if ((this.stateData.downloadVariants != null) && this.stateData.downloadVariants.length > 1) {
			HelperUtils.updateComponentByVariant(this.stateData,
				cast(this.stateData.downloadVariants.get(this.stateData.selectedVariantIndex), ComponentVariantVO));
		}

		this.dispatchEvent(new HelperEvent(HelperEvent.DOWNLOAD_COMPONENT, this.stateData, true));
	}

	private function onLicenseViewRequested(event:MouseEvent):Void {
		this.dispatchEvent(new HelperEvent(HelperEvent.OPEN_COMPONENT_LICENSE, this.stateData));
	}
}
