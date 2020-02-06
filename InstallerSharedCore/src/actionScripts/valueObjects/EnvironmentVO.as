package actionScripts.valueObjects
{
	import flash.filesystem.File;

	public class EnvironmentVO
	{
		public var ANT_HOME:File;
		public var JAVA_HOME:File;
		public var NODEJS_HOME:File;
		public var FLEX_HOME:HelperSDKVO;
		public var MAVEN_HOME:File;
		public var GRADLE_HOME:File;
		public var GRAILS_HOME:File;
		public var GIT_HOME:File;
		public var SVN_HOME:File;
		public var PLAYERGLOBAL_HOME:File;
		
		public function EnvironmentVO() {}
	}
}