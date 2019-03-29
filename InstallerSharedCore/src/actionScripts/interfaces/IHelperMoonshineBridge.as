package actionScripts.interfaces
{
	public interface IHelperMoonshineBridge
	{
		function isDefaultSDKPresent():Boolean;
		function isFlexSDKAvailable():Object;
		function isFlexJSSDKAvailable():Object;
		function isRoyaleSDKAvailable():Object;
		function isFeathersSDKAvailable():Object;
		function isJavaPresent():Boolean;
		function isAntPresent():Boolean;
		function isMavenPresent():Boolean;
		function isSVNPresent():Boolean;
		function isGitPresent():Boolean;
		function runOrDownloadSDKInstaller():void;
	}
}