////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package ws.tink.spark.controls
{
	import flash.events.Event;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.components.DataRenderer;
	import spark.components.IItemRenderer;
	
	public class StepRendererBase extends DataRenderer implements IItemRenderer
	{
		public function StepRendererBase()
		{
			super();
		}
		
		private var _itemIndex:int;
		[Bindable("itemIndexChanged")]
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			if( _itemIndex == value ) return;
			_itemIndex = value;
			dispatchEvent(new Event("itemIndexChanged"));
		}
		
		private var _stateColor:Number;
		[Bindable(type="currentStateChange")]
		public function get stateColor():Number { return _stateColor; }
		
		
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			invalidateProperties();
		}
		
		override public function setCurrentState(stateName:String, playTransition:Boolean=true):void
		{
			_stateColor = stateName == "normal" ? getStyle( "color" ) : getStyle( stateName + "Color" );
			super.setCurrentState(stateName, playTransition);
		}
		
		override protected function commitProperties():void
		{
			if (data && data is StepItem && hasState( StepItem( data ).status ))
			{
				setCurrentState( StepItem( data ).status );
			}
			else
			{
				setCurrentState( "normal" );
			}
			
			toolTip = (data && data is StepItem )? StepItem( data ).label : "";
			
			super.commitProperties();
		}
		
		public function get label():String
		{
			return "";
		}
		
		public function set label(value:String):void
		{
		}
		public function get selected():Boolean
		{
			return false;
		}
		
		public function set selected(value:Boolean):void
		{
		}
		
		public function get showsCaret():Boolean
		{
			return false;
		}
		
		public function set showsCaret(value:Boolean):void
		{
		}
		
		public function get dragging():Boolean
		{
			return false;
		}
		
		public function set dragging(value:Boolean):void
		{
		}
		
	}
}
