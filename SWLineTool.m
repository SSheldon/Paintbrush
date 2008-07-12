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


#import "SWLineTool.h"

@implementation SWLineTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path moveToPoint:begin];
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		// Here comes the crazy math. First, we find the length of the hypotenuse of the
		// imaginary triangle formed by the line
		double hypotenuse = sqrt(pow((end.x-begin.x),2)+pow((end.y-begin.y),2));
		
		// Size is the base/height of the 45¼ triangle
		double size = hypotenuse/sqrt(2);
		
		// x and y are either positive or negative 1
		int x = (end.x-begin.x) / abs(end.x-begin.x);
		int y = (end.y-begin.y) / abs(end.y-begin.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/¹)
		// atan()'s result is in radians
		double theta = 180*atan((end.y-begin.y)/(end.x-begin.x)) / 3.1415926535;
		
		// Deciding whether it should be horizontal, vertical, or at 45¼
		NSPoint newPoint = NSZeroPoint;
		
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			newPoint = NSMakePoint(size*x, size*y);
		} else if (abs(theta) > 67.5) {
			newPoint = NSMakePoint(0, (end.y-begin.y));
		} else {
			newPoint = NSMakePoint((end.x - begin.x), 0);
		}
		
		[path relativeLineToPoint:newPoint];
	} else {
		[path lineToPoint:end];
	}
	
	return path;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(SWMouseEvent)event
{
	// Use the points clicked to build a redraw rectangle
	//[super setRedrawRectFromPoint:savedPoint toPoint:point];

	// This loop removes all the representations in the overlay image, effectively clearing it
	for (NSImageRep *rep in [secondImage representations]) {
		[secondImage removeRepresentation:rep];
	}
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];		
		drawToMe = anImage;
	} else {
		drawToMe = secondImage;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[frontColor setStroke];
	[[self pathFromPoint:savedPoint toPoint:point] stroke];
	
	[drawToMe unlockFocus];
	return;
	
}


- (NSString *)name
{
	return @"Line";
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

@end
