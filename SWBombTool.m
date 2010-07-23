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


#import "SWBombTool.h"
#import "SWDocument.h"

@implementation SWBombTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{	
	if (event == MOUSE_DOWN) {
		// If there's an explosion going on, kill it
		if (isExploding) {
			[self endExplosion:bombTimer];
		}
		
		i = 0;
		rect = NSZeroRect;
		p = point;
		_bufferImage = bufferImage;
		_mainImage = mainImage;
		
		// We do this to make a copy of the color
		bombColor = (flags & NSAlternateKeyMask) ? frontColor : backColor;
		
		if (flags & NSShiftKeyMask) {
			bombSpeed = 2;
		} else {
			bombSpeed = 50;
		}
		max = sqrt([mainImage size].width*[mainImage size].width + [_mainImage size].height*[_mainImage size].height);
		bombTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/60.0) // 1 μs
													 target:self
												   selector:@selector(drawNewCircle:)
												   userInfo:nil
													repeats:YES];
		isExploding = YES;
	}
	return nil;
}

// Each time this method is called (by the timer), a larger circle is drawn. This happens
// until the circle is larger than the image, at which point we can end the animation
- (void)drawNewCircle:(NSTimer *)timer
{
	if (i < max) {
		// Where to draw the circle - it's a square!
		rect.origin.x = p.x - i;
		rect.origin.y = p.y - i;
		rect.size.width = 2*i;
		rect.size.height = 2*i;
		
		// Perform the actual drawing
		SWLockFocus(_mainImage);
		
		//SWClearImageRect(image, rect);
		
//		[[NSColor clearColor] set];
//		[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		[bombColor set];
		[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
		[NSGraphicsContext restoreGraphicsState];
		SWUnlockFocus(_mainImage);
		
		// Change the redraw rect
		redrawRect = rect;

		// Get the view to perform a redraw to see the new circle
		[NSApp sendAction:@selector(refreshImage:)
					   to:nil
					 from:self];
		
		// bombSpeed == either 2 or 25, depending on the shift
		i += bombSpeed;
	} else {
		[self endExplosion:timer];
	}
}

- (void)endExplosion:(NSTimer *)timer
{
	// Stop the timer
	[timer invalidate];
	[document handleUndoWithImageData:nil frame:NSZeroRect];
	
	SWLockFocus(_mainImage);	
	[bombColor set];
	NSRectFill(NSMakeRect(0,0,[_mainImage size].width, [_mainImage size].height));
	SWUnlockFocus(_mainImage);

	[SWImageTools clearImage:_bufferImage];
	[NSApp sendAction:@selector(refreshImage:)
				   to:nil
				 from:nil];
	isExploding = NO;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"bomb-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(8,8)];
	}
	return customCursor;
}


// Overwrite to stop the animation
- (void)tieUpLooseEnds
{
	if (isExploding) {
		[self endExplosion:bombTimer];
	}
	
	[super tieUpLooseEnds];
}

- (NSString *)description
{
	return @"Bomb";
}

@end
