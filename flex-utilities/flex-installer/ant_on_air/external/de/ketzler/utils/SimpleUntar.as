/*
Copyright (c) 2012, Christoph Ketzler
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */


package de.ketzler.utils {
	import de.ketzler.utils.untar.UntarFileInfo;
	import de.ketzler.utils.untar.UntarHeaderBlock;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class SimpleUntar extends EventDispatcher {
		
		public static var BLOCK_SIZE:uint = 512;
		public static var BLOCK_SIZE_FACTOR : Number = 1 / 512;
		public static var SAVEDBYTES_AT_ONCE : uint = 4*1024*1024; // 4 MB
		public static const CODE_PAGE : String = "iso-8859-1";
		
		private var _sourcePath:String;
		private var _targetPath:String;
		private var sourceFile:File;
		private var targetFile:File;
		private var sourceFileStream : FileStream;
		
		private var allFiles : Vector.<UntarFileInfo> = new Vector.<UntarFileInfo>();
		private var allDirectories : Vector.<UntarFileInfo> = new Vector.<UntarFileInfo>();
		private var tempFileInfo : UntarFileInfo;
		private var tempFile : File;
		private var tempFileStream : FileStream;
		private var availBytes : uint;
		private var walkerPosition : uint;
		private var tempBA : ByteArray = new ByteArray();
		//private var ev : UntarEvent;
		
		
		
		public function SimpleUntar(target : IEventDispatcher = null) {
			super(target);
			
			
		}

		public function get sourcePath() : String {
			return _sourcePath;
			
			
			
		}

		public function set sourcePath(sourcePath : String) : void {
			
			//trace(sourcePath);
			_sourcePath = sourcePath;
			
			// TODO: Error Management
			sourceFile = new File(sourcePath);
			if(sourceFile.exists)
			{
				sourceFileStream = new FileStream();
				sourceFileStream.open(sourceFile, FileMode.READ);
			
				getAllFilenames();
			}
				
			
			
		}
		
		
		public function get targetPath() : String {
			return _targetPath;
		}

		public function set targetPath(targetPath : String) : void {
			
			targetFile = new File(targetPath);
			if(!targetFile.exists)
			{
				targetFile.createDirectory();
			}
			
			_targetPath = targetPath;
		}
		
		public function extract():void
		{
			createDirs();
			createFiles();
		}
		
		public function close():void
		{
			sourceFileStream.close();
		}
		
		
		public function getFileContent(filename:String):ByteArray
		{
			tempBA.clear();
			for (var i : int = 0; i < allFiles.length; i++) {
				tempFileInfo = allFiles[i];
				if (tempFileInfo.filename == filename)
				{
					sourceFileStream.position = tempFileInfo.startPosition;
					sourceFileStream.readBytes(tempBA,0,tempFileInfo.size);
					break;
				}
			}
			return tempBA;
		}
		
		
		private function createDirs():void
		{
			for (var i : int = 0; i < allDirectories.length; i++) {
				
				tempFile = targetFile.resolvePath(allDirectories[i].filename);
				if (!tempFile.exists)
				{
					tempFile.createDirectory();
				}
			}
		}
		private function createFiles():void
		{
			trace('createFiles');
			for (var i : int = 0; i < allFiles.length; i++) {
				tempFileInfo = allFiles[i];
				tempFile = targetFile.resolvePath(allFiles[i].filename);
				if (tempFile.exists)
				{
					tempFile.deleteFile();
				}
				
				tempFileStream = new FileStream();
				tempFileStream.open(tempFile, FileMode.APPEND);
				
				//trace(tempFile.nativePath);
				//trace(tempFileInfo.startPosition+' '+tempFileInfo.size);
				availBytes = tempFileInfo.size;
				walkerPosition = tempFileInfo.startPosition;
				//trace('start: '+availBytes);
				while (availBytes > SAVEDBYTES_AT_ONCE)
				{
					//trace('walk: '+availBytes);
					tempBA.clear();
					sourceFileStream.position = walkerPosition;
					sourceFileStream.readBytes(tempBA,0,SAVEDBYTES_AT_ONCE);
					tempFileStream.writeBytes(tempBA);
					
					
					availBytes -= SAVEDBYTES_AT_ONCE;
					walkerPosition += SAVEDBYTES_AT_ONCE;
					//ev = new UntarEvent(UntarEvent.EXTRACT_UPDATE);
					//dispatchEvent(ev);
				}
				
				// last one
				//trace('last one: '+ availBytes);
				tempBA.clear();
				sourceFileStream.position = walkerPosition;
				sourceFileStream.readBytes(tempBA,0,availBytes);
				tempFileStream.writeBytes(tempBA);
				
				tempFileStream.close();
				
				
			}
		}
		
		
		
		private function getAllFilenames():void
		{
			
			allFiles = new Vector.<UntarFileInfo>();
			allDirectories = new Vector.<UntarFileInfo>();
			var currentPosition:int = 0;
			var hasNewBlock:Boolean = true;
			var savedLongFileName:String = '';
			while (hasNewBlock)
			{
				var bytes:ByteArray = new ByteArray();
				sourceFileStream.position = currentPosition;
				sourceFileStream.readBytes(bytes, 0, BLOCK_SIZE);
				
				var header:UntarHeaderBlock = new UntarHeaderBlock();
				header.byteArray = bytes;
				tempFileInfo = new UntarFileInfo();
				// wir haben einen header und machen nun eine FileInfo
				switch (header.type)
				{
					case UntarHeaderBlock.TYPE_NULL:
						hasNewBlock = false;
					break;
					
					case UntarHeaderBlock.TYPE_LONGFILENAME:
						sourceFileStream.position = currentPosition+BLOCK_SIZE;
						savedLongFileName = sourceFileStream.readMultiByte(header.size, CODE_PAGE);
					break;
					
					case UntarHeaderBlock.TYPE_FILE:
						
						tempFileInfo.startPosition = currentPosition+BLOCK_SIZE;
						tempFileInfo.size = header.size;
						if (savedLongFileName != '')
						{
							tempFileInfo.filename = savedLongFileName;
						} else {
							tempFileInfo.filename = header.filename;
						}
						allFiles.push(tempFileInfo);
						savedLongFileName = '';
					break;
					case UntarHeaderBlock.TYPE_DIR:
						if (savedLongFileName != '')
						{
							tempFileInfo.filename = savedLongFileName;
						} else {
							tempFileInfo.filename = header.filename;
						}
						allDirectories.push(tempFileInfo);
						savedLongFileName = '';
					break;
					
				}
				
				//trace('bytes: '+bytes);
				//trace('header: '+header);
				
				currentPosition = currentPosition+(header.size_blocks*BLOCK_SIZE)+BLOCK_SIZE;
				//trace('new pos: '+currentPosition+' avail: '+sourceFileStream.bytesAvailable);
				//trace('current Size: '+tempFileInfo.size+' avail: '+sourceFileStream.bytesAvailable+' dif: '+(sourceFileStream.bytesAvailable-tempFileInfo.size));
				
				if ((sourceFileStream.bytesAvailable-tempFileInfo.size) < 512)
				{
					hasNewBlock = false;
				}
			}
			
			/*
			trace('dirs: ');
			
			trace('file: ');
			for (var j : int = 0; j < allFiles.length; j++) {
				
				trace(allFiles[j]);
			}
			 */
		}

		
		
		
		
		
		
		
	}
}
