package actionScripts.utils
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;

    public class HarmanInstallerSymlinkFix extends EventDispatcher
	{
        public static const EVENT_ANT_SCRIPT_GENERATED:String = "eventAntScriptFileGenerated";

        private static const LIST_STATIC_SYMLINKS:String = "runtimes/air-captive/mac/Adobe AIR.framework/Adobe AIR -> Versions/Current/Adobe AIR\n" +
                "runtimes/air-captive/mac/Adobe AIR.framework/Versions/1.0/Adobe AIR_64 -> Adobe AIR\n" +
                "runtimes/air-captive/mac/Adobe AIR.framework/Versions/Current -> 1.0\n" +
                "runtimes/air-captive/mac/Adobe AIR.framework/Resources -> Versions/Current/Resources\n" +
                "runtimes/air/mac/Adobe AIR.framework/Adobe AIR -> Versions/Current/Adobe AIR\n" +
                "runtimes/air/mac/Adobe AIR.framework/Versions/1.0/Adobe AIR_64 -> Adobe AIR\n" +
                "runtimes/air/mac/Adobe AIR.framework/Versions/Current -> 1.0\n" +
                "runtimes/air/mac/Adobe AIR.framework/Headers -> Versions/Current/Headers\n" +
                "runtimes/air/mac/Adobe AIR.framework/Resources -> Versions/Current/Resources";

        private var baseDirectory:File;
        private var customProcess:NativeProcess;
        private var symlinkPairs:Dictionary;
        private var queue:Vector.<String> = new Vector.<String>();

        private var _antScriptPath:File;
        public function get antScriptPath():File
        {
            return _antScriptPath;
        }

		public function HarmanInstallerSymlinkFix()
		{
		}

        public function runCheck(baseDirectory:File):void
        {
            this.baseDirectory = baseDirectory;
            symlinkPairs = new Dictionary();

            var tmpLines:Array = LIST_STATIC_SYMLINKS.split("\n");
            var tmpLine:Array;
            for each (var line:String in tmpLines)
            {
                tmpLine = line.split(" -> ");
                if (tmpLine.length > 1)
                {
                    symlinkPairs[tmpLine[0]] = tmpLine[1];
                }
            }

            generateNewSymlinkFiles();
        }

        private function flush():void
        {
            if (queue.length == 0) return;

            var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            npInfo.executable = File.documentsDirectory.resolvePath("/bin/bash");

            npInfo.arguments = Vector.<String>(["-c", queue.shift()]);
            npInfo.workingDirectory = this.baseDirectory;

            startShell(true);
            customProcess.start(npInfo);
        }

        private function startShell(start:Boolean):void
        {
            if (start)
            {
                customProcess = new NativeProcess();
                customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
                customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
                customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
                customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
            }
            else
            {
                if (!customProcess) return;
                if (customProcess.running) customProcess.exit();
                customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
                customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
                customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
                customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
                customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
                customProcess = null;
            }
        }

        private function shellData(event:ProgressEvent):void
        {
            //var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
            //var data:String = output.readUTFBytes(output.bytesAvailable);
        }

        private function shellError(event:ProgressEvent):void
        {
            if (customProcess)
            {
                var output:IDataInput = customProcess.standardError;
                var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();

                trace(data);
                dispose();
            }
        }

        private function shellExit(e:NativeProcessExitEvent):void
        {
            if (customProcess)
            {
                dispose();
            }
        }

        private function dispose():void
        {
            startShell(false);
            flush();
        }

        private function generateNewSymlinkFiles():void
        {
            var symlinkFilePath:File;
            for (var key:String in symlinkPairs)
            {
                symlinkFilePath = baseDirectory.resolvePath(key);
                // delete existing symlink
                queue.push('rm "'+ symlinkFilePath.nativePath +'"');
                // generate new symlink
                queue.push('ln -s "'+ symlinkFilePath.parent.resolvePath(symlinkPairs[key]).nativePath +'" "'+ symlinkFilePath.nativePath +'"');
            }

            flush();
            dispatchEvent(new Event(EVENT_ANT_SCRIPT_GENERATED));
        }
	}
}
