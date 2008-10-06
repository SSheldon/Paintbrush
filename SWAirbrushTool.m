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


#import "SWAirbrushTool.h"

@implementation SWAirbrushTool


// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	// Custom setting the redraw rect
	redrawRect = NSMakeRect(end.x - 2*lineWidth, end.y - 2*lineWidth, 4*lineWidth, 4*lineWidth);
	
	path = [NSBezierPath new];
	[path setLineWidth:0];
	[path setLineCapStyle:NSRoundLineCapStyle];
	NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:redrawRect];
	
	NSInteger i, x, y;
	for (i = 0; i < (lineWidth*lineWidth)/2; i++) {
		do {
			x = (random() % (4*(int)lineWidth))+end.x - 2*lineWidth;
			y = (random() % (4*(int)lineWidth))+end.y - 2*lineWidth;
		} while (![circle containsPoint:NSMakePoint(x,y)]);
		[path appendBezierPathWithRect:NSMakeRect(x,y,0.0,0.0)];
	}
	return path;
}

- (void)performDrawAtPoint:(NSPoint)point 
			 withMainImage:(NSImage *)anImage 
			   secondImage:(NSImage *)secondImage 
				mouseEvent:(SWMouseEvent)event
{
	p = point;
	if (event == MOUSE_UP) {
		[self endSpray:airbrushTimer];
	} else if (event == MOUSE_DOWN) {
		// Seed a random number based on the time!
		srandom(time(NULL));

		_secondImage = secondImage;
		_anImage = anImage;
		airbrushTimer = [NSTimer scheduledTimerWithTimeInterval:0.002 // 1 ms
														 target:self
													   selector:@selector(spray:)
													   userInfo:nil
														repeats:YES];
		isSpraying = YES;
	}
	path = nil;
}

- (void)spray:(NSTimer *)timer
{
	[_secondImage lockFocus]; 
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	if (flags & NSAlternateKeyMask) {
		[backColor setStroke];	
	} else {
		[frontColor setStroke];
	}
	[[self pathFromPoint:savedPoint toPoint:p] stroke];
	savedPoint = p;
	
	[_secondImage unlockFocus];
	
	// Get the view to perform a redraw to see the new spray
	[NSApp sendAction:@selector(refreshImage:)
				   to:nil
				 from:self];
	
}

// Once they lift the mouse button, this happens
- (void)endSpray:(NSTimer *)timer
{
	[timer invalidate];
	
	isSpraying = NO;
	
	[NSApp sendAction:@selector(prepUndo:)
				   to:nil
				 from:nil];
	[_anImage lockFocus];
	[_secondImage drawAtPoint:NSZeroPoint
					fromRect:NSZeroRect
				   operation:NSCompositeSourceOver 
					fraction:1.0];
	[_anImage unlockFocus];
	
	// This loop removes all the representations in the overlay image, effectively clearing it
	for (NSImageRep *rep in [_secondImage representations]) {
		[_secondImage removeRepresentation:rep];
	}		
}

- (NSCursor *)cursor
{
	NSImage *customImage = [NSImage imageNamed:@"airbrush-cursor-2.png"];
	NSCursor *customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(6,3)];
	return customCursor;
}


- (void)tieUpLooseEnds
{
	if (isSpraying) {
		[self endSpray:airbrushTimer];
	}
}


- (NSString *)description
{
	return @"Airbrush";
}

@end
