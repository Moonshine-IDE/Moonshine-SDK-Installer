package actionScripts.utils
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import actionScripts.locator.HelperModel;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.PackageVO;

	public class Parser
	{
		public static function parseHelperConfig(xmlData:XML):void
		{
			var model:HelperModel = HelperModel.getInstance();
			
			// store AIR version
			HelperConstants.CONFIG_AIR_VERSION = xmlData.air.@version.toString();
			
			// parse packages
			model.components = new ArrayCollection();
			var tmpComponent:ComponentVO;
			for each (var comp:XML in xmlData.components.item)
			{
				tmpComponent = new ComponentVO();
				tmpComponent.id = String(comp.@id);
				tmpComponent.title = String(comp.title);
				tmpComponent.description = String(comp.description);
				tmpComponent.imagePath = String(comp.image);
				tmpComponent.type = String(comp.sdkType);
				tmpComponent.pathValidation = String(comp.pathValidation);
				tmpComponent.isSelectionChangeAllowed = true;
				tmpComponent.version = String(comp.download[HelperConstants.IS_MACOS ? "mac" : "windows"].version.@displayVersion);
				tmpComponent.downloadURL = comp.download[HelperConstants.IS_MACOS ? "mac" : "windows"].version.path.toString() + comp.download[HelperConstants.IS_MACOS ? "mac" : "windows"].version.file.toString();
				tmpComponent.installToPath = getInstallDirectoryPath(tmpComponent.type, tmpComponent.version, HelperConstants.CONFIG_AIR_VERSION);
				tmpComponent.website = String(comp.website);
				
				model.components.addItem(tmpComponent);
			}
			
			// parse components
			model.packages = new ArrayCollection();
			var tmpPackage:PackageVO;
			for each (var pkg:XML in xmlData.packages.item)
			{
				tmpPackage = new PackageVO();
				tmpPackage.title = String(pkg.title);
				tmpPackage.description = String(pkg.description);
				tmpPackage.imagePath = String(pkg.image);
				tmpPackage.isIntegrated = (String(pkg.@integrated) == "true") ? true : false;
				
				var dependencyIDs:Array = String(pkg.componentDependencyIDs).split(",");
				if (dependencyIDs[0] != "") 
				{
					tmpPackage.dependencyTypes = new ArrayList();
					for each (var id:String in dependencyIDs)
					{
						tmpPackage.dependencyTypes.addItem(HelperUtils.getComponentById(id));
					}
				}
				
				model.packages.addItem(tmpPackage);
			}
		}
		
		private static function getInstallDirectoryPath(type:String, version:String, airVersion:String=null):String
		{
			switch (type)
			{
				case ComponentTypes.TYPE_FLEX:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Flex_SDK/Flex_"+ version +"_AIR_"+ airVersion;
				case ComponentTypes.TYPE_FLEXJS:
					return null;
				case ComponentTypes.TYPE_ROYALE:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Royale_SDK/apache-royale-"+ version +"-bin-js";
				case ComponentTypes.TYPE_FEATHERS:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Flex_SDK/feathers-sdk-"+ version +"-bin";
				case ComponentTypes.TYPE_ANT:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Ant/apache-ant-"+ version;
				case ComponentTypes.TYPE_MAVEN:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Maven/apache-maven-"+ version;
				case ComponentTypes.TYPE_OPENJAVA:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Java/openjdk-"+ version;
				case ComponentTypes.TYPE_GIT:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/Git/git-"+ version;
				case ComponentTypes.TYPE_SVN:
					return HelperConstants.DEFAULT_INSTALLATION_PATH.nativePath +"/SVN/slik-svn-"+ version;
				default:
					throw new Error("Unknown Component Type");
			}
			
			return null;
		}
	}
}