package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	import moonshine.haxeScripts.valueObjects.ComponentVO;

	public class LinkVerifierAS extends NativeProcess
	{
		private var loader:URLLoader;
		private var resultHandler:Function;
		private var component:ComponentVO;

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

		private function removeListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
			dispatcher.removeEventListener(Event.OPEN, openHandler);
			dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}

		private function completeHandler(event:Event):void
		{
			relayResult(true);
		}

		private function openHandler(event:Event):void
		{
			trace("openHandler: " + event);
		}

		private function progressHandler(event:ProgressEvent):void
		{
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + event.text);
			relayResult(false);
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			trace("httpStatusHandler: " + event.status);
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace("ioErrorHandler: " + event.text);
			relayResult(false);
		}
		
		private function relayResult(value:Boolean):void
		{
			if (resultHandler != null) 
				resultHandler(value, component);

			dispose();
		}
		
		private function dispose():void
		{
			removeListeners(loader);
			resultHandler = null;
			component = null;
			loader = null;
		}
	}
}