package actionScripts.valueObjects
{
	[Bindable] public class ComponentVO
	{
		public var id:String;
		public var title:String;
		public var description:String;
		public var imagePath:String;
		public var type:String;
		public var version:String;
		public var website:String;
		
		public function ComponentVO()
		{
		}
		
		private var _isDownloading:Boolean;
		public function set isDownloading(value:Boolean):void
		{
			_isDownloading = value;
		}
		public function get isDownloading():Boolean
		{
			return _isDownloading;
		}
		
		private var _isDownloaded:Boolean;
		public function set isDownloaded(value:Boolean):void
		{
			_isDownloaded = value;
		}
		public function get isDownloaded():Boolean
		{
			return _isDownloaded;
		}
		
		private var _hasError:String;
		public function set hasError(value:String):void
		{
			_hasError = value;
		}
		public function get hasError():String
		{
			return _hasError;
		}
		
		private var _hasWarning:String;
		public function set hasWarning(value:String):void
		{
			_hasWarning = value;
		}
		public function get hasWarning():String
		{
			return _hasWarning;
		}
		
		private var _isAlreadyDownloaded:Boolean;
		public function set isAlreadyDownloaded(value:Boolean):void
		{
			_isAlreadyDownloaded = value;
		}
		public function get isAlreadyDownloaded():Boolean
		{
			return _isAlreadyDownloaded;
		}
		
		private var _isSelectedToDownload:Boolean;
		public function set isSelectedToDownload(value:Boolean):void
		{
			_isSelectedToDownload = value;
		}
		public function get isSelectedToDownload():Boolean
		{
			return _isSelectedToDownload;
		}
		
		private var _isSelectionChangeAllowed:Boolean;
		public function set isSelectionChangeAllowed(value:Boolean):void
		{
			_isSelectionChangeAllowed = value;
		}
		public function get isSelectionChangeAllowed():Boolean
		{
			return _isSelectionChangeAllowed;
		}
		
		private var _pathValidation:String;
		public function set pathValidation(value:String):void
		{
			_pathValidation = value;
		}
		public function get pathValidation():String
		{
			return _pathValidation;
		}
		
		private var _downloadURL:String;
		public function set downloadURL(value:String):void
		{
			_downloadURL = value;
		}
		public function get downloadURL():String
		{
			return _downloadURL;
		}
		
		private var _installToPath:String;
		public function set installToPath(value:String):void
		{
			_installToPath = value;
		}
		public function get installToPath():String
		{
			return _installToPath;
		}
		
		private var _oldInstalledVersion:String;
		public function get oldInstalledVersion():String
		{
			return _oldInstalledVersion;
		}
		public function set oldInstalledVersion(value:String):void
		{
			_oldInstalledVersion = value;
		}
	}
}