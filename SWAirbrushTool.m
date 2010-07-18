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


#import "SWAirbrushTool.h"
#import "SWDocument.h"

@implementation SWAirbrushTool


// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	// Custom setting the redraw rect
	redrawRect = NSMakeRect(end.x - 2*lineWidth, end.y - 2*lineWidth, 4*lineWidth, 4*lineWidth);
	
	path = [NSBezierPath new];
//	[path setLineWidth:0];
	NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:redrawRect];
	
	NSInteger i, x, y;
	NSInteger modNumber = 4*(int)lineWidth;
	for (i = 0; i < (lineWidth*lineWidth)/2; i++) {
		do {
			x = (random() % modNumber)+end.x - 2*lineWidth;
			y = (random() % modNumber)+end.y - 2*lineWidth;
		} while (![circle containsPoint:NSMakePoint(x,y)]);
		[path appendBezierPathWithRect:NSMakeRect(x,y,0.0,0.0)];
	}
	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	p = point;
	if (event == MOUSE_UP) {
		[self endSpray:airbrushTimer];
	} else if (event == MOUSE_DOWN) {		
		// Seed a random number based on the time!
		srandom(time(NULL));

		_bufferImage = bufferImage;
		_mainImage = mainImage;

		// Prep the images
		[SWImageTools drawToImage:_bufferImage fromImage:_mainImage withComposition:NO];

		airbrushTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 // 20 ms
														 target:self
													   selector:@selector(spray:)
													   userInfo:nil
														repeats:YES];
		isSpraying = YES;
	}
	path = nil;
	return nil;
}

- (void)spray:(NSTimer *)timer
{
	SWLockFocus(_bufferImage); 
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	if (flags & NSAlternateKeyMask) {
		[backColor setStroke];	
	} else {
		[frontColor setStroke];
	}
	[[self pathFromPoint:savedPoint toPoint:p] stroke];
	savedPoint = p;
	
	SWUnlockFocus(_bufferImage);
	
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
	
	[document handleUndoWithImageData:nil frame:NSZeroRect];
	[SWImageTools drawToImage:_mainImage fromImage:_bufferImage withComposition:NO];
	[SWImageTools clearImage:_bufferImage];
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"airbrush-cursor-2.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(6,3)];
	}
	return customCursor;
}


- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	if (isSpraying) {
		[self endSpray:airbrushTimer];
	}
	
	[super tieUpLooseEnds];
}


- (NSString *)description
{
	return @"Airbrush";
}

@end
