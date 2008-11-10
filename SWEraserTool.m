/**
 * Copyright 2007, 2008 Soggy Waffles
 *
 * This file is part of Paintbrush.
 *
 * Paintbrush is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */


#import "SWEraserTool.h"

@implementation SWEraserTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (!path) {
		path = [NSBezierPath new];
		[path setLineWidth:lineWidth];
	}
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	[path moveToPoint:begin];
	[path lineToPoint:end];
	
	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSImage *)anImage 
						 secondImage:(NSImage *)secondImage 
						  mouseEvent:(SWMouseEvent)event
{	
	// Use the points clicked to build a redraw rectangle
	[super addRedrawRectFromPoint:point toPoint:savedPoint];
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		[anImage lockFocus];
		[secondImage drawAtPoint:NSZeroPoint
						fromRect:NSZeroRect
					   operation:NSCompositeSourceOver 
						fraction:1.0];
		[anImage unlockFocus];
		
		path = nil;
	} else {		
		[secondImage lockFocus]; 
		
		// The best way I can come up with to clear the image
		[[NSColor clearColor] setFill];
		NSRectFill(NSMakeRect(0,0,[secondImage size].width, [secondImage size].height));
		
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		if (flags & NSAlternateKeyMask) {
			[frontColor setStroke];	
		} else {
			[backColor setStroke];
		}
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		savedPoint = point;
		
		[secondImage unlockFocus];
	}
	return nil;
}

- (NSCursor *)cursor
{
	NSImage *customImage = [NSImage imageNamed:@"eraser-cursor.png"];
	NSCursor *customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(2,12)];
	return customCursor;
}

- (NSColor *)drawingColor
{
	return backColor;
}

- (NSString *)description
{
	return @"Eraser";
}

@end
