package actionScripts.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.events.HelperEvent;
	import actionScripts.locator.HelperModel;
	import actionScripts.utils.EnvironmentUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class DetectionManager extends EventDispatcher
	{
		public var environmentUtil:EnvironmentUtils;
		
		private var model:HelperModel = HelperModel.getInstance();
		private var gitSvnDetector:GitSVNDetector = GitSVNDetector.getInstance();
		
		public function detect():void
		{
			if (!HelperConstants.IS_MACOS && !environmentUtil)
			{
				environmentUtil = new EnvironmentUtils();
				environmentUtil.addEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvReadCompleted, false, 0, true);
				environmentUtil.readValues();
			}
			else
			{
				startDetectionProcess();
			}
			
			/*
			 * @local
			 */
			function onEnvReadCompleted(event:Event):void
			{
				environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvReadCompleted);
				startDetectionProcess();
			}
		}
		
		private function startDetectionProcess():void
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
					case ComponentTypes.TYPE_GIT:
						item.isAlreadyDownloaded = model.moonshineBridge.isGitPresent();
						break;
					case ComponentTypes.TYPE_SVN:
						item.isAlreadyDownloaded = model.moonshineBridge.isSVNPresent();
						break;
				}
			}
			
			if (!item.isAlreadyDownloaded)
			{
				stepB_checkDefaultInstallLocation(item);
			}
			else
			{
				notifyMoonshineOnDetection(item);
			}
		}
		
		private function stepB_checkDefaultInstallLocation(item:ComponentVO):void
		{
			var tmpSDKFolder:File = new File(item.installToPath);
			var pathValidationFileName:String;
			
			// 1. named-sdk folder check
			if (item.installToPath && tmpSDKFolder.exists)
			{
				// file-system check inside the named-sdk
				if (item.pathValidation)
				{
					if (item.type == ComponentTypes.TYPE_OPENJAVA) 
					{
						pathValidationFileName = HelperConstants.IS_MACOS ? item.pathValidation : item.pathValidation +".exe";
					}
					else
					{
						pathValidationFileName = item.pathValidation;
					}
					
					if (tmpSDKFolder.resolvePath(pathValidationFileName).exists)
					{
						item.isAlreadyDownloaded = true;
					}
				}
				else
				{
					item.isAlreadyDownloaded = true;
				}
			}
			
			// 2. Windows-only env.variable check
			if (environmentUtil && !item.isAlreadyDownloaded)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_FLEX:
					case ComponentTypes.TYPE_FLEXJS:
					case ComponentTypes.TYPE_ROYALE:
					case ComponentTypes.TYPE_FEATHERS:
						if (environmentUtil.environments.FLEX_HOME && 
							environmentUtil.environments.FLEX_HOME.type == item.type) 
						{
							if (HelperUtils.isNewUpdateVersion(environmentUtil.environments.FLEX_HOME.version, item.version))
							{
								item.oldInstalledVersion = environmentUtil.environments.FLEX_HOME.version;
							}
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_ANT:
						if (environmentUtil.environments.ANT_HOME) item.isAlreadyDownloaded = true;
						break;
					case ComponentTypes.TYPE_MAVEN:
						if (environmentUtil.environments.MAVEN_HOME) item.isAlreadyDownloaded = true;
						break;
					case ComponentTypes.TYPE_OPENJAVA:
						if (environmentUtil.environments.JAVA_HOME) item.isAlreadyDownloaded = true;
						break;
				}
			}
			
			// 3. even more
			if (!item.isAlreadyDownloaded)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_GIT:
						gitSvnDetector.testGitSVNmacOS(onXCodePathDetection);
						break;
				}
			}
			
			if (item.isAlreadyDownloaded) notifyMoonshineOnDetection(item);
		}
		
		private function onXCodePathDetection(value:String):void
		{
			var component:ComponentVO;
			if (value)
			{
				component = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
				if (component) updateComponent();
				component = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
				if (component) updateComponent();
			}
			
			/*
			 * @local
			 */
			function updateComponent():void
			{
				component.isAlreadyDownloaded = true;
				notifyMoonshineOnDetection(component);
			}
		}
		
		private function notifyMoonshineOnDetection(value:ComponentVO):void
		{
			this.dispatchEvent(new HelperEvent(HelperEvent.COMPONENT_DOWNLOADED, value));
		}
	}
}