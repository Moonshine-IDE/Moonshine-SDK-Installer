package moonshine.components.renderers;

import feathers.layout.HorizontalLayoutData;
import actionScripts.valueObjects.ComponentVO;
import feathers.controls.Label;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.controls.AssetLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AnchorLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import moonshine.theme.MoonshineTheme;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;

class ComponentRenderer extends LayoutGroupItemRenderer 
{
	private var itemImageState:AssetLoader;
	
	public function new()
	{
		super();
		buildLayout();
	}
	
	public function updateItemState(stateData:ComponentVO):Void
	{
		itemImageState.source = "/helperResources/images/icoTickLabel.png";
	}
	
	private function buildLayout():Void
	{
		this.height = 100;
	 	this.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_WHITE_BACKGROUND;
	
	    var layout = new HorizontalLayout();
	    layout.horizontalAlign = JUSTIFY;
	    layout.verticalAlign = MIDDLE;
	    layout.gap = 6.0;
	    layout.paddingTop = 4.0;
	    layout.paddingBottom = 4.0;
	    layout.paddingLeft = 6.0;
	    layout.paddingRight = 6.0;
	    this.layout = layout;
	    
	    var imageContainer = new LayoutGroup();
	    imageContainer.name = "imageContainer";
	    imageContainer.height = this.height;
	    imageContainer.width = 136;
	    imageContainer.layout = new AnchorLayout();
		this.addChild(imageContainer);
	
		var assetLoaderLayoutData = new AnchorLayoutData();
		assetLoaderLayoutData.horizontalCenter = 0.0;
		assetLoaderLayoutData.verticalCenter = 0.0;
		
	    var icon = new AssetLoader();
	    icon.layoutData = assetLoaderLayoutData;
	    icon.name = "logo";
	    imageContainer.addChild(icon);
	    
	    var titleDesContainerLayout = new VerticalLayout();
	    titleDesContainerLayout.verticalAlign = MIDDLE;
	    titleDesContainerLayout.horizontalAlign = JUSTIFY;
	    
	    var titleDesContainer = new LayoutGroup();
	    titleDesContainer.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
	    titleDesContainer.name = "titleDesContainer";
	    titleDesContainer.layout = titleDesContainerLayout;
	    titleDesContainer.layoutData = new VerticalLayoutData(100, 100);
	    this.addChild(titleDesContainer);
	
	    var label = new Label();
	    label.name = "title";
	    titleDesContainer.addChild(label);
	    
	    var description = new Label();
	    description.name = "description";
	    description.layoutData = new HorizontalLayoutData(100, null);
	    description.wordWrap = true;
	    titleDesContainer.addChild(description);
	    
	    var license = new Label();
	    license.text = "License Agreement";
	    license.variant = MoonshineTheme.THEME_VARIANT_TEXT_LINK;
	    titleDesContainer.addChild(license);
	    
	    var stateImageContainer = new LayoutGroup();		
	    stateImageContainer.name = "stateImageContainer";
	    stateImageContainer.height = this.height;
	    stateImageContainer.width = 50;
	    stateImageContainer.layout = new AnchorLayout();
		this.addChild(stateImageContainer);
		
	    this.itemImageState = new AssetLoader();
	    this.itemImageState.layoutData = assetLoaderLayoutData;
	    this.itemImageState.name = "itemImageState";
	    this.addChild(this.itemImageState);
	}
}