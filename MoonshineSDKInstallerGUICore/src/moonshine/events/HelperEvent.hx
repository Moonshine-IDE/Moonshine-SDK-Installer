package moonshine.events;

import openfl.events.Event;

class HelperEvent extends Event
{
	public static final DOWNLOAD_COMPONENT:String = "DOWNLOAD_COMPONENT";
	public static final OPEN_MOON_SETTINGS:String = "OPEN_MOON_SETTINGS";
	public static final COMPONENT_DOWNLOADED:String = "COMPONENT_DOWNLOADED";
	public static final COMPONENT_NOT_DOWNLOADED:String = "COMPONENT_NOT_DOWNLOADED";
	public static final OPEN_COMPONENT_LICENSE:String = "OPEN_COMPONENT_LICENSE";
	public static final ALL_COMPONENTS_TESTED:String = "ALL_COMPONENTS_TESTED";
	public static final DOWNLOAD_VARIANT_CHANGED:String = "DOWNLOAD_VARIANT_CHANGED";
	
	public var data:Dynamic;
	
	public function new(type:String, value:Dynamic=null, canBubble:Bool=false, isCancelable:Bool=true)
	{
		super(type, canBubble, isCancelable);
		
		this.data = value;
	}
	
	override public function clone():Event 
	{
		return new HelperEvent(this.type, this.data, this.bubbles, this.cancelable);
	}
}
