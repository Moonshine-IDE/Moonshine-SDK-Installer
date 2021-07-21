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
    import flash.utils.IDataInput;

    public class HarmanInstallerSymlinkFix extends EventDispatcher
	{
        public static const EVENT_SYMLINK_FIXED:String = "eventAntScriptFileGenerated";

        // @note
        // in a broken symlink directory we never get a list of symlinks
        // we need to retrieve the list from an working directory
        // save the list here, update the list time to time
        private static const LIST_STATIC_SYMLINKS:Object = [
            {
                workingDirectory: "runtimes/air-captive/mac/Adobe AIR.framework",
                resources: "Versions/Current/Adobe AIR",
                link: "Adobe AIR"
            },
            {
                workingDirectory: "runtimes/air-captive/mac/Adobe AIR.framework/Versions/1.0",
                resources: "Adobe AIR",
                link: "Adobe AIR_64"
            },
            {
                workingDirectory: "runtimes/air-captive/mac/Adobe AIR.framework/Versions",
                resources: "1.0",
                link: "Current"
            },
            {
                workingDirectory: "runtimes/air-captive/mac/Adobe AIR.framework",
                resources: "Versions/Current/Resources",
                link: "Resources"
            },
            {
                workingDirectory: "runtimes/air/mac/Adobe AIR.framework",
                resources: "Versions/Current/Adobe AIR",
                link: "Adobe AIR"
            },
            {
                workingDirectory: "runtimes/air/mac/Adobe AIR.framework/Versions/1.0",
                resources: "Adobe AIR",
                link: "Adobe AIR_64"
            },
            {
                workingDirectory: "runtimes/air/mac/Adobe AIR.framework/Versions",
                resources: "1.0",
                link: "Current"
            },
            {
                workingDirectory: "runtimes/air/mac/Adobe AIR.framework",
                resources: "Versions/Current/Headers",
                link: "Headers"
            },
            {
                workingDirectory: "runtimes/air/mac/Adobe AIR.framework",
                resources: "Versions/Current/Resources",
                link: "Resources"
            }
        ];

        private var baseDirectory:File;
        private var customProcess:NativeProcess;
        private var listIndex:int = -1;

		public function HarmanInstallerSymlinkFix()
		{
		}

        public function runCheck(baseDirectory:File):void
        {
            this.baseDirectory = baseDirectory;
            listIndex = -1;
            flush();
        }

        private function flush():void
        {
            listIndex++;
            if (listIndex == LIST_STATIC_SYMLINKS.length)
            {
                dispatchEvent(new Event(EVENT_SYMLINK_FIXED));
                return;
            }

            var symlinkObject:Object = LIST_STATIC_SYMLINKS[listIndex];
            var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            npInfo.executable = File.documentsDirectory.resolvePath("/bin/bash");

            var command1:String = 'rm "'+ symlinkObject.link +'"';
            var command2:String = 'ln -s "'+ symlinkObject.resources +'" "'+ symlinkObject.link +'"';

            npInfo.arguments = Vector.<String>(["-c", command1 +";"+ command2]);
            npInfo.workingDirectory = this.baseDirectory.resolvePath(symlinkObject.workingDirectory);

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
	}
}
