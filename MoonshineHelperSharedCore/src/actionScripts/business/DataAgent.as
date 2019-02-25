package actionScripts.business
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * DataAgent
	 * 
	 * Copyright @ - Prominic Inc.
	 * @author santanu.k
	 * @version 1.0
	 * 
	 * The agent designed in the way as
	 * one at a time usage - do not
	 * use for parallel use, if you needs to
	 * do that then create different instances of
	 * the class.
	 */
	public class DataAgent
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC CONST
		//
		//--------------------------------------------------------------------------
		
		public static const GENERICPOSTEVENT		: String = "GENERICPOSTEVENT";
		public static const POSTEVENT				: String = "POST";
		public static const GETEVENT				: String = "GET";
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var successFunctionCallback		: Function; // Holds the author component's success handler (param: errorMessage, successMessage ..args)
		public var errorFunctionCallback		: Function; // Holds the author component's fault handler (param: errorMessage)
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------
		
		private var httpService					: URLLoader;
		
		/**
		 * CONSTRUCTOR
		 * 
		 * Initiates HTTP request event for any
		 * GET or POST data transaction
		 * 
		 * @required
		 * type, successFunction, errorFunction
		 * @optional
		 * postURL, postObject, timeoutSeconds
		 */
		public function DataAgent(_postURL:String, _successFn:Function, _errorFn:Function, _anObject:Object = null, _eventType:String=POSTEVENT, _timeout:Number=0 )
		{
			successFunctionCallback = _successFn;
			errorFunctionCallback = _errorFn;
			
			// starting the call
			var urlVariables : URLVariables = new URLVariables();
			var urlVariablesFieldCount : int;
			for ( var i:String in _anObject ) {
				urlVariables[ i ] = encodeURI(_anObject[ i ]);
				urlVariablesFieldCount ++;
			}
			
			var request : URLRequest = new URLRequest();
			request.data = urlVariables;
			request.url = ( urlVariablesFieldCount == 1 ) ? _postURL+"&" : _postURL;
			request.method = _eventType;
			
			httpService = new URLLoader();
			httpService.addEventListener( Event.COMPLETE, onSuccess );
			httpService.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			httpService.load( request );
		}
		
		//--------------------------------------------------------------------------
		//
		//  PROTECTED API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Dispose everything 
		 */
		protected function dispose() : void
		{
			// probable termination
			if ( !httpService ) return;
			
			httpService.close();
			httpService.removeEventListener( Event.COMPLETE, onSuccess );
			httpService.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			successFunctionCallback = errorFunctionCallback = null;
			httpService = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On success callback
		 */
		private function onSuccess( event:Event ) : void
		{
			if ( successFunctionCallback != null ) successFunctionCallback( null, event.target.data );
			
			// finally clear the event
			dispose();
		}
		
		/**
		 * On error callback
		 */
		private function onIOError( event:IOErrorEvent ) : void
		{
			// Fault definition of having a 'onErrorPostHandler()'
			// in the Post event initiator component.
			errorFunctionCallback( event.text );
			
			// finally clear the event
			dispose();
		}
	}
}