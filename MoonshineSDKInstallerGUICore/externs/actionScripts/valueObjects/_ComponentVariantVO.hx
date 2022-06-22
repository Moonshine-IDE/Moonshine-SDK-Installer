package actionScripts.valueObjects;
extern class _ComponentVariantVO
{
	public static final TYPE_STABLE:String;
	public static final TYPE_RELEASE_CANDIDATE:String;
	public static final TYPE_NIGHTLY:String;
	public static final TYPE_BETA:String;
	public static final TYPE_ALPHA:String;
	public static final TYPE_PRE_ALPHA:String;
	
	public var title:String;
	public var version:String;
	public var displayVersion:String;
	public var downloadURL:String;
	public var sizeInMb:Int;
	
	@:flash.property
	public var isReDownloadAvailable(default, default):Bool;
}