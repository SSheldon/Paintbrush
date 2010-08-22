/**
 * Copyright 2007-2010 Soggy Waffles. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY SOGGY WAFFLES ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SOGGY WAFFLES OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those of the
 * authors and should not be interpreted as representing official policies, either expressed
 * or implied, of Soggy Waffles.
 */


#import "SWAirbrushTool.h"
#import "SWDocument.h"

@implementation SWAirbrushTool


// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	// Custom setting the redraw rect
	redrawRect = NSMakeRect(end.x - 2*lineWidth, end.y - 2*lineWidth, 4*lineWidth, 4*lineWidth);
	
	path = [NSBezierPath bezierPath];
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
