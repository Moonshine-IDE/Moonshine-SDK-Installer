package actionScripts.valueObjects
{
	import flash.filesystem.File;

	public class EnvironmentVO
	{
		public var ANT_HOME:File;
		public var JAVA_HOME:File;
		public var FLEX_HOME:HelperSDKVO;
		public var MAVEN_HOME:File;
		public var GIT_HOME:File;
		public var SVN_HOME:File;
		
		public function EnvironmentVO() {}
	}
}