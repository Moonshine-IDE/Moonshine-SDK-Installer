////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.packageflexsdk.util
{
	import flash.desktop.NativeProcess;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import org.apache.flex.packageflexsdk.model.OS;
	import org.apache.flex.packageflexsdk.resource.ViewResourceConstants;
	import org.apache.flex.packageflexsdk.view.events.GenericEvent;
	
	import ws.tink.spark.controls.StepItem;
	
	public class ArchiveDownloader
	{
		public var installerApacheFlexInstance:InstallApacheFlex;
		public var viewResourceConstants:ViewResourceConstants;
		
		[Bindable] private var versionSelected:Object; // IComponentVO (TODO: type-restrict)
		
		private var _os:OS = new OS();
		private var _archiveTempDir:File;
		private var _archiveFile:File;
		private var loader:ApacheURLLoader;
		private var homeDir:File;
		private var successHandler:Function;
		private var errorHandler:Function;
		
		public function ArchiveDownloader(versionSelected:Object, success:Function=null, error:Function=null)
		{
			this.versionSelected = versionSelected;
			this.successHandler = success;
			this.errorHandler = error;
		}
		
		public function startInstallation():void
		{
			// check if the version already downloaded or not
			var sdkHome:File = new File(versionSelected.installToPath);
			homeDir = sdkHome;
			if (!sdkHome.exists) sdkHome.createDirectory();
			else if (sdkHome.exists && versionSelected.pathValidation)
			{
				sdkHome = sdkHome.resolvePath(versionSelected.pathValidation as String);
				if (sdkHome.exists)
				{
					// we take this as the particular ant varsiion already downloaded
					versionSelected.isAlreadyDownloaded = true;
					//installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
					return;
				}
			}
			
			try
			{
				versionSelected.isDownloading = true;
				installerApacheFlexInstance.logMASH(getByNamedMessage(viewResourceConstants.INFO_DOWNLOADING_APACHE_ANT) + versionSelected.downloadURL);
				
				var tmpArr:Array = versionSelected.downloadURL.split("/");
				var packageFileName:String = tmpArr[tmpArr.length - 1];
				
				_archiveTempDir = homeDir.resolvePath("temp");
				if (!_archiveTempDir.exists) _archiveTempDir.createDirectory();
				_archiveFile = _archiveTempDir.resolvePath(packageFileName);
				installerApacheFlexInstance.copyOrDownloadMASH(versionSelected.downloadURL, handleArchiveDownload, _archiveFile, handleArchiveDownloadError);
			}
			catch (e:Error)
			{
				versionSelected.isDownloading = false;
				installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT) + e.toString());
			}
		}
		
		protected function handleArchiveDownload(event:Event):void
		{
			try
			{
				installerApacheFlexInstance.writeFileToDirectoryMASH(_archiveFile, event.target.data);
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.STEP_OPTIONAL_INSTALL_APACHE_ANT) + e.toString());
				versionSelected.isDownloading = false;
			}
			
			unzipArchive();
		}
		
		protected function unzipArchive():void
		{
			try
			{
				if (_os.isWindows())
				{
					unzipArchiveWindows()
				}
				else
				{
					unzipArchiveMac();
				}
			}
			catch (e:Error)
			{
				installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT) + e.toString());
				versionSelected.isDownloading = false;
			}
		}
		
		protected function unzipArchiveWindows():void
		{
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_UNZIPPING + _archiveFile.nativePath);
			installerApacheFlexInstance.unzipMASH(_archiveFile, handleArchiveUnzipComplete, handleArchiveUnzipError);
		}
		
		protected function unzipArchiveMac():void
		{
			if (NativeProcess.isSupported)
			{
				installerApacheFlexInstance.untarMASH(_archiveFile, homeDir, handleArchiveUntarComplete, handleArchiveUntarError);
			}
			else
			{
				installerApacheFlexInstance.logMASH(viewResourceConstants.ERROR_NATIVE_PROCESS_NOT_SUPPORTED);
			}
		}
		
		protected function handleArchiveDownloadError(error:* = null):void
		{
			versionSelected.isDownloading = false;
			
			installerApacheFlexInstance.logMASH(getByNamedMessage(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT));
			installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.ERROR_UNABLE_TO_DOWNLOAD_APACHE_ANT));
		}
		
		protected function handleArchiveUnzipComplete(event:Event):void
		{
			versionSelected.isDownloading = false;
			versionSelected.isDownloaded = true;
			
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNZIPPING + _archiveFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			if (_archiveTempDir && _archiveTempDir.exists) _archiveTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
		
		protected function handleArchiveUnzipError(error:ErrorEvent = null):void
		{
			installerApacheFlexInstance.logMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT));
			installerApacheFlexInstance.updateActivityStepMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT), StepItem.ERROR);
			installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT));
			versionSelected.isDownloading = false;
		}
		
		protected function handleArchiveUntarError(error:ProgressEvent = null):void
		{
			installerApacheFlexInstance.logMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT));
			installerApacheFlexInstance.updateActivityStepMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT), StepItem.ERROR);
			installerApacheFlexInstance.abortInstallationMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT));
			versionSelected.isDownloading = false;
		}
		
		protected function handleArchiveUntarComplete(event:Event):void
		{
			versionSelected.isDownloaded = true;
			versionSelected.isDownloading = false;
			
			installerApacheFlexInstance.updateActivityStepMASH(getByNamedMessage(viewResourceConstants.STEP_UNZIP_APACHE_ANT), StepItem.COMPLETE);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_FINISHED_UNTARING + _archiveFile.nativePath);
			installerApacheFlexInstance.logMASH(viewResourceConstants.INFO_INSTALLATION_COMPLETE);
			
			if (_archiveTempDir && _archiveTempDir.exists) _archiveTempDir.deleteDirectory(true);
			installerApacheFlexInstance.dispatchEvent(new GenericEvent(GenericEvent.INSTALL_FINISH));
		}
		
		private function getByNamedMessage(value:String):String
		{
			return value.replace("$title", versionSelected.type);
		}
	}
}