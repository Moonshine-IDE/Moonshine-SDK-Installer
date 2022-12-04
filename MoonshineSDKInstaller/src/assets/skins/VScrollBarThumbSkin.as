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
package assets.skins
{
	import mx.skins.ProgrammaticSkin;

	[Style(name="thumbColorLeft", type="uint", format="color", inherit="yes")]
	[Style(name="thumbColorRight", type="uint", format="color", inherit="yes")]
	[Style(name="thumbLeftSideLine", type="uint", format="color", inherit="yes")]
	[Style(name="thumbHline1", type="uint", format="color", inherit="yes")]
	[Style(name="thumbHline2", type="uint", format="color", inherit="yes")]
	public class VScrollBarThumbSkin extends ProgrammaticSkin
	{
		public function VScrollBarThumbSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// background
			graphics.clear();
			graphics.beginFill(getStyle('thumbColorLeft'));
			graphics.drawRect(-8, 0, 15, unscaledHeight);
			graphics.endFill();
			
			// hilight
			graphics.beginFill(getStyle('thumbColorRight'));
			graphics.drawRect(0, 0, 7, unscaledHeight);
			graphics.endFill();
			
			// left side line
			graphics.beginFill(getStyle('thumbLeftSideLine'));
			graphics.drawRect(-8, 0, 1, unscaledHeight);
			graphics.endFill();
			
			// middle drag-lines
			graphics.lineStyle(1, getStyle('thumbHline1'), 1, false);
			
			// Only draw one line if the scrubber is supersmall
			if (unscaledHeight > 15)
			{
				graphics.moveTo(-4, int(unscaledHeight/2)-4);
				graphics.lineTo(4,  int(unscaledHeight/2)-4);
				
				graphics.moveTo(-4, int(unscaledHeight/2)+4);
				graphics.lineTo(4,  int(unscaledHeight/2)+4);
			}
			
			graphics.moveTo(-4, int(unscaledHeight/2));
			graphics.lineTo(4,	 int(unscaledHeight/2));
			
			
			graphics.lineStyle(1, getStyle('thumbHline2'), 0.3, false);

			if (unscaledHeight > 15)
			{
				graphics.moveTo(-4, int(unscaledHeight/2)-3);
				graphics.lineTo(4,	 int(unscaledHeight/2)-3);
				
				graphics.moveTo(-4, int(unscaledHeight/2)+5);
				graphics.lineTo(4,	 int(unscaledHeight/2)+5);	
			}
			
			graphics.moveTo(-4, int(unscaledHeight/2)+1);
			graphics.lineTo(4,	 int(unscaledHeight/2)+1);
			
		}
		
	}
}