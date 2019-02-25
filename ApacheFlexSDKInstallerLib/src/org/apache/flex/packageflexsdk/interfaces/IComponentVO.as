package org.apache.flex.packageflexsdk.interfaces
{
	public interface IComponentVO
	{
		function set isDownloading(value:Boolean):void;
		function get isDownloading():Boolean;
		
		function set isDownloaded(value:Boolean):void;
		function get isDownloaded():Boolean;
		
		function set hasError(value:Boolean):void;
		function get hasError():Boolean;
		
		function set isAlreadyDownloaded(value:Boolean):void;
		function get isAlreadyDownloaded():Boolean;
		
		function set isSelectedToDownload(value:Boolean):void;
		function get isSelectedToDownload():Boolean;
		
		function set isSelectionChangeAllowed(value:Boolean):void;
		function get isSelectionChangeAllowed():Boolean;
		
		function set pathValidation(value:Object):void;
		function get pathValidation():Object;
		
		function set downloadURL(value:String):void;
		function get downloadURL():String;
		
		function set installToPath(value:String):void;
		function get installToPath():String;
	}
}