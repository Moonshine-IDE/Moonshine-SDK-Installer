package actionScripts.utils;

import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ComponentVariantVO;

extern class HelperUtils 
{
	public static function updateComponentByVariant(component:ComponentVO, variant:ComponentVariantVO):Void;
	public static function getSizeFix(value:Int):String;
}
