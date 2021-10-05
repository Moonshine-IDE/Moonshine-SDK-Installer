package actionScripts.valueObjects
{
	import actionScripts.utils.FileUtils;
	
	import feathers.data.ArrayCollection;
	import flash.events.EventDispatcher;
	import flash.events.Event;
		
	[Bindable] public class ComponentVO extends EventDispatcher
	{
		private static const EVENT_UPDATED:String = "isUpdated";

		public var id:String;
		public var title:String;
		public var description:String;
		public var imagePath:String;
		public var type:String;
		public var website:String;
		public var licenseUrl:String;
		public var licenseTitle:String;
		public var licenseSmallDescription:String;
		public var sizeInMb:int;
		public var downloadVariants:ArrayCollection;
		
		public function ComponentVO()
		{
		}
		
		private var _version:String;
		public function get version():String
		{
			return _version;
		}
		public function set version(value:String):void
		{
			_version = value;
		}

		private var _displayVersion:String;
		public function get displayVersion():String
		{
			return _displayVersion;
		}
		public function set displayVersion(value:String):void
		{
			_displayVersion = value;
		}
		
		private var _isDownloadable:Boolean = true;
		public function get isDownloadable():Boolean
		{
			return _isDownloadable;
		}
		public function set isDownloadable(value:Boolean):void
		{
			_isDownloadable = value;
		}
		
		private var _isDownloading:Boolean;
		public function set isDownloading(value:Boolean):void
		{
			if (_isDownloading != value)
			{
				_isDownloading = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
		}
		public function get isDownloading():Boolean
		{
			return _isDownloading;
		}
		
		private var _isDownloaded:Boolean;
		public function set isDownloaded(value:Boolean):void
		{
			if (_isDownloaded != value)
			{
				_isDownloaded = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
		}
		public function get isDownloaded():Boolean
		{
			return _isDownloaded;
		}
		
		private var _hasError:String;
		public function set hasError(value:String):void
		{
			if (_hasError != value)
			{
				_hasError = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
		}
		public function get hasError():String
		{
			return _hasError;
		}
		
		private var _hasWarning:String;
		public function set hasWarning(value:String):void
		{
			if (_hasWarning != value)
			{
				_hasWarning = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
		}
		public function get hasWarning():String
		{
			return _hasWarning;
		}
		
		private var _isAlreadyDownloaded:Boolean;
		public function set isAlreadyDownloaded(value:Boolean):void
		{
			if (_isAlreadyDownloaded != value)
			{
				_isAlreadyDownloaded = value;
				createdOn = FileUtils.getCreationDateForPath(installToPath);
				dispatchEvent(new Event(EVENT_UPDATED));
			}
			//_isAlreadyDownloaded = value;
			
		}
		public function get isAlreadyDownloaded():Boolean
		{
			return _isAlreadyDownloaded;
		}
		
		private var _isSelectedToDownload:Boolean;
		public function set isSelectedToDownload(value:Boolean):void
		{
			if (_isSelectedToDownload != value)
			{
				_isSelectedToDownload = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
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
		
		private var _pathValidation:Array;
		public function set pathValidation(value:Array):void
		{
			_pathValidation = value;			
		}
		public function get pathValidation():Array
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
		
		private var _selectedVariantIndex:int;
		public function get selectedVariantIndex():int
		{
			return _selectedVariantIndex;
		}
		public function set selectedVariantIndex(value:int):void
		{
			_selectedVariantIndex = value;
		}
		
		public function get variantCount():uint
		{
			if (downloadVariants) return downloadVariants.length;
			return 1;
		}
		
		private var _createdOn:Date;
		public function get createdOn():Date
		{
			return _createdOn;
		}
		public function set createdOn(value:Date):void
		{
			if (_createdOn != value)
			{
				_createdOn = value;
				dispatchEvent(new Event(EVENT_UPDATED));
			}
		}
	}
}