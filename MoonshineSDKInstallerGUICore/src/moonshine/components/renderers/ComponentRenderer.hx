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
import feathers.core.InvalidationFlag;
import moonshine.theme.MoonshineTheme;

class ComponentRenderer extends LayoutGroup 
{
	private var itemImageState:AssetLoader;
	private var itemImageNote:AssetLoader;
	private var stateData:ComponentVO;
	private var assetLogo:AssetLoader;
	private var lblTitle:Label;
	private var lblDescription:Label;
	
	public function new()
	{
		super();
	}
	
	public function updateItemState(stateData:ComponentVO):Void
	{
		this.stateData = stateData;
		this.setInvalid(InvalidationFlag.DATA);
	}
	
	override private function initialize():Void
	{
		this.height = 100;
	 	this.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_WHITE_BACKGROUND;
	    this.layout = new AnchorLayout();
	    
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
	    
	    var titleDesContainerLayoutData = new AnchorLayoutData();
	    titleDesContainerLayoutData.left = 136;
	    titleDesContainerLayoutData.right = 50;
	    titleDesContainerLayoutData.verticalCenter = 0.0;
	    
	    var titleDesContainer = new LayoutGroup();
	    titleDesContainer.layout = titleDesContainerLayout;
	    titleDesContainer.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
	    titleDesContainer.layoutData = titleDesContainerLayoutData;
	    this.addChild(titleDesContainer);
	
	    this.lblTitle = new Label();
	    titleDesContainer.addChild(this.lblTitle);
	    
	    this.lblDescription = new Label();
	    this.lblDescription.layoutData = new HorizontalLayoutData(100, null);
	    this.lblDescription.wordWrap = true;
	    titleDesContainer.addChild(this.lblDescription);
	    
	    var license = new Label();
	    license.text = "License Agreement";
	    license.variant = MoonshineTheme.THEME_VARIANT_TEXT_LINK;
	    titleDesContainer.addChild(license);
	    
	    var stateImageContainerLayoutData = new AnchorLayoutData();
	    stateImageContainerLayoutData.right = 0;
	    stateImageContainerLayoutData.verticalCenter = 0.0;
	    
	  	var stateImageContainer = new LayoutGroup();		
	    stateImageContainer.width = 50;
	    stateImageContainer.layoutData = stateImageContainerLayoutData;
	    stateImageContainer.layout = new HorizontalLayout();
		this.addChild(stateImageContainer);
		
		this.itemImageNote = new AssetLoader();
	    this.itemImageNote.layoutData = assetLoaderLayoutData;
		this.itemImageNote.visible = false;
		this.itemImageNote.includeInLayout = false;
	    stateImageContainer.addChild(this.itemImageNote);
		
	    this.itemImageState = new AssetLoader();
	    this.itemImageState.layoutData = assetLoaderLayoutData;
	    stateImageContainer.addChild(this.itemImageState);
	    
	    super.initialize();
	}
	
	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		if (dataInvalid) 
		{
			if (this.stateData != null)
			{
				this.updateFields();
			}
			else
			{
				this.resetFields();
			}
		}

		super.update();
	}
	
	private function updateFields():Void
	{
		this.lblTitle.text = this.stateData.title;
    	this.lblDescription.text = this.stateData.description;
		this.assetLogo.source = this.stateData.imagePath;
		
		this.updateItemIconState();
	}
	
	private function resetFields():Void
	{
		this.lblTitle.text = "";
    	this.lblDescription.text = "";
    	this.assetLogo.source = null;
	    	this.itemImageState.source = null;
	}
	
	private function updateItemIconState():Void
	{
		if (this.stateData.isAlreadyDownloaded)
		{
			this.itemImageState.source = "/helperResources/images/icoTickLabel.png";
		}
		else
		{
			this.itemImageState.source = "/helperResources/images/icoErrorLabel.png";
		}
		
		if (this.stateData.oldInstalledVersion != null)
		{
			this.itemImageNote.visible = true;
			this.itemImageNote.includeInLayout = true;
			this.itemImageState.source = "/helperResources/images/icoNote.png";
		}
		else
		{
			this.itemImageNote.visible = false;
			this.itemImageNote.includeInLayout = false;
		}
	}
}