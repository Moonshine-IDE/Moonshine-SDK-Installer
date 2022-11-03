package actionScripts.utils;

import moonshine.haxeScripts.valueObjects.ComponentVO;
import moonshine.haxeScripts.valueObjects.ComponentVariantVO;

extern class HelperUtils 
{
	public static function updateComponentByVariant(component:ComponentVO, variant:ComponentVariantVO):Void;
	public static function getSizeFix(value:Int):String;
	public static function isValidSDKDirectoryBy(type:String, originPath:String, validationPath:Array<String>=null):Bool;
}
