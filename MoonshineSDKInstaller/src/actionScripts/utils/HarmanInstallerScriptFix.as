package actionScripts.utils
{
	import flash.filesystem.File;
	
	import actionScripts.valueObjects.ComponentVO;
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
					'<target name="air-setup-mac" depends="unzipOrMountDMG,unzipAIRSDK2,copyFromMount">'
				);

				// modify to `copyFromMount` to work correctly
				installerContent = installerContent.replace(
						'<target name="copyFromMount" unless="${shouldUnzip}">',
						'<target name="copyFromMount">'
				);
				installerContent = installerContent.replace(
						'<arg value="/Volumes/AIR SDK/"/>',
						'<arg value="${download.dir}/airsdk/."/>'
				);
				installerContent = installerContent.replace(
						'<arg value="${download.dir}/airsdk" />',
						'<arg value="${basedir}"/>'
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
						'<unzip src="${download.dir}/airsdk/'+ tmpFileName +'" dest="${download.dir}/airsdk" overwrite="true" />' +
						'<delete file="${download.dir}/airsdk/'+ tmpFileName +'" />' +
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