package actionScripts.valueObjects;

import feathers.data.ArrayCollection;
import actionScripts.valueObjects.ComponentVariantVO;

extern class ComponentVO 
{
	public var id:String;
	public var title:String;
	public var description:String;
	public var imagePath:String;
	public var type:String;
	public var website:String;
	public var licenseUrl:String;
	public var licenseTitle:String;
	public var licenseSmallDescription:String;
	public var sizeInMb:Int;
	public var downloadVariants:ArrayCollection<ComponentVariantVO>;
	
	@:flash.property
	public var version(default, default):String;

	@:flash.property
	public var displayVersion(default, default):String;
	
	@:flash.property
	public var isDownloadable(default, default):Bool;
	
	@:flash.property
	public var isDownloading(default, default):Bool;
	
	@:flash.property
	public var isDownloaded(default, default):Bool;
	
	@:flash.property
	public var hasError(default, default):String;
	
	@:flash.property
	public var hasWarning(default, default):String;
	
	@:flash.property
	public var isAlreadyDownloaded(default, default):Bool;
	
	@:flash.property
	public var isSelectedToDownload(default, default):Bool;
	
	@:flash.property
	public var isSelectionChangeAllowed(default, default):Bool;
	
	@:flash.property
	public var pathValidation(default, default):String;
	
	@:flash.property
	public var downloadURL(default, default):String;
	
	@:flash.property
	public var installToPath(default, default):String;
	
	@:flash.property
	public var oldInstalledVersion(default, default):String;
	
	@:flash.property
	public var selectedVariantIndex(default, default):Int;
	
	@:flash.property
	public var variantCount(default, never):UInt;
	
	@:flash.property
	public var createdOn(default, default):Date;
}