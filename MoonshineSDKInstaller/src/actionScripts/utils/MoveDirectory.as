package actionScripts.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import actionScripts.events.HelperEvent;
	
	[Event(name="deletingOldDirectory", type="flash.events.Event")]
	[Event(name="deletedOldDirectory", type="flash.events.Event")]
	[Event(name="directoryMoveCompleted", type="flash.events.Event")]
	[Event(name="directoryMoveFailed", type="actionScripts.events.HelperEvent")]
	public class MoveDirectory extends EventDispatcher
	{
		public static const EVENT_DELETING_OLD_DIRECTORY:String = "deletingOldDirectory";
		public static const EVENT_DELETED_OLD_DIRECTORY:String = "deletedOldDirectory";
		public static const EVENT_DIRECTORY_MOVE_COMPLETED:String = "directoryMoveCompleted";
		public static const EVENT_DIRECTORY_MOVE_FAILED:String = "directoryMoveFailed";
		
		private var fromDirectory:File;
		private var toDirectory:File;
		
		public function MoveDirectory() {}
		
		public function move(fromDir:String, toDir:String):void
		{
			this.fromDirectory = new File(fromDir);
			this.toDirectory = new File(toDir);
			
			// delete the earlier folder first
			if (this.toDirectory.exists)
			{
				deletePreviousDirectory();
			}
		}
		
		protected function deletePreviousDirectory():void
		{
			dispatchEvent(new Event(EVENT_DELETING_OLD_DIRECTORY));
			FileUtils.deleteDirectoryAsync(toDirectory, onDeletionCompleted, onDeleteionError);
			
			/*
			* @local
			*/
			function onDeletionCompleted():void
			{
				dispatchEvent(new Event(EVENT_DELETED_OLD_DIRECTORY));
				renameNewerDirectory();
			}
			function onDeleteionError(value:String):void
			{
				dispatchEvent(new HelperEvent(EVENT_DIRECTORY_MOVE_FAILED, value));
				dispose();
			}
		}
		
		protected function renameNewerDirectory():void
		{
			manageListeners(fromDirectory, true) 
			fromDirectory.moveToAsync(toDirectory);
			
			/*
			* @local
			*/
			function completeHandlerMove(event:Event):void
			{
				manageListeners(event.target as File, false);
				dispatchEvent(new Event(EVENT_DIRECTORY_MOVE_COMPLETED));
				dispose();
			}
			function onIOErrorMove(event:IOErrorEvent):void
			{
				manageListeners(event.target as File, false);
				dispatchEvent(new HelperEvent(EVENT_DIRECTORY_MOVE_FAILED, event.text));
				dispose();
			}
			function manageListeners(origin:File, attach:Boolean):void
			{
				if (attach)
				{
					origin.addEventListener(Event.COMPLETE, completeHandlerMove);
					origin.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorMove);
				}
				else
				{
					origin.removeEventListener(Event.COMPLETE, completeHandlerMove);
					origin.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorMove);
				}
			}
		}
		
		private function dispose():void
		{
			fromDirectory = null;
			toDirectory = null;
		}
	}
}