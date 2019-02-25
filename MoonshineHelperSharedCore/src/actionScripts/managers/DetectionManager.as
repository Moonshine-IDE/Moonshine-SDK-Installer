package actionScripts.managers
{
	import flash.filesystem.File;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;

	public class DetectionManager
	{
		private var model:HelperModel = HelperModel.getInstance();
		
		public function detect():void
		{
			for (var i:int; i < model.components.length; i++)
			{
				stepA_checkMoonshineInternal(model.components[i]);
			}
		}
		
		private function stepA_checkMoonshineInternal(item:ComponentVO):void
		{
			var isPresent:Boolean;
			if (model.moonshineBridge)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_FLEX:
						item.isAlreadyDownloaded = model.moonshineBridge.isFlexSDKAvailable();
						break;
					case ComponentTypes.TYPE_FLEXJS:
						item.isAlreadyDownloaded = model.moonshineBridge.isFlexJSSDKAvailable();
						break;
					case ComponentTypes.TYPE_ROYALE:
						item.isAlreadyDownloaded = model.moonshineBridge.isRoyaleSDKAvailable();
						break;
					case ComponentTypes.TYPE_FEATHERS:
						item.isAlreadyDownloaded = model.moonshineBridge.isFeathersSDKAvailable();
						break;
					case ComponentTypes.TYPE_ANT:
						item.isAlreadyDownloaded = model.moonshineBridge.isAntPresent();
						break;
					case ComponentTypes.TYPE_MAVEN:
						item.isAlreadyDownloaded = model.moonshineBridge.isMavenPresent();
						break;
					case ComponentTypes.TYPE_OPENJAVA:
						item.isAlreadyDownloaded = model.moonshineBridge.isJavaPresent();
						break;
				}
			}
			
			if (!item.isAlreadyDownloaded)
			{
				stepB_checkDefaultInstallLocation(item);
			}
		}
		
		private function stepB_checkDefaultInstallLocation(item:ComponentVO):void
		{
			var tmpSDKFolder:File = new File(item.installToPath); 
			// named-sdk folder check
			if (item.installToPath && tmpSDKFolder.exists)
			{
				// file-system check inside the named-sdk
				if (item.pathValidation)
				{
					if (tmpSDKFolder.resolvePath(item.pathValidation).exists)
					{
						item.isAlreadyDownloaded = true;
					}
				}
				else
				{
					item.isAlreadyDownloaded = true;
				}
			}
		}
	}
}