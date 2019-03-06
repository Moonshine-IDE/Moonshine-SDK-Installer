package actionScripts.events
{
	import flash.events.Event;
	
	public class HelperEvent extends Event
	{
		public static const DOWNLOAD_COMPONENT:String = "DOWNLOAD_COMPONENT";
		public static const OPEN_MOON_SETTINGS:String = "OPEN_MOON_SETTINGS";
		public static const COMPONENT_DOWNLOADED:String = "COMPONENT_DOWNLOADED";
		
		public var value:Object;
		
		public function HelperEvent(type:String, value:Object=null, _bubble:Boolean=false, _cancelable:Boolean=true)
		{
			this.value = value;
			super(type, _bubble, _cancelable);
		}
		
		public override function clone():Event
		{
			return new HelperEvent(type, value, bubbles, cancelable);
		}
	}
}