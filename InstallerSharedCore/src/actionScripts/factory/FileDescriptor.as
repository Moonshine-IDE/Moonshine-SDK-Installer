////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.factory
{
	import actionScripts.interfaces.IFileDescriptorBridge;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;

	[Bindable] public class FileDescriptor extends EventDispatcher
	{
		public var fileBridge: IFileDescriptorBridge;

		public function FileDescriptor(path:String = null, isURL:Boolean = false):void
		{
			// ** IMPORTANT **
			var clsToCreate : Object = ApplicationDomain.currentDomain.getDefinition("actionScripts.imp.IFileDescriptorBridgeImp");
			fileBridge = new clsToCreate();

			if (isURL)
			{
				fileBridge.url = path;
			}
			else
			{
				fileBridge.nativePath = path;
			}
		}
		
		public function resolvePath(path:String):FileDescriptor
		{
			return fileBridge.resolvePath(path);
		}
		
		public function get name():String
		{
			return fileBridge.name;
		}
	}
}