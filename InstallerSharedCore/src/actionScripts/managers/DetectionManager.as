package actionScripts.managers
{
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
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
		
		private var _itemTestCount:int;
		private function get itemTestCount():int
		{
			return _itemTestCount;
		}
		private function set itemTestCount(value:int):void
		{
			_itemTestCount = value;
			if (_itemTestCount == model.components.source.length)
			{
				_itemTestCount = 0;
				this.dispatchEvent(new HelperEvent(HelperEvent.ALL_COMPONENTS_TESTED, null));
			}
		}
		
		public function detect():void
		{
			HelperConstants.IS_DETECTION_IN_PROCESS = true;
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
			function onEnvReadCompleted(event:HelperEvent):void
			{
				environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvReadCompleted);

				startDetectionProcess();
			}
		}
		
		private function startDetectionProcess():void
		{
			// go by source as collection can be in filtered state
			for (var i:int; i < model.components.source.length; i++)
			{
				stepA_checkMoonshineInternal(model.components.source[i]);
			}
			
			// check non-listed items if any
			checkPlayerGlobalHomePresence();
			
			var timeoutValue:uint = setTimeout(function():void{
				HelperConstants.IS_DETECTION_IN_PROCESS = false;
				clearTimeout(timeoutValue);
			}, 3000);

		}
		
		private function stepA_checkMoonshineInternal(item:ComponentVO):void
		{
			if (model.moonshineBridge)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_FLEX:
						item.isAlreadyDownloaded = (model.moonshineBridge.isFlexSDKAvailable() != null);
						break;
					case ComponentTypes.TYPE_FLEXJS:
						item.isAlreadyDownloaded = (model.moonshineBridge.isFlexJSSDKAvailable() != null);
						break;
					case ComponentTypes.TYPE_ROYALE:
						item.isAlreadyDownloaded = (model.moonshineBridge.isRoyaleSDKAvailable() != null);
						break;
					case ComponentTypes.TYPE_FEATHERS:
						item.isAlreadyDownloaded = (model.moonshineBridge.isFeathersSDKAvailable() != null);
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
			// 1. named-sdk folder check
			if (HelperUtils.isValidSDKDirectoryBy(item.type, item.installToPath, item.pathValidation))
				item.isAlreadyDownloaded = true;
			
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
							checkUpdateVersion(environmentUtil.environments.FLEX_HOME.version, item);
							item.installToPath = environmentUtil.environments.FLEX_HOME.path.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_ANT:
						if (environmentUtil.environments.ANT_HOME) 
						{
							item.installToPath = environmentUtil.environments.ANT_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_MAVEN:
						if (environmentUtil.environments.MAVEN_HOME) 
						{
							item.installToPath = environmentUtil.environments.MAVEN_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_OPENJAVA:
						if (environmentUtil.environments.JAVA_HOME) 
						{
							item.installToPath = environmentUtil.environments.JAVA_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
				}
			}
			
			// 3. even more
			if (!item.isAlreadyDownloaded)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_GIT:
					case ComponentTypes.TYPE_SVN:
						gitSvnDetector.testGitSVNmacOS(onXCodePathDetection);
						break;
				}
			}
			
			/*if (item.isAlreadyDownloaded) notifyMoonshineOnDetection(item);
			else notifyMoonshineOnDetection(item, false);*/
			
			notifyMoonshineOnDetection(item, item.isAlreadyDownloaded);
		}
		
		private function checkUpdateVersion(againstVersion:String, item:ComponentVO):void
		{
			if (HelperUtils.isNewUpdateVersion(againstVersion, item.version))
			{
				item.oldInstalledVersion = againstVersion;
			}
		}
		
		private function checkPlayerGlobalHomePresence():void
		{
			if (model.moonshineBridge && environmentUtil)
			{
				model.moonshineBridge.playerglobalExists = environmentUtil.environments.PLAYERGLOBAL_HOME != null;
			}
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
				component.hasWarning = "Feature available. Click on Configure to allow";
				notifyMoonshineOnDetection(component);
			}
		}
		
		private function notifyMoonshineOnDetection(value:ComponentVO, isDownloaded:Boolean=true):void
		{
			if (isDownloaded) 
			{
				this.dispatchEvent(new HelperEvent(HelperEvent.COMPONENT_DOWNLOADED, value));
			}
			else 
			{
				this.dispatchEvent(new HelperEvent(HelperEvent.COMPONENT_NOT_DOWNLOADED, value));
			}
			
			itemTestCount = itemTestCount + 1;
		}
	}
}