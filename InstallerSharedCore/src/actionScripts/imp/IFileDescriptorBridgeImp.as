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
package actionScripts.imp
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import actionScripts.factory.FileDescriptor;
	import actionScripts.interfaces.IFileDescriptorBridge;
	
	import actionScripts.utils.FileUtils;
	import mx.controls.Alert;

	/**
	 * IFileBridgeImp
	 *
	 * @date 10.28.2015
	 * @version 1.0
	 */
	public class IFileDescriptorBridgeImp implements IFileDescriptorBridge
	{
		private var _file: File = File.desktopDirectory;
		
		/**
		 * Creating new File instance everytime
		 * to detect if exists could be expensive
		 */
		public function isPathExists(value:String):Boolean
		{
			return FileUtils.isPathExists(value);
		}
		
		public function getDirectoryListing():Array
		{
			if (!checkFileExistenceAndReport()) return [];
			return _file.getDirectoryListing();
		}
		
		public function deleteFileOrDirectory():void
		{
		}
		
		public function canonicalize():void
		{
			_file.canonicalize();
		}
		
		public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);

			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForDirectory(title);
			
			/*
			 *@local
			 */
			function onSelectHandler(event:Event):void
			{
				onCancelHandler(event);
				
				// to overcome a macOS bug where previously selected
				// file can return to directory browsing
				if (!testSelectionIfDirectory(event.target as File))
				{
					return;
				}
				
				selectListner(event.target as File);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
			function testSelectionIfDirectory(byFile:File=null, byPath:String=null):Boolean
			{
				var isValid:Boolean;
				// to overcome a macOS bug where previously selected
				// file can return to directory browsing
				if (byFile && byFile.isDirectory)
				{
					isValid = true;
				}
				else if (byPath && FileUtils.isPathDirectory(byPath))
				{
					isValid = true;
				}
				
				if (!isValid) Alert.show("Selected file is not Directory.", "Error!");
				return isValid;
			}
		}
		
		public function createDirectory():void
		{
			try
			{
				_file.createDirectory();
			}
			catch (e:Error)
			{
				trace("Unable to create directory.");
			}
		}
		
		public function getRelativePath(ref:FileDescriptor, useDotDot:Boolean=false):String
		{
			if (ref.fileBridge.nativePath == File.separator) return ref.fileBridge.nativePath;
			return _file.getRelativePath(ref.fileBridge.getFile as File, useDotDot);
		}
		
		public function copyTo(value:FileDescriptor, overwrite:Boolean = false):void
		{
			_file.copyTo(value.fileBridge.getFile as File, overwrite);
		}

		public function moveToTrashAsync():void
		{
			_file.moveToTrashAsync();
		}
		
		public function load():void
		{
			if (checkFileExistenceAndReport()) _file.load();
		}
		
		public function save(content:Object):void
		{
			var fs:FileStream = new FileStream();
			fs.open(_file, FileMode.WRITE);
			fs.writeUTFBytes(String(content));
			fs.close();
		}
		
		public function browseForSave(selected:Function, canceled:Function=null, title:String=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);
			
			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForSave(title ? title : "");
			
			/*
			 *@local
			 */
			function onSelectHandler(event:Event):void
			{
				removeListeners(event);
				selected(event.target as File);
			}
			function onCancelHandler(event:Event):void
			{
				removeListeners(event);
				if (canceled != null) canceled(event);
			}
			function removeListeners(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}
		
		public function moveTo(newLocation:FileDescriptor, overwrite:Boolean=false):void
		{
			if (checkFileExistenceAndReport()) _file.moveTo(newLocation.fileBridge.getFile as File, overwrite);
		}
		
		public function moveToAsync(newLocation:FileDescriptor, overwrite:Boolean=false):void
		{
			if (checkFileExistenceAndReport()) _file.moveToAsync(newLocation.fileBridge.getFile as File, overwrite);
		}
		
		public function deleteDirectory(deleteDirectoryContents:Boolean=false):void
		{
			try
			{
				_file.deleteDirectory(deleteDirectoryContents);
			}
			catch (e:Error)
			{
				deleteDirectoryAsync(deleteDirectoryContents);
			}
		}
		
		public function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void
		{
			try
			{
				_file.deleteDirectoryAsync(deleteDirectoryContents);
			}
			catch (e:Error)
			{
				trace("Unable to delete directory asynchronously.");
			}
		}
		
		public function resolveDocumentDirectoryPath(pathWith:String=null):FileDescriptor
		{
			if (!pathWith) return (new FileDescriptor(File.documentsDirectory.nativePath));
			return (new FileDescriptor(File.documentsDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveUserDirectoryPath(pathWith:String=null):FileDescriptor
		{
			if (!pathWith) return (new FileDescriptor(File.userDirectory.nativePath));
			return (new FileDescriptor(File.userDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileDescriptor
		{
			if (!pathWith) return (new FileDescriptor(File.applicationStorageDirectory.nativePath));
			return (new FileDescriptor(File.applicationStorageDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveApplicationDirectoryPath(pathWith:String=null):FileDescriptor
		{
			if (!pathWith) return (new FileDescriptor(File.applicationDirectory.nativePath));
			return (new FileDescriptor(File.applicationDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveTemporaryDirectoryPath(pathWith:String=null):FileDescriptor
		{
			if (!pathWith) return (new FileDescriptor(File.cacheDirectory.nativePath));
			return (new FileDescriptor(File.cacheDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolvePath(path:String, toRelativePath:String=null):FileDescriptor
		{
			var tmpFile:File = toRelativePath ? new File(toRelativePath).resolvePath(path) : _file.resolvePath(path);
			return (new FileDescriptor(tmpFile.nativePath));
		}
		
		public function read():Object
		{
			var saveData:Object;
			try
			{
				if (checkFileExistenceAndReport())
				{
					var stream:FileStream = new FileStream();
					stream.open(_file, FileMode.READ);
					saveData = stream.readUTFBytes(stream.bytesAvailable);
					stream.close();
				}
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
			
			return saveData;
		}
		
		public function readAsyncWithListener(onComplete:Function, onError:Function=null, fileToRead:Object=null):void
		{
			if (fileToRead && 
				!(fileToRead is FileDescriptor) && 
					!(fileToRead is File)) return;
			
			fileToRead ||= _file;
			
			FileUtils.readFromFileAsync((fileToRead is FileDescriptor) ? ((fileToRead as FileDescriptor).fileBridge.getFile as File) : fileToRead as File, 
				FileUtils.DATA_FORMAT_STRING, 
				onComplete, onError);
		}
		
		public function deleteFile():void
		{
			try
			{
				_file.deleteFile();
			}
			catch (e:Error)
			{
				deleteFileAsync();
			}
		}
		
		public function deleteFileAsync():void
		{
			try
			{
				_file.deleteFileAsync();
			}
			catch (e:Error)
			{
				trace("Unable to delete file asynchronously.");
			}
		}
		
		public function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);
			
			var filters:Array;
			var filtersForExt:Array = [];
			if (fileFilters)
			{
				filters = [];
				//"*.as;*.mxml;*.css;*.txt;*.js;*.xml"
				for each (var i:String in fileFilters)
				{
					filters.push(new FileFilter("Open", i));
					var extSplit:Array = i.split(";");
					for each (var j:String in extSplit)
					{
						filtersForExt.push(j.split(".")[1]);
					}
				}
			}

			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForOpen(title, filters);
			
			/*
			*@local
			*/
			function onSelectHandler(event:Event):void
			{
				onCancelHandler(event);
				selectListner(event.target as File);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}

		public function openWithDefaultApplication():void
		{
			if (checkFileExistenceAndReport()) _file.openWithDefaultApplication();
		}

		public function get url():String
		{
			return _file.url;
		}

		public function set url(value:String):void
		{
			_file.url = value;
		}
		
		public function get parent():FileDescriptor
		{
			return (new FileDescriptor(_file.parent.nativePath));
		}
		
		public function get separator():String
		{
			return File.separator;
		}
		
		public function get getFile():Object
		{
			return _file;
		}
		
		public function get exists():Boolean
		{
			try
			{
				return _file.exists;
			}
			catch (e:Error)
			{
			}
			
			return false;
		}
		
		public function get isDirectory():Boolean
		{
			return _file.isDirectory;
		}
		
		public function get isHidden():Boolean
		{
			return _file.isHidden;
		}
		
		public function get nativePath():String
		{
			return _file.nativePath;
		}
		
		public function set nativePath(value:String):void
		{
			try
			{
				if (checkFileExistenceAndReport(false)) 
				{
					_file.nativePath = value;
				}
				else if (FileUtils.isPathExists(value))
				{
					_file = new File(value);
				}
				else
				{
					_file.nativePath = value;
				}
			}
			catch (e:Error)
			{
				trace(value +": "+ e.message);
			}
		}
		
		public function get nativeURL():String
		{
			return _file.nativePath;
		}
		
		public function set nativeURL(value:String):void
		{
		}
		
		public function get creator():String
		{
			return _file.creator;
		}
		
		public function get extension():String
		{
			return _file.extension;
		}
		
		public function get name():String
		{
			return _file.name;
		}
		
		public function get type():String
		{
			return _file.type;
		}
		
		public function get creationDate():Date
		{
			if (_file && _file.exists) return _file.creationDate;
			return (new Date());
		}
		
		public function get modificationDate():Date
		{
			if (_file && _file.exists) return _file.modificationDate;
			return null;
		}
		
		public function get data():Object
		{
			return _file.data;
		}
		
		public function set data(value:Object):void
		{
		}

		public function get nameWithoutExtension():String
		{
			var extensionIndex:int = this.name.lastIndexOf(extension);
			if (extensionIndex > -1)
			{
				return this.name.substring(0, extensionIndex - 1);
			}

			return this.name;
		}
		
		public function get userDirectory():Object
		{
			return File.userDirectory;
		}
		
		public function get desktopDirectory():Object
		{
			return File.desktopDirectory;
		}
		
		public function get documentsDirectory():Object
		{
			return File.documentsDirectory;
		}

		public function checkFileExistenceAndReport(showAlert:Boolean=true):Boolean
		{
			// we want to keep this method separate from
			// 'exists' and not add these alerts to the
			// said method, because file.exists uses against many
			// internal checks which are not intentional to throw an alert
			if (!_file.exists)
			{
				/*if (showAlert)
				{
					// let's not alert
				}*/
				return false;
			}
			
			return true;
		}
		
		private function setFileInternalPath(startFromLocation:String):void
		{
			// set file path if requires
			try
            {
                if (startFromLocation && FileUtils.isPathExists(startFromLocation))
                {
					_file.nativePath = startFromLocation;
                }
            }
			catch(e:Error)
			{}
		}
	}
}