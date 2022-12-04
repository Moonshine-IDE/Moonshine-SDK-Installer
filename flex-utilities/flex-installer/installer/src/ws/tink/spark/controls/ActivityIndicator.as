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
	import mx.events.FlexEvent;
	import mx.managers.IToolTipManagerClient;
	
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	import ws.tink.spark.controls.Rotator;

	/**
	 *  An indicator showing the indeterminate progress of a task.
	 *
	 * 	@langversion 3.0
	 * 	@playerversion Flash 10
	 * 	@playerversion AIR 1.5
	 * 	@productversion Flex 4
	 */
	public class ActivityIndicator extends SkinnableComponent
	{

		

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  Constructor
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ActivityIndicator()
		{
			addEventListener(FlexEvent.SHOW, showHandler, false, 0, true);
			addEventListener(FlexEvent.HIDE, hideHandler, false, 0, true);
		}

		
		
		//--------------------------------------------------------------------------
		//
		//  SkinParts
		//
		//--------------------------------------------------------------------------	
		
		//----------------------------------
		//  indicator
		//----------------------------------
		
		[SkinPart(required='true')]
		/**
		 *  The rotator used to show an indicator
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var indicator:IAnimator;
		
		//----------------------------------
		//  label
		//----------------------------------
		
		[SkinPart]
		/**
		 *  The labelDisplay to show the activity status
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var labelDisplay:Label;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------	

		//----------------------------------
		//  label
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for label.
		 */
		private var _label:String = '';
		
		/**
		 *  Text representing the status of the activity in progress.
		 *  This will be shown to the user, depending on the skin.
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get label():String
		{
			if(_label == '')
				return null;
			return _label;
		}
		/**
		 *  @private
		 */
		public function set label(value:String):void
		{
			if( _label == value ) return;
			
			_label = value;
			
			if (indicator && indicator is IToolTipManagerClient)
				IToolTipManagerClient( indicator ).toolTip = label;
			
			if (labelDisplay)
				labelDisplay.text = _label;
		}

		
		//----------------------------------
		//  autoAnimate
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for autoAnimate.
		 */
		private var _autoAnimate:Boolean = true;
		
		[Inspectable(type="Boolean",defaultValue="true")]
		/**
		 *  Indicates that the <code>ActivityIndicator</code> should animate by default.
		 *
		 *  This includes starting and stopping the animation when the component is shown and hidden.
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get autoAnimate():Boolean
		{
			return _autoAnimate;
		}
		/**
		 *  @private
		 */
		public function set autoAnimate(value:Boolean):void
		{
			_autoAnimate = value;
			if (value && visible)
				play();
			else
				stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  Start the activity animation.
		 *  This can be managed automatically when show/hidden using autoAnimate.
		 * 
		 *  @see autoAnimate
		 * 
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */	
		public function play():void
		{
			if (indicator)
				indicator.play();
		}

		/**
		 *  Stop the activity animation.
		 *  This can be managed automatically when show/hidden using autoAnimate.
		 * 
		 *  @see autoAnimate
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */	
		public function stop():void
		{
			if (indicator)
				indicator.stop();
		}

		

		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  @private
		 */
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch( instance )
			{
				case indicator :
				{
					if( label && indicator is IToolTipManagerClient )
						IToolTipManagerClient( indicator ).toolTip = label;
					if( autoAnimate ) play();
					break;
				}
				case labelDisplay :
				{
					labelDisplay.text = label;
					break;
				}
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  @private
		 */
		private function hideHandler(event:FlexEvent):void
		{
			if( autoAnimate ) stop();
		}
		
		/**
		 *  @private
		 */
		private function showHandler(event:FlexEvent):void
		{
			if (autoAnimate)
				play();
		}
	}
}
