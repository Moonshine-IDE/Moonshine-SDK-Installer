package actionScripts.locator
{
	import mx.collections.ArrayCollection;
	
	import actionScripts.interfaces.IHelperMoonshineBridge;

	[Bindable] public class HelperModel
	{
		private static var instance:HelperModel;

		public static function getInstance():HelperModel 
		{	
			if (!instance) instance = new HelperModel();
			return instance;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var packages:ArrayCollection;
		public var components:ArrayCollection;
		public var moonshineBridge:IHelperMoonshineBridge;
	}
}