import flash.events.ErrorEvent;
import flash.events.Event;

import mx.controls.Alert;

import air.update.events.DownloadErrorEvent;
import air.update.events.StatusUpdateEvent;
import air.update.events.UpdateEvent;

[Bindable] protected var downlaoding:Boolean = false;
[Bindable] protected var isUpdater:Boolean;

protected function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
{
	// Example of custom isNewerFunction function, it can be omitted if one doesn't want
	// to implement it's own version comparison logic. Be default it does simple string
	// comparison.
	return true;
}

protected function updater_errorHandler(event:ErrorEvent):void
{
	Alert.show(event.text);
}

protected function updater_initializedHandler(event:UpdateEvent):void
{
	// When NativeApplicationUpdater is initialized you can call checkNow function
	updater.checkNow();
}
 
protected function updater_updateStatusHandler(event:StatusUpdateEvent):void
{
	if (event.available)
	{
		// In case update is available prevent default behavior of checkNow() function 
		// and switch to the view that gives the user ability to decide if he wants to
		// install new version of the application.
		event.preventDefault();
		//currentState = "Update";
		isUpdater = true;
		onUpdateFound();
	}
	else
	{
		//Alert.show("Your application is up to date!");
	}
}

protected function btnNo_clickHandler(event:Event):void
{
	updaterView.close();
	updaterView.removeEventListener("UPDATEYES", btnYes_clickHandler);
	updaterView.removeEventListener("UPDATENO", btnNo_clickHandler);
	updaterView.removeEventListener("UPDATECANCEL", btnCancel_clickHandler);
	updaterView = null;
}

protected function btnCancel_clickHandler(event:Event):void
{
	updater.cancelUpdate();
	btnNo_clickHandler(null);
}

protected function btnYes_clickHandler(event:Event):void
{
	 
	// In case user wants to download and install update display download progress bar
	// and invoke downloadUpdate() function.
	downlaoding = true;
	updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updater_downloadErrorHandler);
	updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
	updater.downloadUpdate();
}

private function updater_downloadCompleteHandler(event:UpdateEvent):void
{
	// When update is downloaded install it.
	//updater.installUpdate();
}
 
private function updater_downloadErrorHandler(event:DownloadErrorEvent):void
{
	Alert.show("Error downloading update file, try again later.");
}