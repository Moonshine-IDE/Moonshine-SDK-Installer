package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.valueObjects.InstallerConstants;

	public class InstallerUtils
	{
		public static function readBuildVersion():void
		{
			var revisionInfoFile: File = File.applicationDirectory.resolvePath("images/appProperties.txt");
			if (revisionInfoFile.exists)
			{
				var saveData:String;
				try
				{
					var stream:FileStream = new FileStream();
					stream.open(revisionInfoFile, FileMode.READ);
					saveData = String(stream.readUTFBytes(stream.bytesAvailable));
					stream.close();
				}
				catch (e:Error)
				{
					return;
				}
				
				InstallerConstants.applicationBuildVersion = saveData.split("\n")[0];
			}
		}
	}
}