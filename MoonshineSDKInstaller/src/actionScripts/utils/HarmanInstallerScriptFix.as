////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.utils
{
	import flash.filesystem.File;
	
	import moonshine.haxeScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;

	public class HarmanInstallerScriptFix
	{
		public function HarmanInstallerScriptFix(itemDownloading:ComponentVO)
		{
			var tmpFileName:String = HelperConstants.CONFIG_HARMAN_AIR_OBJECT.file.replace("?license=accepted", "");
			
			// custom sdk-installer-config with harman download information
			var installFolder:File = new File(itemDownloading.installToPath);
			FileUtils.copyFile(
				File.applicationDirectory.resolvePath("installer/sdk-installer-config-4.0.xml"),
				(installFolder.resolvePath("sdk-installer-config-4.0.xml"))
			);
			
			// modify installer.xml to use custom sdk-installer-config
			var installer:File = installFolder.resolvePath("installer.xml");
			var installerContent:String = FileUtils.readFromFile(installer) as String;
			installerContent = installerContent.replace(
				'<property name="xml.properties" value="http://flex.apache.org/installer/sdk-installer-config-4.0.xml?ts=${ts}" />',
				'<property name="xml.properties" value="${basedir}/sdk-installer-config-4.0.xml" />'
			);
			installerContent = installerContent.replace(
				'<get src="${xml.properties}" dest="${basedir}/sdk-installer-config-4.0.xml" />',
				''
			);
			
			if (HelperConstants.IS_MACOS)
			{
				installerContent = installerContent.replace(
					'<matches pattern="tbz2" string="${air.sdk.url.file}"/>',
					'<matches pattern="(tbz2|zip)" string="${air.sdk.url.file}"/>'
				);
				
				// for an unknown reason irrespective of ${shouldUnzip} value
				// installer.xml always triggering mountDMG on macOS
				installerContent = installerContent.replace(
					'<target name="air-setup-mac" depends="unzipOrMountDMG,unzipAIRSDK,mountAIRSDK,copyFromMount,unmountAIRSDK">',
					'<target name="air-setup-mac" depends="unzipOrMountDMG,unzipAIRSDK2">'
				);
				
				// we also need to normalize the downloaded zip file
				// name to properly unzip with using tar
				// eg. from AIRSDK_Flex_*.zip?license=accepted to AIRSDK_Flex_*.zip
				installerContent = installerContent.replace(
					'<move file="${download.dir}/${air.sdk.url.file}" todir="${download.dir}/airsdk" />',
					'<move file="${download.dir}/${air.sdk.url.file}" todir="${download.dir}/airsdk" />' +
					'<move file="${download.dir}/airsdk/${air.sdk.url.file}" tofile="${download.dir}/airsdk/'+ tmpFileName +'" />'
				);
				
				// write our own unzip method to facilitate following:
				// 1. an unzip process doing similar as copying resources from DMG distribution
				// 2. overlay directly to the sdk directory instead of copying individual resources following original unzip process
				// 3. individual copying resource list in installer.xml is outdated against harman sdk
				installerContent = installerContent.replace(
					'<target name="unzipAIRSDK" if="${shouldUnzip}">',
					'<target name="unzipAIRSDK2">' +
						'<echo>Unzipping ${download.dir}/airsdk/'+ tmpFileName +'</echo>' +
						'<exec executable="tar" dir="${basedir}"><arg value="-xvf" /><arg value="${download.dir}/airsdk/'+ tmpFileName +'" /></exec>' +
						'</target>' +
						'<target name="unzipAIRSDK" if="${shouldUnzip}">'
				);
			}
			else
			{
				// on Windows using `value="${download.dir}/${air.sdk.url.file}"`
				// throws error#1000: out of memory
				// https://github.com/Moonshine-IDE/Moonshine-SDK-Installer/issues/32#issuecomment-879644056
				// it could be because of the using suffix to the file
				installerContent = installerContent.replace(
					'<param name="dest" value="${download.dir}/${air.sdk.url.file}" />',
					'<param name="dest" value="${download.dir}" />'
				);
				
				// write our own unzip method to facilitate following:
				// 1. overlay directly to the sdk directory instead of copying individual resources following original unzip process
				// 2. individual copying resource list in installer.xml is outdated against harman sdk
				installerContent = installerContent.replace(
					'<target name="air-setup-win" if="isWindows">',
					'<target name="air-setup-win-2" if="isWindows">' +
					'<echo>Uncompressing ${download.dir}/${air.sdk.url.file}</echo><unzip src="${download.dir}/'+ tmpFileName +'" dest="${basedir}" overwrite="true" />' +
					'<echo>${INFO_FINISHED_UNZIPPING} ${download.dir}/${air.sdk.url.file}</echo>' +
					'</target><target name="air-setup-win" if="isWindows">'
				);
				installerContent = installerContent.replace(
					'<antcall target="air-setup-win" />',
					'<antcall target="air-setup-win-2" />'
				);
			}
			
			// re-write installer.xml
			FileUtils.writeToFile(installer, installerContent);
		}
	}
}