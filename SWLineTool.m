/**
 * Copyright 2007-2009 Soggy Waffles
 * 
 * This file is part of Paintbrush.
 * 
 * Paintbrush is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "SWLineTool.h"

@implementation SWLineTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path moveToPoint:begin];
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		// x and y are either positive or negative 1
		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/¹)
		// atan()'s result is in radians
		CGFloat theta = 180*atan((end.y-begin.y)/(end.x-begin.x)) / pi;
		
		// Deciding whether it should be horizontal, vertical, or at 45¼
		NSPoint newPoint = NSZeroPoint;
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			// ¹/4
			newPoint = NSMakePoint(size*x, size*y);
		} else if (abs(theta) > 67.5) {
			// ¹/2
			newPoint = NSMakePoint(0, (end.y-begin.y));
		} else {
			// 0
			newPoint = NSMakePoint((end.x - begin.x), 0);
		}
		
		[path relativeLineToPoint:newPoint];
	} else {
		[path lineToPoint:end];
	}
	
	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	// Use the points clicked to build a redraw rectangle
	[super addRedrawRectFromPoint:savedPoint toPoint:point];

	SWClearImage(bufferImage);
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];		
		drawToMe = mainImage;
	} else {
		drawToMe = bufferImage;
	}
	
	// Which color do we use?
	if (event == MOUSE_DOWN) {
		primaryColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[primaryColor setStroke];
	[[self pathFromPoint:savedPoint toPoint:point] stroke];
	
	[drawToMe unlockFocus];
	return nil;
	
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		customCursor = [[NSCursor crosshairCursor] retain];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Line";
}

@end
