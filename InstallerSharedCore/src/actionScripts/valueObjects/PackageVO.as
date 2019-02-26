package actionScripts.valueObjects
{
	import mx.collections.ArrayList;

	[Bindable] public class PackageVO
	{
		public var title:String;
		public var description:String;
		public var imagePath:String;
		public var isIntegrated:Boolean;
		
		public function PackageVO()
		{
		}
		
		private var _dependencyTypes:ArrayList;
		public function set dependencyTypes(value:ArrayList):void
		{
			_dependencyTypes = value;
		}
		public function get dependencyTypes():ArrayList
		{
			return _dependencyTypes;
		}
	}
}