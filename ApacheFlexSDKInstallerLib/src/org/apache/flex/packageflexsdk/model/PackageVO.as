package org.apache.flex.packageflexsdk.model
{
	[Bindable] public class PackageVO
	{
		public static const TYPE_FLEX_SDK:String = "Apache Flex®";
		public static const TYPE_FLEXJS_SDK:String = "Apache FlexJS®";
		public static const TYPE_ROYALE_SDK:String = "Apache Royale™";
		public static const TYPE_ANT_BIN:String = "Apache Ant™";
		public static const TYPE_FEATHERS_SDK:String = "Feathers SDK";
		public static const TYPE_SVN_BIN:String = "SVN";
		public static const TYPE_MAVEN:String = "Apache Maven™";
		
		public var packageType:String;
		public var version:String;
		public var packageURL:String;
		public var downloadingTo:String;
		public var arguments:Object;
		
		private var _isDownloading:Boolean;
		private var _isDownloaded:Boolean;
		private var _isAlreadyDownloaded:Boolean;
		private var _hasError:Boolean;
		private var _isSelectedToDownload:Boolean = true;
		private var _isSelectionChangeAllowed:Boolean;
		
		public function PackageVO()
		{
		}
		
		public function set isDownloading(value:Boolean):void
		{
			_isDownloading = value;
		}
		public function get isDownloading():Boolean
		{
			return _isDownloading;
		}
		
		public function set isDownloaded(value:Boolean):void
		{
			_isDownloaded = value;
		}
		public function get isDownloaded():Boolean
		{
			return _isDownloaded;
		}
		
		public function set hasError(value:Boolean):void
		{
			_hasError = value;
		}
		public function get hasError():Boolean
		{
			return _hasError;
		}
		
		public function set isAlreadyDownloaded(value:Boolean):void
		{
			_isAlreadyDownloaded = value;
		}
		public function get isAlreadyDownloaded():Boolean
		{
			return _isAlreadyDownloaded;
		}
		
		public function set isSelectedToDownload(value:Boolean):void
		{
			_isSelectedToDownload = value;
		}
		public function get isSelectedToDownload():Boolean
		{
			return _isSelectedToDownload;
		}
		
		public function set isSelectionChangeAllowed(value:Boolean):void
		{
			_isSelectionChangeAllowed = value;
		}
		public function get isSelectionChangeAllowed():Boolean
		{
			return _isSelectionChangeAllowed;
		}
	}
}