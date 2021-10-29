package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.IDataInput;

	import spark.components.Alert;
	
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.HelperConstants;
	
	public class LinkVerifierAS extends NativeProcess
	{
		private var loader:URLLoader;
		private var resultHandler:Function;
		private var component:ComponentVO;
		private var isSuccessOrError:Boolean;
		
		/**
		 * resultHandler --> BOOL, ComponentVO
		 * Example,
		 * function myResultHandler(success:Boolean, component:ComponentVO)
		 */
		public function LinkVerifierAS(component:ComponentVO,
									   resultHandler:Function,
									   directURL:String=null)
		{
			super();
			
			this.resultHandler = resultHandler;
			this.component = component;

			loader = new URLLoader();
			configureListeners(loader);

			var request:URLRequest = new URLRequest(directURL ? directURL : component.downloadURL);
			request.method = URLRequestMethod.HEAD;
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}

		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}

		private function completeHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			Alert.show("completeHandler: " + loader.data);
		}

		private function openHandler(event:Event):void {
			Alert.show("openHandler: " + event);
		}

		private function progressHandler(event:ProgressEvent):void {
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			Alert.show("securityErrorHandler: " + event.text);
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void {
			Alert.show("httpStatusHandler: " + event.status);
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
			Alert.show("ioErrorHandler: " + event.text);
		}
		
		private function relayResult(value:Boolean):void
		{
			if (resultHandler != null) 
				resultHandler(value, component);
		}
		
		private function dispose():void
		{

			resultHandler = null;
			component = null;
			isSuccessOrError = true;
		}
	}
}