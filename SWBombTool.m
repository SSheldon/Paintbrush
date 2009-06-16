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


#import "SWBombTool.h"

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
		image = bufferImage;
		mainImage = mainImage;
		
		// We do this to make a copy of the color
		bombColor = (flags & NSAlternateKeyMask) ? frontColor : backColor;
		
		if (flags & NSShiftKeyMask) {
			bombSpeed = 2;
		} else {
			bombSpeed = 25;
		}
		max = sqrt([mainImage size].width*[mainImage size].width + [mainImage size].height*[mainImage size].height);
		bombTimer = [NSTimer scheduledTimerWithTimeInterval:0.000001 // 1 μs
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
		[mainImage lockFocus];
		
		//SWClearImageRect(image, rect);
		
//		[[NSColor clearColor] set];
//		[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		[bombColor set];
		[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
		[NSGraphicsContext restoreGraphicsState];
		[mainImage unlockFocus];
		
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
	[NSApp sendAction:@selector(prepUndo:)
				   to:nil
				 from:nil];
	
	[mainImage lockFocus];	
	[bombColor set];
	NSRectFill(NSMakeRect(0,0,[mainImage size].width, [mainImage size].height));
	[mainImage unlockFocus];

	SWClearImage(image);
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
}

- (NSString *)description
{
	return @"Bomb";
}

@end
