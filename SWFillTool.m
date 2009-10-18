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


#import "SWFillTool.h"
#import "SWSelectionBuilder.h"


@interface SWFillTool (Private)

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(CGFloat)tolerance;
- (void) fillMask:(CGImageRef)mask withColor:(NSColor *)color;

@end


@implementation SWFillTool

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

		// Get the width and height of the image
		w = [mainImage size].width;
		h = [mainImage size].height;
		
		_mainImage = mainImage;
		
		// Which color are we using?
		fillColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
		
		// Check to make sure if we should even bother trying to fill - 
		// if it's the same color, there's nothing to do
		if (!colorsAreEqual([mainImage colorAtX:point.x y:(h - point.y)], 
							[fillColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace])) {			
			// Prep an undo - we're about to change things!
			[NSApp sendAction:@selector(prepUndo:)
						   to:nil
						 from:nil];
			
			// Create the image mask we will be using to fill the selecteds region
			CGImageRef mask = [self floodFillSelect:NSMakePoint(point.x, point.y+1) tolerance:0.0];
			
			// And then fill it!
			[self fillMask:mask withColor:fillColor];
			
			[super addRedrawRectFromPoint:NSZeroPoint toPoint:NSMakePoint([_mainImage pixelsWide], [_mainImage pixelsHigh])];
		}
		
		[imageRep release];
	}
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"bucket-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(14,13)];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Fill";
}

@end

@implementation SWFillTool (Private)

- (CGImageRef)floodFillSelect:(NSPoint)point tolerance:(CGFloat)tolerance
{
	// Building up a selection mask is pretty involved, so we're going to pass
	//	the task to a helper class that can build up temporary state.
	SWSelectionBuilder *builder = [[SWSelectionBuilder alloc] initWithBitmapImageRep:_mainImage point:point tolerance:tolerance];
	CGImageRef ref = [builder mask];
	[builder release];
	return ref;
}

- (void)fillMask:(CGImageRef)mask withColor:(NSColor *)color
{
	// We want to render the image into our bitmap image rep, so create a
	//	NSGraphicsContext from it.
	NSGraphicsContext *imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:_mainImage];
	CGContextRef cgContext = [imageContext graphicsPort];
	
	// "Focus" our image rep so the NSBitmapImageRep will use it to draw into
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	// Clip out everything that we don't want to fill with the new color
	CGContextClipToMask(cgContext, CGRectMake(0, 0, w, h), mask);
	
	// Set the color and fill
	[fillColor set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, w, h)];
//	[[[NSGradient alloc] initWithStartingColor:frontColor endingColor:backColor] drawInRect:NSMakeRect(0,0,w,h) angle:45];
	
	[NSGraphicsContext restoreGraphicsState];
}


- (NSString *)description
{
	return @"Fill";
}

@end
