package actionScripts.interfaces
{
	public interface IHelperMoonshineBridge
	{
		function isDefaultSDKPresent():Boolean;
		function isFlexSDKAvailable():Boolean;
		function isFlexJSSDKAvailable():Boolean;
		function isRoyaleSDKAvailable():Boolean;
		function isFeathersSDKAvailable():Boolean;
		function isJavaPresent():Boolean;
		function isAntPresent():Boolean;
		function isMavenPresent():Boolean;
		function isSVNPresent():Boolean;
		function isGitPresent():Boolean;
		function runOrDownloadSDKInstaller():void;
	}
}