////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.utils.EnvironmentUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.JavaVersionReader;

	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	import moonshine.events.HelperEvent;

	public class DetectionManager extends EventDispatcher
	{
		public static const EVENT_DETECTION_BEGINS:String = "eventDetectionBegins";
		public static const EVENT_DETECTION_ENDS:String = "eventDetectionEnds";

		public var environmentUtil:EnvironmentUtils;
		
		private var model:HelperModel = HelperModel.getInstance();
		private var macGitDetector:MacOSGitDetector = MacOSGitDetector.getInstance();
		
		private var _itemTestCount:int = -1;
		private function get itemTestCount():int
		{
			return _itemTestCount;
		}
		private function set itemTestCount(value:int):void
		{
			_itemTestCount = value;
			if (_itemTestCount == (model.components.length - 1))
			{
				this.dispatchEvent(new HelperEvent(HelperEvent.ALL_COMPONENTS_TESTED, null));
			}
		}
		
		public function detect():void
		{
			itemTestCount = -1;
			HelperConstants.IS_DETECTION_IN_PROCESS = true;
			dispatchEvent(new Event(EVENT_DETECTION_BEGINS));
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
			for (var i:int; i < model.components.length; i++)
			{
				stepA_checkMoonshineInternal(model.components.get(i) as ComponentVO);
			}
			
			// check non-listed items if any
			checkPlayerGlobalHomePresence();
			
			var timeoutValue:uint = setTimeout(function():void{
				HelperConstants.IS_DETECTION_IN_PROCESS = false;
				dispatchEvent(new Event(EVENT_DETECTION_ENDS));
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
					case ComponentTypes.TYPE_FLEX_HARMAN:
						item.isAlreadyDownloaded = (model.moonshineBridge.isFlexHarmanSDKAvailable() != null);
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
					case ComponentTypes.TYPE_GRADLE:
						item.isAlreadyDownloaded = model.moonshineBridge.isGradlePresent();
						break;
					case ComponentTypes.TYPE_GRAILS:
						item.isAlreadyDownloaded = model.moonshineBridge.isGrailsPresent();
						break;
					case ComponentTypes.TYPE_OPENJAVA:
						if (model.moonshineBridge.isJavaPresent() && model.moonshineBridge.javaVersionForTypeahead)
						{
							if ((model.moonshineBridge.javaVersionForTypeahead != "1.8.0"))
							{
								item.isAlreadyDownloaded = true;
							}
							else if (model.moonshineBridge.javaVersionForTypeahead == "1.8.0" && model.moonshineBridge.isJava8Present())
							{
								item.isAlreadyDownloaded = true;
							}
							else
							{
								item.isAlreadyDownloaded = false;
							}
						}
						else
						{
							item.isAlreadyDownloaded = false;
						}
						break;
					case ComponentTypes.TYPE_OPENJAVA_V8:
						if (model.moonshineBridge.isJava8Present() && model.moonshineBridge.javaVersionInJava8Path)
						{
							item.isAlreadyDownloaded =
								(HelperUtils.isNewUpdateVersion(model.moonshineBridge.javaVersionInJava8Path, "1.8.0") != 1) ? 
								true : false;
						}
						else
						{
							item.isAlreadyDownloaded = false;
						}
						break;
					case ComponentTypes.TYPE_GIT:
						item.isAlreadyDownloaded = model.moonshineBridge.isGitPresent();
						break;
					case ComponentTypes.TYPE_SVN:
						item.isAlreadyDownloaded = model.moonshineBridge.isSVNPresent();
						break;
					case ComponentTypes.TYPE_NODEJS:
						item.isAlreadyDownloaded = model.moonshineBridge.isNodeJsPresent();
						break;
					case ComponentTypes.TYPE_NOTES:
						item.hasWarning = null;
						item.isAlreadyDownloaded = model.moonshineBridge.isNotesDominoPresent();
						break;
					case ComponentTypes.TYPE_VAGRANT:
						item.isAlreadyDownloaded = model.moonshineBridge.isVagrantAvailable();
						break;
					case ComponentTypes.TYPE_MACPORTS:
						item.isAlreadyDownloaded = model.moonshineBridge.isMacPortsAvailable();
						break;
					case ComponentTypes.TYPE_HAXE:
						item.isAlreadyDownloaded = model.moonshineBridge.isHaxeAvailable();
						break;
					case ComponentTypes.TYPE_NEKO:
						item.isAlreadyDownloaded = model.moonshineBridge.isNekoAvailable();
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
			// 1. named-sdk folder check under MoonshineSDKs
			item.isAlreadyDownloaded = HelperUtils.isValidSDKDirectoryBy(item.type, item.installToPath, item.pathValidation);
			
			// 2. Windows-only env.variable check
			if (environmentUtil && !item.isAlreadyDownloaded)
			{
				switch (item.type)
				{
					case ComponentTypes.TYPE_FLEX:
					case ComponentTypes.TYPE_FLEX_HARMAN:
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
					case ComponentTypes.TYPE_GRADLE:
						if (environmentUtil.environments.GRADLE_HOME) 
						{
							item.installToPath = environmentUtil.environments.GRADLE_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_GRAILS:
						if (environmentUtil.environments.GRAILS_HOME) 
						{
							item.installToPath = environmentUtil.environments.GRAILS_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_SVN:
						if (environmentUtil.environments.SVN_HOME)
						{
							item.installToPath = environmentUtil.environments.SVN_HOME.nativePath;
							item.isAlreadyDownloaded = true;
						}
						break;
					case ComponentTypes.TYPE_OPENJAVA:
					case ComponentTypes.TYPE_OPENJAVA_V8:
						if (environmentUtil.environments.JAVA_HOME) 
						{
							var javaVersionReader:JavaVersionReader = new JavaVersionReader();
							javaVersionReader.component = item;
							addJavaVersionReaderEvents(javaVersionReader);
							javaVersionReader.readVersion(environmentUtil.environments.JAVA_HOME.nativePath);
							return;
						}
						break;
					case ComponentTypes.TYPE_NODEJS:
						if (environmentUtil.environments.NODEJS_HOME) 
						{
							item.installToPath = environmentUtil.environments.NODEJS_HOME.nativePath;
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
						macGitDetector.test(onXCodePathDetection);
						break;
					case ComponentTypes.TYPE_SVN:
						if (HelperConstants.IS_MACOS)
						{
							var svnDefaultPaths:Array = ["/usr/local/bin/svn", "/opt/local/bin/svn", "/opt/homebrew/bin/svn"];
							for each(var svnPath:String in svnDefaultPaths)
							{
								item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
										item.type,
										svnPath,
										item.pathValidation
								);
								if (item.isAlreadyDownloaded)
								{
									item.installToPath = svnPath;
									break;
								}
							}
						}
						break;
					case ComponentTypes.TYPE_ANT:
						if (HelperConstants.IS_MACOS)
						{
							var antDefaultPaths:Array = ["/usr/local", "/opt/homebrew"];
							for each(var antPath:String in antDefaultPaths)
							{
								item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
										item.type,
										antPath,
										item.pathValidation
								);
								if (item.isAlreadyDownloaded)
								{
									item.installToPath = antPath;
									break;
								}
							}
						}
						break;
					case ComponentTypes.TYPE_MAVEN:
						if (HelperConstants.IS_MACOS)
						{
							var mvnDefaultPaths:Array = ["/usr/local", "/opt/homebrew"];
							for each(var mvnPath:String in mvnDefaultPaths)
							{
								item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
										item.type,
										mvnPath,
										item.pathValidation
								);
								if (item.isAlreadyDownloaded)
								{
									item.installToPath = mvnPath;
									break;
								}
							}
						}
						break;
					case ComponentTypes.TYPE_NOTES:
						new NotesDominoDetector(notifyMoonshineOnDetection);
						break;
					case ComponentTypes.TYPE_HAXE:
						var haxeDefaultPath:String = HelperConstants.IS_MACOS ? "/usr/local/lib/haxe" : "c:\\HaxeToolkit\\haxe";
						item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
								item.type,
								haxeDefaultPath,
								item.pathValidation
						);
						if (item.isAlreadyDownloaded)
						{
							item.installToPath = haxeDefaultPath;
						}
						break;
					case ComponentTypes.TYPE_NEKO:
						var nekoDefaultPath:String = HelperConstants.IS_MACOS ? "/usr/local/lib/neko" : "c:\\HaxeToolkit\\neko";
						item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
								item.type,
								nekoDefaultPath,
								item.pathValidation
						);
						if (item.isAlreadyDownloaded)
						{
							item.installToPath = nekoDefaultPath;
						}
						break;
					case ComponentTypes.TYPE_VAGRANT:
						var vagrantDefaultPath:String = HelperConstants.IS_MACOS ? "/usr/local/bin" : "C:\\HashiCorp\\Vagrant";
						item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
								item.type,
								vagrantDefaultPath,
								item.pathValidation
						);
						if (item.isAlreadyDownloaded)
						{
							item.installToPath = vagrantDefaultPath;
						}
						break;
					case ComponentTypes.TYPE_MACPORTS:
						if (HelperConstants.IS_MACOS)
						{
							var macPortsDefaultPath:String = "/opt/local/bin";
							item.isAlreadyDownloaded = HelperUtils.isValidExecutableBy(
									item.type,
									macPortsDefaultPath,
									item.pathValidation
							);
							if (item.isAlreadyDownloaded)
							{
								item.installToPath = macPortsDefaultPath;
							}
						}
						break;
				}
			}
			
			/*if (item.isAlreadyDownloaded) notifyMoonshineOnDetection(item);
			else notifyMoonshineOnDetection(item, false);*/
			
			notifyMoonshineOnDetection(item, item.isAlreadyDownloaded);
		}
		
		private function checkUpdateVersion(againstVersion:String, item:ComponentVO):void
		{
			if (HelperUtils.isNewUpdateVersion(againstVersion, item.version) == 1)
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
				if (component)
				{
					component.isAlreadyDownloaded = true;
					if (HelperConstants.IS_RUNNING_IN_MOON)
					{
						component.hasWarning = "Feature available. Click on Configure(icon) to allow permission.";
					}
					notifyMoonshineOnDetection(component);
				}
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
			
			itemTestCount++;
		}
		
		private function addJavaVersionReaderEvents(reader:JavaVersionReader):void
		{
			reader.addEventListener(JavaVersionReader.ENV_READ_COMPLETED, onJavaVersionReadCompletes);
			reader.addEventListener(JavaVersionReader.ENV_READ_ERROR, onJavaVersionReadError);
		}
		
		private function removeJavaVersionReaderEvents(reader:JavaVersionReader):void
		{
			reader.removeEventListener(JavaVersionReader.ENV_READ_COMPLETED, onJavaVersionReadCompletes);
			reader.removeEventListener(JavaVersionReader.ENV_READ_ERROR, onJavaVersionReadError);
		}
		
		private function onJavaVersionReadCompletes(event:HelperEvent):void
		{
			var reader:JavaVersionReader = event.target as JavaVersionReader;
			removeJavaVersionReaderEvents(reader);
			
			// for 1.8.0 the founding JDK version must match
			// for default-JDK the founding JDK version can compare
			var versionFindIndex:int = HelperUtils.isNewUpdateVersion(reader.component.version, event.data as String);
			if ((reader.component.version == "1.8.0" && versionFindIndex == -1) || 
				(reader.component.version != "1.8.0" && versionFindIndex != 0))
			{
				reader.component.installToPath = environmentUtil.environments.JAVA_HOME.nativePath;
				reader.component.isAlreadyDownloaded = true;
			}
			
			notifyMoonshineOnDetection(reader.component);
			reader.component = null;
		}
		
		private function onJavaVersionReadError(event:HelperEvent):void
		{
			removeJavaVersionReaderEvents(event.target as JavaVersionReader);
			notifyMoonshineOnDetection((event.target as JavaVersionReader).component);
			(event.target as JavaVersionReader).component = null;
		}
	}
}