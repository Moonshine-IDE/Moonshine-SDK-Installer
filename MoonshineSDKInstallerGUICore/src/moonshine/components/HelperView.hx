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

package moonshine.components;

import moonshine.components.renderers.PackageRenderer;
import moonshine.components.renderers.ComponentRenderer;
import feathers.layout.HorizontalLayoutData;
import openfl.display.StageScaleMode;
import actionScripts.valueObjects.PackageVO;
import feathers.core.ToggleGroup;
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
	public static final EVENT_SHOW_ONLY_NEEDS_SETUP_CHANGED = "eventShowOnlyNeedsSetupChanged";

	public function new() 
	{
		MoonshineTheme.initializeTheme();
		super();
	}
	
	public function setListPropertiesBySoftwareType(withCollection:ArrayCollection<ComponentVO>):Void
	{
		this.itemsListView.itemRendererRecycler = this.bySoftwareRecycler;
		this.bySoftwareRecycler.update = this.bySoftwareRecyclerUpdateFn;
		this.bySoftwareRecycler.reset = this.bySoftwareRecyclerResetFn;
		
		this.collectionBySoftware = withCollection;
		this.setInvalid(InvalidationFlag.DATA);
	}
	
	public function setListPropertiesByFeatureType(withCollection:ArrayCollection<PackageVO>):Void
	{
		this.itemsListView.itemRendererRecycler = this.byFeatureRecycler;
		this.byFeatureRecycler.update = this.byFeatureRecyclerUpdateFn;
		this.byFeatureRecycler.reset = this.byFeatureRecyclerResetFn;
		
		this.collectionByFeature = withCollection;
		this.setInvalid(InvalidationFlag.DATA);
	}
	
	private var _filterTypeIndex:Int = 1;
	
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
	private var downloadThirdPartyButton:Button;
	private var sdkInstallerInstallationMessageLabel:Label;
	private var checkShowFeaturesNeedsSetup:Check;
	private var radioByFeature:Radio;
	private var radioBySoftware:Radio;
	private var filterByGroup = new ToggleGroup();
	private var collectionBySoftware:ArrayCollection<ComponentVO> = new ArrayCollection();
	private var collectionByFeature:ArrayCollection<PackageVO> = new ArrayCollection();
	
	private var byFeatureRecycler = DisplayObjectRecycler.withFunction(
		() -> {    
	    return (new PackageRenderer());
	});
	
	private var byFeatureRecyclerUpdateFn = (itemRenderer:LayoutGroupItemRenderer, state:ListViewItemState) -> 
	{
	    var titleDesContainer = cast(itemRenderer.getChildByName("titleDesContainer"), LayoutGroup);
	    var label = cast(titleDesContainer.getChildByName("title"), Label);
	    var description = cast(titleDesContainer.getChildByName("description"), Label);
	
	    label.text = state.data.title;
	    description.text = state.data.description;
	    
	};
	
	private var byFeatureRecyclerResetFn = (itemRenderer:LayoutGroupItemRenderer, state:ListViewItemState) -> 
	{
	    var titleDesContainer = cast(itemRenderer.getChildByName("titleDesContainer"), LayoutGroup);
	    var label = cast(titleDesContainer.getChildByName("title"), Label);
	    var description = cast(titleDesContainer.getChildByName("description"), Label);
	
	    label.text = "";
	    description.text = "";
	};
	
	private var bySoftwareRecycler = DisplayObjectRecycler.withFunction(
		() -> {
	    return (new ComponentRenderer());
	});
	
	private var bySoftwareRecyclerUpdateFn = (itemRenderer:ComponentRenderer, state:ListViewItemState) -> 
	{
	    itemRenderer.updateItemState(cast(state.data, ComponentVO));
	};
	
	private var bySoftwareRecyclerResetFn = (itemRenderer:ComponentRenderer, state:ListViewItemState) -> 
	{
	    itemRenderer.updateItemState(null);
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
		this.radioBySoftware.selected = true;
		this.radioBySoftware.toggleGroup = this.filterByGroup;
		radioContainer.addChild(this.radioByFeature);
		radioContainer.addChild(this.radioBySoftware);
		
		this.filterByGroup.addEventListener(Event.CHANGE, onFilterTypeChanged, false, 0, true);
		
		this.itemsListView = new ListView();
		this.itemsListView.layoutData = new VerticalLayoutData(100, 100);
		this.addChild(this.itemsListView);

		super.initialize();
	}

	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) 
		{
			if (this._filterTypeIndex == 0)
			{
				this.itemsListView.dataProvider = this.collectionByFeature;
			}
			else
			{
				this.itemsListView.dataProvider = this.collectionBySoftware;
			}
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
		if (this.filterTypeIndex != this.filterByGroup.selectedIndex)
		{
			this._filterTypeIndex = this.filterByGroup.selectedIndex;
			dispatchEvent(new Event(EVENT_FILTER_TYPE_CHANGED));
		}
	}
	
	private function onCheckShowFeaturesNeedsSetupChange(event:Event):Void
	{
		var check = cast(event.currentTarget, Check);
		if (this._checkShowOnlyNeedsSetup != check.selected)
		{
			this._checkShowOnlyNeedsSetup = check.selected;
			dispatchEvent(new Event(EVENT_SHOW_ONLY_NEEDS_SETUP_CHANGED));
		}
	}
}