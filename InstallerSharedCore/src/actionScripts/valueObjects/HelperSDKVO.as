package actionScripts.valueObjects
{
	import flash.filesystem.File;

	public class HelperSDKVO
	{
		private static const JS_SDK_COMPILER_NEW:String = "js/bin/mxmlc";
		private static const JS_SDK_COMPILER_OLD:String = "bin/mxmlc";
		private static const FLEX_SDK_COMPILER:String = "bin/fcsh";
		
		public function HelperSDKVO()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var version:String;
		public var build:String;
		public var status:String;
		public var path:File;
		public var name:String;
		
		private var _type:String;
		public function get type():String
		{
			if (!_type) _type = getType();
			return _type;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function getType():String
		{
			// flex
			var compilerExtension:String = HelperConstants.IS_MACOS ? "" : ".bat";
			var compilerFile:File = path.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/libs/spark.swc").exists || 
					path.resolvePath("frameworks/libs/flex.swc").exists) return ComponentTypes.TYPE_FLEX;
			}
			
			// royale
			compilerFile = path.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/royale-config.xml").exists) return ComponentTypes.TYPE_ROYALE;
			}
			
			// feathers
			compilerFile = path.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
			if (compilerFile.exists)
			{
				if (path.resolvePath("frameworks/libs/feathers.swc").exists) return ComponentTypes.TYPE_FEATHERS;
			}
			
			// flexjs
			compilerFile = path.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
			if (compilerFile.exists)
			{
				if (name.toLowerCase().indexOf("flexjs") != -1) return ComponentTypes.TYPE_FLEXJS;
			}
			else 
			{
				compilerFile = path.resolvePath(JS_SDK_COMPILER_OLD + compilerExtension);
				if (compilerFile.exists)
				{
					if (name.toLowerCase().indexOf("flexjs") != -1) return ComponentTypes.TYPE_FLEXJS;
				}
			}
			
			return null;
		}
	}
}