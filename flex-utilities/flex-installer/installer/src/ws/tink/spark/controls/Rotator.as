////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.layouts.supportClasses.LayoutElementHelper;
	import spark.primitives.supportClasses.GraphicElement;
	
	
	/**
	 *  The Rotator control is a simple skinnable component that rotates it's skin when playing.
	 *
	 *  <p>You can set the amount of rotation on each frame by changing the <code>delta</code> property.</p>
	 *
	 *  <p>The List control has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default skin class</td><td>ws.tink.spark.skins.controls.RotatorSkin</td></tr>
	 *  </table>
	 *
	 *  @mxml <p>The <code>&lt;st:Rotator&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:Rotator
	 *    <strong>Properties</strong>
	 *    delta="10"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see ws.tink.spark.skins.controls.RotatorSkin
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class Rotator extends SkinnableComponent implements IAnimator
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
		public function Rotator()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _playing:Boolean;
		
		/**
		 *  @private
		 */
		private var _rotation:Number = 0;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  delta
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for delta.
		 */
		private var _delta:Number = 10;
		
		[Inspectable(type="Boolean", defaultValue="10")]
		/**
		 *  The amount to rotate in degrees each frame.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get delta():Number
		{
			return _delta;
		}
		/**
		 *  @private
		 */
		public function set delta(value:Number):void
		{
			if (_delta == value) return;
			
			_delta = value;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function play():void
		{
			_playing = true;
			addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
		}
		
		/**
		 *  @inheritDoc
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function stop():void
		{
			_playing = false;
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler, false );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function enterFrameHandler( event:Event ):void
		{
			if( skin )
			{
				_rotation += ( 360 / 10 );
				skin.transformAround( new Vector3D( unscaledWidth / 2, unscaledHeight / 2, 0 ),
					new Vector3D( 1, 1, 1 ),
					new Vector3D( 0, 0, _rotation ) );
			}
		}
	}
}
