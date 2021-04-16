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
package actionScripts.interfaces
{
	import actionScripts.factory.FileDescriptor;

	[Bindable] public interface IFileDescriptorBridge
	{
		function isPathExists(value:String):Boolean;
		function getDirectoryListing():Array;
		function deleteFileOrDirectory():void;
		function canonicalize():void;
		function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null, startFromLocation:String=null):void;
		function createDirectory():void;
		function copyTo(value:FileDescriptor, overwrite:Boolean = false):void;
		function getRelativePath(ref:FileDescriptor, useDotDot:Boolean=false):String;
		function load():void;
		function save(content:Object):void;
		function browseForSave(selected:Function, canceled:Function=null, title:String=null, startFromLocation:String=null):void;
		function moveTo(newLocation:FileDescriptor, overwrite:Boolean=false):void;
		function moveToAsync(newLocation:FileDescriptor, overwrite:Boolean=false):void;
		function deleteDirectory(deleteDirectoryContents:Boolean=false):void;
		function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void;
		function resolveUserDirectoryPath(pathWith:String=null):FileDescriptor;
		function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileDescriptor;
		function resolveApplicationDirectoryPath(pathWith:String=null):FileDescriptor;
		function resolveTemporaryDirectoryPath(pathWith:String=null):FileDescriptor;
		function resolvePath(path:String, toRelativePath:String=null):FileDescriptor;
		function resolveDocumentDirectoryPath(pathWith:String=null):FileDescriptor;
		function read():Object;
		function readAsyncWithListener(onComplete:Function, onError:Function=null, fileToRead:Object=null):void;
		function deleteFile():void;
		function deleteFileAsync():void;
		function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null, startFromLocation:String=null):void;
		function moveToTrashAsync():void;
		function openWithDefaultApplication():void;
		
		function get url():String;
		function set url(value:String):void
		function get separator():String;
		function get getFile():Object;
		function get parent():FileDescriptor;
		function get exists():Boolean;
		function get isDirectory():Boolean;
		function get isHidden():Boolean;
		function get nativePath():String;
		function set nativePath(value:String):void;
		function get nativeURL():String;
		function set nativeURL(value:String):void;
		function get creator():String;
		function get extension():String;
		function get name():String;
		function get type():String;
		function get creationDate():Date;
		function get modificationDate():Date;
		function get data():Object;
		function set data(value:Object):void;
		function get userDirectory():Object;
		function get desktopDirectory():Object;
		function get documentsDirectory():Object;

		function get nameWithoutExtension():String;
	}
}