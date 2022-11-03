package actionScripts.managers
{
	import actionScripts.utils.HelperUtils;
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class NotesDominoDetector
	{
		protected var installLocationsWindows:Array = ["C:\\Program Files (x86)\\IBM\\Notes", "C:\\Program Files (x86)\\HCL\\Notes"];
		protected var installLocationsMacOS:Array = ["/Applications/IBM Notes.app", "/Applications/HCL Notes.app"];
		
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
			var installLocations:Array = HelperConstants.IS_MACOS ? installLocationsMacOS : installLocationsWindows;
			
			for (var i:int; i < installLocations.length; i++)
			{
				if (HelperUtils.isValidSDKDirectoryBy(component.type, installLocations[i], component.pathValidation))
				{
					component.isAlreadyDownloaded = true;
					component.installToPath = installLocations[i];
					component.hasWarning = null;
					break;
				}
			}
			
			// finally notify to the caller
			onCompletion(component, component.isAlreadyDownloaded);
			onCompletion = null;
			component = null;
		}
	}
}