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

package moonshine.ui.views;

import feathers.skins.RectangleSkin;
import actionScripts.valueObjects.ComponentVO;
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
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class HelperView extends LayoutGroup
{
	public static final EVENT_FILTER_TYPE_CHANGED = "eventFilterTypeChanged";

	public function new() 
	{
		MoonshineTheme.initializeTheme();
		super();
	}
	
	private var _filterType:String;
	
	@:flash.property
	public var filterType(get, never):String;
	
	private function get_filterType():String {
		return this._filterType;
	}
	
	private var _packageList:ArrayCollection<ComponentVO> = new ArrayCollection();
	
	@:flash.property
	public var packageList(get, set):ArrayCollection<ComponentVO>;

	private function get_packageList():ArrayCollection<ComponentVO> {
		return this._packageList;
	}

	private function set_packageList(value:ArrayCollection<ComponentVO>):ArrayCollection<ComponentVO> {
		if (this._packageList == value) {
			return this._packageList;
		}
		this._packageList = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._packageList;
	}

	private var itemsListView:ListView;
	private var downloadThirdPartyButton:Button;
	private var sdkInstallerInstallationMessageLabel:Label;
	private var checkShowFeaturesNeedsSetup:Check;
	private var radioByFeature:Radio;
	private var radioBySoftware:Radio;
	
	private var bySoftwareRecycler = DisplayObjectRecycler.withFunction(
		() -> {
	    var itemRenderer = new LayoutGroupItemRenderer();
	    itemRenderer.height = 100;
	 	itemRenderer.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_WHITE_BACKGROUND;
	
	    var layout = new HorizontalLayout();
	    layout.gap = 6.0;
	    layout.paddingTop = 4.0;
	    layout.paddingBottom = 4.0;
	    layout.paddingLeft = 6.0;
	    layout.paddingRight = 6.0;
	    itemRenderer.layout = layout;
	
	    var icon = new AssetLoader();
	    icon.name = "logo";
	    itemRenderer.addChild(icon);
	
	    var label = new Label();
	    label.name = "title";
	    itemRenderer.addChild(label);
	
	    return itemRenderer;
	});
	
	private var bySoftwareRecyclerUpdateFn = (itemRenderer:LayoutGroupItemRenderer, state:ListViewItemState) -> 
	{
	    var label = cast(itemRenderer.getChildByName("title"), Label);
	    var loader = cast(itemRenderer.getChildByName("logo"), AssetLoader);
	
	    label.text = state.data.title;
	    loader.source = state.data.imagePath;
	};
	
	private var bySoftwareRecyclerResetFn = (itemRenderer:LayoutGroupItemRenderer, state:ListViewItemState) -> 
	{
	    var label = cast(itemRenderer.getChildByName("title"), Label);
	    var loader = cast(itemRenderer.getChildByName("logo"), AssetLoader);
	    label.text = "";
	    loader.source = null;
	};

	override private function initialize():Void 
	{
		this.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
		
		// root container
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = CENTER;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 4.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;
		
		var optionsViewContainer = new LayoutGroup();
		optionsViewContainer.layoutData = new VerticalLayoutData(100, null);
		optionsViewContainer.layout = new AnchorLayout();
		this.addChild(optionsViewContainer);
		
		this.checkShowFeaturesNeedsSetup = new Check();
		this.checkShowFeaturesNeedsSetup.text = "Only show features that need setup";
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
		this.radioByFeature.addEventListener(Event.CHANGE, onFilterTypeChanged);
		this.radioBySoftware = new Radio();
		this.radioBySoftware.text = "By Software";
		this.radioBySoftware.selected = true;
		this.radioBySoftware.addEventListener(Event.CHANGE, onFilterTypeChanged);
		radioContainer.addChild(this.radioByFeature);
		radioContainer.addChild(this.radioBySoftware);
		
		this.itemsListView = new ListView();
		this.itemsListView.itemRendererRecycler = this.bySoftwareRecycler;
		this.bySoftwareRecycler.update = this.bySoftwareRecyclerUpdateFn;
		this.bySoftwareRecycler.reset = this.bySoftwareRecyclerResetFn;
		this.itemsListView.layoutData = new VerticalLayoutData(100, 100);
		//this.itemsListView.addEventListener(Event.CHANGE, itemsListView_changeHandler);
		this.addChild(this.itemsListView);

		super.initialize();
	}

	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) 
		{
			this.itemsListView.dataProvider = this._packageList;
		}

		super.update();
	}

	private function itemsListView_changeHandler(event:Event):Void 
	{
		/*if (this.itemsListView.selectedItem == null) {
			return;
		}*/
		//this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_REFERENCE));
	}
	
	private function onFilterTypeChanged(event:Event):Void
	{
		var radio = cast(event.currentTarget, Radio);
		this._filterType = radio.text;
		dispatchEvent(new Event(EVENT_FILTER_TYPE_CHANGED));
	}
}