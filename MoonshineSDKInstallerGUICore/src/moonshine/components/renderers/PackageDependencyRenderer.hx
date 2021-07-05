package moonshine.components.renderers;

import feathers.controls.dataRenderers.IDataRenderer;
import actionScripts.utils.Parser;
import feathers.events.TriggerEvent;
import feathers.controls.PopUpListView;
import openfl.events.Event;
import feathers.controls.TextInput;
import feathers.controls.Button;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.controls.ListView;
import moonshine.events.HelperEvent;
import actionScripts.valueObjects.HelperConstants;
import actionScripts.utils.HelperUtils;
import actionScripts.utils.FileUtils;
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

class PackageDependencyRenderer extends LayoutGroup implements IDataRenderer {
	private var assetDownloaded:LayoutGroup;
	private var assetNote:LayoutGroup;
	private var assetError:LayoutGroup;
	private var assetDownload:Button;
	private var assetReDownload:Button;
	private var assetQueued:LayoutGroup;
	private var assetConfigure:Button;
	private var stateData:ComponentVO;
	private var lblTitle:Label;
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

	override private function initialize():Void {
		this.height = 40;
		this.variant = SDKInstallerTheme.THEME_VARIANT_RENDERER_PACKAGE_DEPENDENCY;

		var viewLayout = new HorizontalLayout();
		viewLayout.horizontalAlign = RIGHT;
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.paddingTop = 0.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 0.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.cmbVariants = new PopUpListView();
		this.cmbVariants.itemToText = (item:ComponentVariantVO) -> item.title;
		this.cmbVariants.includeInLayout = this.cmbVariants.visible = false;
		this.addChild(this.cmbVariants);

		var assetLoaderLayoutData = new AnchorLayoutData();
		assetLoaderLayoutData.horizontalCenter = 0.0;
		assetLoaderLayoutData.verticalCenter = 0.0;

		var titleDesContainerLayout = new VerticalLayout();
		titleDesContainerLayout.verticalAlign = MIDDLE;
		titleDesContainerLayout.horizontalAlign = RIGHT;

		var titleDesContainer = new LayoutGroup();
		titleDesContainer.layout = titleDesContainerLayout;
		titleDesContainer.variant = SDKInstallerTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
		titleDesContainer.layoutData = new HorizontalLayoutData(100, null);
		//this.addChild(titleDesContainer);

		this.lblTitle = new Label();
		this.addChild(this.lblTitle);

		var stateImageContainer = new LayoutGroup();
		stateImageContainer.layout = new HorizontalLayout();
		cast(stateImageContainer.layout, HorizontalLayout).verticalAlign = MIDDLE;
		cast(stateImageContainer.layout, HorizontalLayout).horizontalAlign = RIGHT;
		cast(stateImageContainer.layout, HorizontalLayout).gap = 4;
		stateImageContainer.layoutData = new HorizontalLayoutData(null, 100);
		this.addChild(stateImageContainer);

		this.assetNote = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_NOTE_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetNote.width = 32;
		this.assetNote.height = 32;
		stateImageContainer.addChild(this.assetNote);

		this.assetError = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_ERROR_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetError.width = 33;
		this.assetError.height = 32;
		stateImageContainer.addChild(this.assetError);

		this.assetDownloaded = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_DOWNLOADED_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetDownloaded.width = 36;
		this.assetDownloaded.height = 32;
		stateImageContainer.addChild(this.assetDownloaded);

		this.assetDownload = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_DOWNLOAD_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetDownload.width = 42;
		this.assetDownload.height = 32;
		this.assetDownload.addEventListener(TriggerEvent.TRIGGER, this.onDownloadButtonClicked, false, 0, true);
		stateImageContainer.addChild(this.assetDownload);

		this.assetReDownload = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetReDownload.width = 41;
		this.assetReDownload.height = 32;
		this.assetReDownload.addEventListener(TriggerEvent.TRIGGER, this.onDownloadButtonClicked, false, 0, true);
		this.assetReDownload.toolTip = "Re-download";
		stateImageContainer.addChild(this.assetReDownload);

		this.assetQueued = this.getNewAssetLayoutForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_QUEUED_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetQueued.width = 33;
		this.assetQueued.height = 32;
		stateImageContainer.addChild(this.assetQueued);

		this.assetConfigure = this.getNewAssetButtonForStateIcons(SDKInstallerTheme.IMAGE_VARIANT_CONFIGURE_ICON_WITH_NO_LABEL, assetLoaderLayoutData);
		this.assetConfigure.width = 32;
		this.assetConfigure.height = 32;
		this.assetConfigure.addEventListener(TriggerEvent.TRIGGER, this.onConfigureButtonClicked, false, 0, true);
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

	public function resetFields():Void {
		this.lblTitle.text = "";
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

	private function updateFields():Void {
		this.lblTitle.text = this.stateData.title;
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

		this.updateItemIconState();
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

		if (HelperConstants.IS_RUNNING_IN_MOON) {
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

		this.setInvalid(InvalidationFlag.DATA);

		this.dispatchEvent(new HelperEvent(HelperEvent.DOWNLOAD_VARIANT_CHANGED,
			{ComponentVariantVO: this.cmbVariants.selectedItem, ComponentVO: this.stateData, newIndex: this.cmbVariants.selectedIndex}));
	}
}
