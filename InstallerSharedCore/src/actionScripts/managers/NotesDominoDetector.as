package actionScripts.managers
{
	import actionScripts.utils.HelperUtils;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class NotesDominoDetector
	{
		protected var installLocationsWindows:Array = ["C:\\Program Files (x86)\\IBM\\Notes", "C:\\Program Files (x86)\\HCL\\Notes"];
		protected var installLocationMacOS:String = "/Applications/IBM Notes.app";
		
		private var onCompletion:Function;
		private var component:ComponentVO;
		
		public function NotesDominoDetector(onCompletion:Function)
		{
			if (onCompletion == null)
			{
				throw new Error("Completion function is required field.");
				return;
			}
			
			this.onCompletion = onCompletion;
			this.component = HelperUtils.getComponentByType(ComponentTypes.TYPE_NOTES);
			
			startBasicDetection();
		}
		
		protected function startBasicDetection():void
		{
			if (HelperConstants.IS_MACOS && HelperUtils.isValidSDKDirectoryBy(component.type, installLocationMacOS, component.pathValidation))
			{
				component.isAlreadyDownloaded = true;
				component.installToPath = installLocationMacOS;
				component.hasWarning = "Feature available. Click on Configure(icon) to allow";
			}
			else (!HelperConstants.IS_MACOS)
			{
				for (var i:int; i < installLocationsWindows.length; i++)
				{
					if (HelperUtils.isValidSDKDirectoryBy(component.type, installLocationsWindows[i], component.pathValidation))
					{
						component.isAlreadyDownloaded = true;
						component.installToPath = installLocationsWindows[i];
						break;
					}
				}
			}
			
			// finally notify to the caller
			onCompletion(component, component.isAlreadyDownloaded);
			onCompletion = null;
			component = null;
		}
	}
}