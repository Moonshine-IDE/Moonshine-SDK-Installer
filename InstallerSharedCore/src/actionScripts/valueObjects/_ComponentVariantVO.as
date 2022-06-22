package actionScripts.valueObjects
{
	[Bindable]
	public class _ComponentVariantVO
	{
		public static const TYPE_STABLE:String = "Stable";
		public static const TYPE_RELEASE_CANDIDATE:String = "Release Candidate";
		public static const TYPE_NIGHTLY:String = "Nightly";
		public static const TYPE_BETA:String = "Beta";
		public static const TYPE_ALPHA:String = "Alpha";
		public static const TYPE_PRE_ALPHA:String = "Pre-Alpha";
		
		public var title:String;
		public var version:String;
		public var displayVersion:String;
		public var downloadURL:String;
		public var sizeInMb:int;
		
		public function ComponentVariantVO() {}
		
		private var _isReDownloadAvailable:Boolean;
		public function get isReDownloadAvailable():Boolean
		{
			return _isReDownloadAvailable;
		}
		public function set isReDownloadAvailable(value:Boolean):void
		{
			_isReDownloadAvailable = value;
		}
	}
}