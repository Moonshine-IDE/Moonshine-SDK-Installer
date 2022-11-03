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
package ws.tink.spark.layouts
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class EllipseLayout extends LayoutBase
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function EllipseLayout()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  startAngle
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for startAngle.
		 */
		private var _startAngle:Number = 0;
		
		[Inspectable(category="General")]
		/**
		 *  startAngle
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get startAngle():Number
		{
			return _startAngle;
		}
		/**
		 *  @private
		 */
		public function set startAngle( value:Number ):void
		{
			if( _startAngle == value ) return;
			
			_startAngle = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  endAngle
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for endAngle.
		 */
		private var _endAngle:Number = 0;
		
		[Inspectable(category="General")]
		/**
		 *  endAngle
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get endAngle():Number
		{
			return _endAngle;
		}
		/**
		 *  @private
		 */
		public function set endAngle( value:Number ):void
		{
			if( _endAngle == value ) return;
			
			_endAngle = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  position
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for position.
		 */
		private var _position:String = "inset";
		
		[Inspectable(category="General")]
		/**
		 *  @private
		 *  Storage property for position.
		 */
		public function get position():String
		{
			return _position;
		}
		/**
		 *  @private
		 */
		public function set position( value:String ):void
		{
			if( _position == value ) return;
			
			_position = value;
			invalidateDisplayList();
		}
		
		public var rotate:Boolean = false;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function updateDisplayListVirtual( width:Number, height:Number ):void
		{
			
			
			
			
		}
		
		/**
		 *  @private
		 */
		private function distance( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			const dx:Number = x2 - x1;
			const dy:Number = y2 - y1;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
		/**
		 *  @private
		 */
		private function invalidateDisplayList():void
		{
			if( !target ) return;
			
			target.invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width,height);
			
			if( !target ) return;
			
			var element:ILayoutElement;
			const numElements:int = target.numElements;
			const angle:Number = 360 / numElements;
			const radiusX:Number = width / 2;
			const radiusY:Number = height / 2;
			var a:Number = startAngle;
			for (var i:int = 0; i < numElements; i++) 
			{
				a = startAngle + ( angle * i );
				element = target.getElementAt( i );
				element.setLayoutBoundsSize( element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight() );
				if( rotate )
				{
					element.transformAround( new Vector3D( element.getPreferredBoundsWidth() / 2, radiusY, 0 ),
						null,
						new Vector3D( 0, 0, a ),
						new Vector3D( radiusX, radiusY, 0 ) );
				}
				else
				{
					element.setLayoutBoundsPosition( radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 ),
						radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 ) );
				}
				//				switch( position )
				//				{
				//					case "inset" :
				//					{
				//						
				//						break;
				//					}
				//					default :
				//					{
				//						
				//						
				//					}
				//				}
				
				//				var m:Matrix = new Matrix();
				//				m.tx = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 );
				//				m.ty = radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 );
				//				m.rotate( a * ( Math.PI / 180 ) );
				//				m.tx = m.ty = 200;
				//								m.tx = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 );
				//								m.ty = radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 );
				//				element.setLayoutMatrix( m, false );
				
				//				var x:Number = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) );
				//				var y:Number = radiusY + ( radiusY * Math.cos(a * ( Math.PI / 180 ) ) );
				//				
				//				
				//				trace( i, distance( radiusX, radiusY, x, y ), x, y, radiusX, radiusY );
				
				
			}
		}
		
		
	}
}