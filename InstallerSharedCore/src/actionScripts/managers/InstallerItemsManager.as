package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.events.HelperEvent;
	import actionScripts.interfaces.IHelperMoonshineBridge;
	import actionScripts.locator.HelperModel;
	import actionScripts.utils.EnvironmentUtils;

	public class InstallerItemsManager extends EventDispatcher
	{
		private static var instance:InstallerItemsManager;
		
		public static function getInstance():InstallerItemsManager 
		{	
			if (!instance) instance = new InstallerItemsManager();
			return instance;
		}
		
		public var startupHelper:StartupHelper = new StartupHelper();
		public var detectionManager:DetectionManager = new DetectionManager();
		public var dependencyCheckUtil:IHelperMoonshineBridge;
		public var environmentUtil:EnvironmentUtils;
		
		private var model:HelperModel = HelperModel.getInstance();
		
		public function loadItemsAndDetect():void
		{
			if (!model.components)
			{
				model.moonshineBridge = dependencyCheckUtil;
				detectionManager.addEventListener(HelperEvent.COMPONENT_DOWNLOADED, onComponentDetected, false, 0, true);
				detectionManager.addEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDetected, false, 0, true);
				detectionManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentsTested, false, 0, true);
				
				CookieManager.getInstance().loadLocalStorage();
				
				attachStartupHelperListeners(true);
				startupHelper.setLocalPathConfig();
				startupHelper.loadMoonshineConfig();
			}
			else
			{
				detectOnly();
			}
		}
		
		public function detectOnly():void
		{
			detectionManager.environmentUtil = environmentUtil;
			detectionManager.detect();
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function attachStartupHelperListeners(attach:Boolean):void
		{
			if (attach)
			{
				startupHelper.addEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
				startupHelper.addEventListener(StartupHelper.EVENT_CONFIG_ERROR, onConfigError);
			}
			else
			{
				startupHelper.removeEventListener(StartupHelper.EVENT_CONFIG_LOADED, onConfigLoaded);
				startupHelper.removeEventListener(StartupHelper.EVENT_CONFIG_ERROR, onConfigError);
			}
		}
		
		private function onConfigLoaded(event:HelperEvent):void
		{
			dispatchEvent(event);
			attachStartupHelperListeners(false);
			
			var timeoutValue:uint = setTimeout(function():void
			{
				clearTimeout(timeoutValue);
				detectionManager.environmentUtil = environmentUtil;
				detectionManager.detect();
			}, 1000);
		}
		
		private function onConfigError(event:HelperEvent):void
		{
			// TODO: Show error
			attachStartupHelperListeners(false);
		}
		
		private function onComponentNotDetected(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onAllComponentsTested(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
		
		private function onComponentDetected(event:HelperEvent):void
		{
			dispatchEvent(event);
		}
	}
}