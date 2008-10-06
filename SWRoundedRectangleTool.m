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


#import "SWRoundedRectangleTool.h"

@implementation SWRoundedRectangleTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSSquareLineCapStyle];
	[path moveToPoint:begin];
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	
//	// Normally this would work, but there are problems with the NSBezierPath rounded rect
//	if (flags & NSShiftKeyMask) {
//		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
//		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
//		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
//		[path appendBezierPathWithRoundedRect:NSMakeRect(begin.x, begin.y, x*size, y*size) xRadius:30 yRadius:30];
//	} else {
//		[path appendBezierPathWithRoundedRect:NSMakeRect(begin.x, begin.y, (end.x - begin.x), (end.y - begin.y)) xRadius:30 yRadius:30];
//	}
	
	// Some weird stuff, since roundedRects are picky and require positive widths and heights
	NSPoint temp = begin;
	BOOL negX = NO, negY = NO;
	if ((end.x - begin.x) < 0) {
		negX = YES;
		temp.x = begin.x;
		begin.x = end.x;
		end.x = temp.x;
	}
	
	if ((end.y - begin.y) < 0) {
		negY = YES;
		temp.y = begin.y;
		begin.y = end.y;
		end.y = temp.y;
	}
	
	if (flags & NSShiftKeyMask) {
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		
		if (negX) {
			begin.x -= size - abs(end.x - begin.x);
		}
		if (negY) {
			begin.y -= size - abs(end.y - begin.y);
		}
		
		NSLog(@"Size is %lf, (end.x - begin.x) is %lf, (end.y - begin.y) is %lf", size, (end.x - begin.x), (end.y - begin.y));
		
		
		
		[path appendBezierPathWithRoundedRect:NSMakeRect(begin.x, begin.y, size, size) 
									  xRadius:30
									  yRadius:30];
	} else {
		//NSLog(@"Width is %lf, height is %lf)", (end.x - begin.x), (end.y - begin.y));
		[path appendBezierPathWithRoundedRect:NSMakeRect(begin.x, begin.y, (end.x - begin.x), (end.y - begin.y)) 
									  xRadius:30 
									  yRadius:30];
	}
	
	return path;	
}

- (void)performDrawAtPoint:(NSPoint)point 
			 withMainImage:(NSImage *)anImage 
			   secondImage:(NSImage *)secondImage 
				mouseEvent:(SWMouseEvent)event
{
	// Use the points clicked to build a redraw rectangle
	[super setRedrawRectFromPoint:savedPoint toPoint:point];

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
	
	// Which colors should we draw with?
	if (event == MOUSE_DOWN) {
		if (flags & NSAlternateKeyMask) {
			primaryColor = backColor;
			secondaryColor = frontColor;
		} else {
			primaryColor = frontColor;
			secondaryColor = backColor;
		}
	}
	
	if (shouldFill && shouldStroke) {
		[primaryColor setStroke];
		[secondaryColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	} else if (shouldFill) {
		[primaryColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
	} else if (shouldStroke) {
		[primaryColor setStroke];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	}
	
	[drawToMe unlockFocus];
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shouldShowFillOptions
{
	return YES;
}

- (NSString *)description
{
	return @"Rounded Rectangle";
}

@end
