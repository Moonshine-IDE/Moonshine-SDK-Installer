package moonshine.components.renderers;

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

class PackageRenderer extends LayoutGroupItemRenderer 
{
	public function new()
	{
		super();
		buildLayout();
	}
	
	private function buildLayout():Void
	{
		this.height = 100;
	 	this.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_WHITE_BACKGROUND;
	
	    var layout = new HorizontalLayout();
	    layout.verticalAlign = MIDDLE;
	    layout.gap = 6.0;
	    layout.paddingTop = 4.0;
	    layout.paddingBottom = 4.0;
	    layout.paddingLeft = 6.0;
	    layout.paddingRight = 6.0;
	    this.layout = layout;
	    
	    var titleDesContainerLayout = new VerticalLayout();
	    titleDesContainerLayout.verticalAlign = MIDDLE;
	    
	    var titleDesContainer = new LayoutGroup();
	    titleDesContainer.name = "titleDesContainer";
	    titleDesContainer.layout = titleDesContainerLayout;
	    titleDesContainer.layoutData = new VerticalLayoutData(100, 100);
	    this.addChild(titleDesContainer);
	
	    var label = new Label();
	    label.name = "title";
	    titleDesContainer.addChild(label);
	    
	    var description = new Label();
	    description.name = "description";
	    description.layoutData = new VerticalLayoutData(100, null);
	    description.wordWrap = true;
	    titleDesContainer.addChild(description);
	}
}