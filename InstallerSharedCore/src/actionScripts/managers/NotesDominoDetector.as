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
package actionScripts.managers
{
	import actionScripts.utils.HelperUtils;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
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