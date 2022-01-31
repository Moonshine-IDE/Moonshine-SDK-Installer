package actionScripts.events
{
	import flash.events.Event;
	
	public class GeneralEvent extends Event
	{
		public var value:Object;
		
		public function GeneralEvent(type:String, value:Object=null, _bubble:Boolean=false, _cancelable:Boolean=true)
		{
			this.value = value;
			super(type, _bubble, _cancelable);
		}
	}
}