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
	import mx.core.IVisualElement;
	
	import spark.layouts.BasicLayout;
	
	public class PercentLayout extends BasicLayout
	{
		public function PercentLayout()
		{
			super();
		}
		
		//----------------------------------
		//  resizeItems
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for resizeItems.
		 */
		private var _resizeItems:Array;
		
		/**
		 *  resizeItems
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get resizeItems():Array
		{
			return _resizeItems;
		}
		/**
		 *  @private
		 */
		public function set resizeItems(value:Array):void
		{
			if( _resizeItems == value ) return;
			
			_resizeItems = value;
		}
		
		//----------------------------------
		//  percent
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for percent.
		 */
		private var _percent:Number = 0;
		
		/**
		 *  percent
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get percent():Number
		{
			return _percent;
		}
		/**
		 *  @private
		 */
		public function set percent(value:Number):void
		{
			if( _percent == value ) return;
			
			_percent = value;
			target.invalidateDisplayList();
		}
		
		
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( resizeItems && resizeItems.length )
			{
				var element:IVisualElement;
				var originalSize:Number;
				var minSize:Number;
				var availableChange:Number;
				
				for each (var item:Object in resizeItems) 
				{
					if( item is IVisualElement )
					{
						element = IVisualElement( item );
						originalSize = element.getLayoutBoundsWidth();
						minSize = element.getMinBoundsWidth();
						availableChange = originalSize - minSize;
						element.setLayoutBoundsSize( minSize + ( availableChange * ( percent / 100 ) ), element.getLayoutBoundsHeight() );
					}
				}
			}
			
			
		}
	}
}
