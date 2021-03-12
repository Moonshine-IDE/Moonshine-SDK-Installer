package actionScripts.locator
{
	import actionScripts.interfaces.IHelperMoonshineBridge;
	
	import feathers.data.ArrayCollection;

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