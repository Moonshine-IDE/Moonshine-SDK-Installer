/*
	Copyright 2020 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.theme;

import actionScripts.valueObjects.HelperConstants;
import feathers.controls.ListView;
import feathers.graphics.LineStyle;
import feathers.graphics.FillStyle;
import feathers.skins.UnderlineSkin;
import openfl.geom.Matrix;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.controls.Button;
import feathers.controls.Callout;
import feathers.controls.Check;
import feathers.controls.HScrollBar;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.Radio;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.VScrollBar;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.ClassVariantTheme;
import moonshine.style.MoonshineButtonSkin;
import openfl.display.Shape;
import openfl.filters.GlowFilter;
import openfl.text.TextFormat;
import openfl.display.GradientType;
import moonshine.theme.assets.DownloadIconWithLabel;
import moonshine.theme.assets.DownloadIconWithoutLabel;
import moonshine.theme.assets.NoteIconWithLabel;
import moonshine.theme.assets.NoteIconWithoutLabel;
import moonshine.theme.assets.DownloadedIconWithLabel;
import moonshine.theme.assets.DownloadedIconWithoutLabel;
import moonshine.theme.assets.ErrorIconWithLabel;
import moonshine.theme.assets.ErrorIconWithoutLabel;
import moonshine.theme.assets.ConfigureIconWithLabel;
import moonshine.theme.assets.ConfigureIconWithoutLabel;
import moonshine.theme.assets.QueuedIconWithLabel;
import moonshine.theme.assets.QueuedIconWithoutLabel;
import moonshine.theme.assets.RedownloadIconWithLabel;
import moonshine.theme.assets.RedownloadIconWithoutLabel;
import moonshine.theme.assets.DownloadingIcon;

class SDKInstallerTheme extends ClassVariantTheme {
	private static var _instance:SDKInstallerTheme;

	public static function initializeTheme():Void {
		if (_instance != null) {
			return;
		}
		_instance = new SDKInstallerTheme();
		Theme.setTheme(_instance);
	}

	public static final THEME_VARIANT_SMALLER_LABEL_12:String = "msdki-label-smaller-sized-12";
	public static final THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR = "moonshine-title-window-control-bar";
	public static final THEME_VARIANT_WARNING_BAR:String = "moonshine-warning-bar";
	public static final THEME_VARIANT_BODY_WITH_GREY_BACKGROUND:String = "moonshine-layoutgroup-grey-background";
	public static final THEME_VARIANT_ROW_ITEM_BODY_WITH_WHITE_BACKGROUND = "moonshine-layoutgroup-rowItem-white-background";
	public static final THEME_VARIANT_TEXT_LINK:String = "moonshine-standard-text-link";
	public static final THEME_VARIANT_LABEL_COMPONENT_TITLE:String = "moonshine-label-item-title";
	public static final THEME_VARIANT_RENDERER_PACKAGE_DEPENDENCY:String = "msdki-package-dependency-renderer";
	
	public static final IMAGE_VARIANT_DOWNLOAD_ICON_WITH_LABEL:String = "image-icon-download-with-label";
	public static final IMAGE_VARIANT_DOWNLOAD_ICON_WITH_NO_LABEL:String = "image-icon-download-with-no-label";
	public static final IMAGE_VARIANT_NOTE_ICON_WITH_LABEL:String = "image-icon-note-with-label";
	public static final IMAGE_VARIANT_NOTE_ICON_WITH_NO_LABEL:String = "image-icon-note-with-no-label";
	public static final IMAGE_VARIANT_DOWNLOADED_ICON_WITH_LABEL:String = "image-icon-downloaded-with-label";
	public static final IMAGE_VARIANT_DOWNLOADED_ICON_WITH_NO_LABEL:String = "image-icon-downloaded-with-no-label";
	public static final IMAGE_VARIANT_ERROR_ICON_WITH_LABEL:String = "image-icon-error-with-label";
	public static final IMAGE_VARIANT_ERROR_ICON_WITH_NO_LABEL:String = "image-icon-error-with-no-label";
	public static final IMAGE_VARIANT_CONFIGURE_ICON_WITH_LABEL:String = "image-icon-configure-with-label";
	public static final IMAGE_VARIANT_CONFIGURE_ICON_WITH_NO_LABEL:String = "image-icon-configure-with-no-label";
	public static final IMAGE_VARIANT_QUEUED_ICON_WITH_LABEL:String = "image-icon-queued-with-label";
	public static final IMAGE_VARIANT_QUEUED_ICON_WITH_NO_LABEL:String = "image-icon-queued-with-no-label";
	public static final IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_LABEL:String = "image-icon-redownload-with-label";
	public static final IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_NO_LABEL:String = "image-icon-redownload-with-no-label";
	public static final IMAGE_VARIANT_DOWNLOADING_ICON:String = "image-icon-downloading";

	public static final DEFAULT_FONT_NAME:String = (HelperConstants.IS_MACOS) ? "System Font" : "Calibri";

	public function new() {
		super();

		this.styleProvider.setStyleFunction(Callout, null, setCalloutStyles);
		this.styleProvider.setStyleFunction(Check, null, setCheckStyles);

		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_SMALLER_LABEL_12, setSmaller12LabelStyles);

		this.styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDERLESS, setBorderlessListViewStyles);

		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_BODY_WITH_GREY_BACKGROUND, setBodyWithGreyBackgroundViewStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_ROW_ITEM_BODY_WITH_WHITE_BACKGROUND, setRowItemBodyWithWhiteBackgroundViewStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_RENDERER_PACKAGE_DEPENDENCY, setRowPackageDependencyViewStyle);

		this.styleProvider.setStyleFunction(TextInput, null, setTextInputStyles);

		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_LABEL_COMPONENT_TITLE, setComponentTitleLabelStyle);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_TEXT_LINK, setTextLinkyLabelStyles);

		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_DOWNLOAD_ICON_WITH_LABEL, setImageDownloadWithLabelStyles);
		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_DOWNLOAD_ICON_WITH_NO_LABEL, setImageDownloadWithoutLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_NOTE_ICON_WITH_LABEL, setImageNoteWithLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_NOTE_ICON_WITH_NO_LABEL, setImageNoteWithoutLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_DOWNLOADED_ICON_WITH_LABEL, setImageDownloadedWithLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_DOWNLOADED_ICON_WITH_NO_LABEL, setImageDownloadedWithoutLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_ERROR_ICON_WITH_LABEL, setImageErrorWithLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_ERROR_ICON_WITH_NO_LABEL, setImageErrorWithoutLabelStyles);
		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_CONFIGURE_ICON_WITH_LABEL, setImageConfigureWithLabelStyles);
		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_CONFIGURE_ICON_WITH_NO_LABEL, setImageConfigureWithoutLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_QUEUED_ICON_WITH_LABEL, setImageQueuedWithLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_QUEUED_ICON_WITH_NO_LABEL, setImageQueuedWithoutLabelStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, IMAGE_VARIANT_DOWNLOADING_ICON, setImageDownloadingStyles);
		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_LABEL, setImageRedownloadWithLabelStyles);
		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_REDOWNLOAD_ICON_WITH_NO_LABEL, setImageRedownloadWithoutLabelStyles);
	}

	private function setCalloutStyles(callout:Callout):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xA0A0A0);
		backgroundSkin.border = SolidColor(1.0, 0x292929);
		backgroundSkin.cornerRadius = 7.0;
		callout.backgroundSkin = backgroundSkin;
	}

	private function setCheckStyles(check:Check):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x000000, 0.0);
		backgroundSkin.border = null;
		check.backgroundSkin = backgroundSkin;

		var icon = new MoonshineButtonSkin();
		icon.outerBorderFill = SolidColor(0x666666);
		icon.outerBorderSize = 2.0;
		icon.outerBorderRadius = 2.0;
		icon.innerBorderFill = SolidColor(0xFFFFFF);
		icon.innerBorderSize = 1.0;
		icon.innerBorderRadius = 1.0;
		icon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		icon.borderRadius = 1.0;
		icon.width = 20.0;
		icon.height = 20.0;
		check.icon = icon;

		var disabledIcon = new MoonshineButtonSkin();
		disabledIcon.outerBorderFill = SolidColor(0xCCCCCC);
		disabledIcon.outerBorderSize = 2.0;
		disabledIcon.outerBorderRadius = 2.0;
		disabledIcon.innerBorderFill = SolidColor(0xFFFFFF);
		disabledIcon.innerBorderSize = 1.0;
		disabledIcon.innerBorderRadius = 1.0;
		disabledIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledIcon.borderRadius = 1.0;
		disabledIcon.alpha = 0.5;
		disabledIcon.width = 20.0;
		disabledIcon.height = 20.0;
		check.disabledIcon = disabledIcon;

		var downIcon = new MoonshineButtonSkin();
		downIcon.outerBorderFill = SolidColor(0x666666);
		downIcon.outerBorderSize = 2.0;
		downIcon.outerBorderRadius = 2.0;
		downIcon.innerBorderFill = SolidColor(0xFFFFFF);
		downIcon.innerBorderSize = 1.0;
		downIcon.innerBorderRadius = 1.0;
		downIcon.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downIcon.borderRadius = 1.0;
		downIcon.alpha = 0.5;
		downIcon.width = 20.0;
		downIcon.height = 20.0;
		check.setIconForState(DOWN(false), downIcon);

		var selectedIcon = new MoonshineButtonSkin();
		selectedIcon.outerBorderFill = SolidColor(0x666666);
		selectedIcon.outerBorderSize = 2.0;
		selectedIcon.outerBorderRadius = 2.0;
		selectedIcon.innerBorderFill = SolidColor(0xFFFFFF);
		selectedIcon.innerBorderSize = 1.0;
		selectedIcon.innerBorderRadius = 1.0;
		selectedIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedIcon.borderRadius = 1.0;
		selectedIcon.width = 20.0;
		selectedIcon.height = 20.0;
		check.selectedIcon = selectedIcon;
		var checkMark = new Shape();
		checkMark.graphics.beginFill(0x292929);
		checkMark.graphics.drawRect(-0.0, -7.0, 3.0, 13.0);
		checkMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
		checkMark.graphics.endFill();
		checkMark.rotation = 45.0;
		checkMark.x = 10.0;
		checkMark.y = 9.0;
		selectedIcon.addChild(checkMark);

		var selectedDownIcon = new MoonshineButtonSkin();
		selectedDownIcon.outerBorderFill = SolidColor(0x666666);
		selectedDownIcon.outerBorderSize = 2.0;
		selectedDownIcon.outerBorderRadius = 2.0;
		selectedDownIcon.innerBorderFill = SolidColor(0xFFFFFF);
		selectedDownIcon.innerBorderSize = 1.0;
		selectedDownIcon.innerBorderRadius = 1.0;
		selectedDownIcon.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedDownIcon.borderRadius = 1.0;
		selectedDownIcon.alpha = 0.5;
		selectedDownIcon.width = 20.0;
		selectedDownIcon.height = 20.0;
		check.setIconForState(DOWN(true), selectedDownIcon);
		var downCheckMark = new Shape();
		downCheckMark.graphics.beginFill(0x292929);
		downCheckMark.graphics.drawRect(-0.0, -7.0, 3.0, 13.0);
		downCheckMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
		downCheckMark.graphics.endFill();
		downCheckMark.rotation = 45.0;
		downCheckMark.x = 10.0;
		downCheckMark.y = 9.0;
		selectedDownIcon.addChild(downCheckMark);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		focusRectSkin.cornerRadius = 4.0;
		check.focusRectSkin = focusRectSkin;
		check.focusPaddingTop = 2.0;
		check.focusPaddingRight = 2.0;
		check.focusPaddingBottom = 2.0;
		check.focusPaddingLeft = 2.0;

		// check.textFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x292929);
		// check.disabledTextFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x999999);
		// check.embedFonts = true;

		check.horizontalAlign = LEFT;
		check.textFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x292929);
		check.gap = 4.0;
	}

	private function setSmaller12LabelStyles(label:Label):Void {
		label.textFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x292929);
		label.disabledTextFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x999999);
		//label.embedFonts = true;
	}

	private function setTextLinkyLabelStyles(label:Label):Void {
		label.textFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0x0000ff, false, false, true);
	}

	private function setBodyWithGreyBackgroundViewStyles(view:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xf5f5f5);
		backgroundSkin.cornerRadius = 0.0;
		view.backgroundSkin = backgroundSkin;
	}

	private function setRowItemBodyWithWhiteBackgroundViewStyles(view:LayoutGroup):Void
	{
		var backgroundSkin = new UnderlineSkin(SolidColor(0xffffff), SolidColor(1.0, 0xcccccc));
		view.backgroundSkin = backgroundSkin;
	}

	private function setRowPackageDependencyViewStyle(layout:LayoutGroup):Void
	{
		layout.backgroundSkin = new UnderlineSkin(Gradient(LINEAR, [0xffffff, 0xe4e4e4], [1.0, 1.0], [0, 255]), SolidColor(1.0, 0xf4f4f4));
	}

	private function setComponentTitleLabelStyle(label:Label):Void
	{
		label.textFormat = new TextFormat(DEFAULT_FONT_NAME, 16, 0x000000);
		//label.embedFonts = true;
	}

	public function setTextInputStyles(textInput:TextInput):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x464646);
		backgroundSkin.border = SolidColor(1.0, 0x666666);
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		textInput.backgroundSkin = backgroundSkin;

		textInput.textFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0xf3f3f3);
		textInput.promptTextFormat = new TextFormat(DEFAULT_FONT_NAME, 12, 0xa6a6a6);
		textInput.setTextFormatForState(DISABLED, new TextFormat(DEFAULT_FONT_NAME, 12, 0x555555));
		//textInput.embedFonts = true;

		textInput.paddingTop = 5.0;
		textInput.paddingRight = 5.0;
		textInput.paddingBottom = 5.0;
		textInput.paddingLeft = 5.0;
	}

	public function setBorderlessListViewStyles(listView:ListView):Void 
	{
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = null;
		backgroundSkin.border = null;
		listView.backgroundSkin = backgroundSkin;

		var layout = new VerticalListLayout();
		listView.layout = layout;

		listView.fixedScrollBars = false;
	}

	private function setImageDownloadWithLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new DownloadIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageDownloadWithoutLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new DownloadIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageNoteWithLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new NoteIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageNoteWithoutLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new NoteIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageDownloadedWithLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new DownloadedIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageDownloadedWithoutLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new DownloadedIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageErrorWithLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new ErrorIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageErrorWithoutLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new ErrorIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageConfigureWithLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new ConfigureIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageConfigureWithoutLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new ConfigureIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageQueuedWithLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new QueuedIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageQueuedWithoutLabelStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new QueuedIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageDownloadingStyles(layout:LayoutGroup):Void 
	{
		var downloadIconBitmap = new DownloadingIcon(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageRedownloadWithLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new RedownloadIconWithLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setImageRedownloadWithoutLabelStyles(layout:Button):Void 
	{
		var downloadIconBitmap = new RedownloadIconWithoutLabel(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(downloadIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}
}
