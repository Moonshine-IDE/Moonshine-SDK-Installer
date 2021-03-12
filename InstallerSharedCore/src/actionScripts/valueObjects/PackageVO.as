package actionScripts.valueObjects
{
	import feathers.data.ArrayCollection;

	[Bindable] public class PackageVO
	{
		public var title:String;
		public var description:String;
		public var imagePath:String;
		public var isIntegrated:Boolean;
		
		public function PackageVO()
		{
		}
		
		private var _dependencyTypes:ArrayCollection;
		public function set dependencyTypes(value:ArrayCollection):void
		{
			_dependencyTypes = value;
		}
		public function get dependencyTypes():ArrayCollection
		{
			return _dependencyTypes;
		}
	}
}