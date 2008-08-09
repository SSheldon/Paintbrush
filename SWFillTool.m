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


#import "SWFillTool.h"

@interface SWFillTool (Private)

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(CGFloat)tolerance;
- (void) fillMask:(CGImageRef)mask withColor:(NSColor *)color;

@end


@implementation SWFillTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (void)performDrawAtPoint:(NSPoint)point 
			 withMainImage:(NSImage *)anImage 
			   secondImage:(NSImage *)secondImage 
				mouseEvent:(SWMouseEvent)event;
{	
	if (event == MOUSE_DOWN) {

		// Get the width and height of the image
		w = [anImage size].width;
		h = [anImage size].height;
		
		NSUInteger rowBytes = ((NSInteger)(ceil(w)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good
		
		// Create a new NSBitmapImageRep for filling
		// Note: this instantiation is only valid for Leopard - Tiger needs something different
		imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
														   pixelsWide:w
														   pixelsHigh:h 
														bitsPerSample:8 
													  samplesPerPixel:4 
															 hasAlpha:YES 
															 isPlanar:NO 
													   colorSpaceName:NSDeviceRGBColorSpace 
														 bitmapFormat:NSAlphaFirstBitmapFormat 
														  bytesPerRow:rowBytes
														 bitsPerPixel:32];
		
		// Get the graphics context associated with the new ImageRep so we can draw to it
		NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:imageContext];
		
		// Draw the current image to the ImageRep
		[anImage drawAtPoint:NSZeroPoint
					fromRect:NSMakeRect(0, 0, [anImage size].width, [anImage size].height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
		[NSGraphicsContext restoreGraphicsState];

		// Which color are we using?
		fillColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
		
		// Check to make sure if we should even bother trying to fill - 
		// if it's the same color, there's nothing to do
		if (!colorsAreEqual([imageRep colorAtX:point.x y:(h - point.y)], 
							[fillColor colorUsingColorSpaceName:NSDeviceRGBColorSpace])) {			
			// Prep an undo - we're about to change things!
			[NSApp sendAction:@selector(prepUndo:)
						   to:nil
						 from:nil];
			
			// Create the image mask we will be using to fill the selected region
			CGImageRef mask = [self floodFillSelect:NSMakePoint(point.x, point.y+1) tolerance:0.0];
			
			// And then fill it!
			[self fillMask:mask withColor:fillColor];
			
			[anImage lockFocus];
			[imageRep drawAtPoint:NSZeroPoint];
			[anImage unlockFocus];
		}
	}
}	

- (NSCursor *)cursor
{
	NSImage *customImage = [NSImage imageNamed:@"bucket-cursor.png"];
	NSCursor *customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(14,13)];
	return customCursor;
}


	

@end

@implementation SWFillTool (Private)

- (CGImageRef) floodFillSelect:(NSPoint)point tolerance:(CGFloat)tolerance
{
	// Building up a selection mask is pretty involved, so we're going to pass
	//	the task to a helper class that can build up temporary state.
	builder = [[SWSelectionBuilder alloc] initWithBitmapImageRep:imageRep point:point tolerance:tolerance];
	return [builder mask];
}

- (void) fillMask:(CGImageRef)mask withColor:(NSColor *)color
{
	// We want to render the image into our bitmap image rep, so create a
	//	NSGraphicsContext from it.
	NSGraphicsContext *imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	CGContextRef cgContext = [imageContext graphicsPort];
	
	// "Focus" our image rep so the NSImage will use it to draw into
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	// Clip out everything that we don't want to fill with the new color
	//NSLog(@"%f, %f", canvasSize.width, canvasSize.height);
	CGContextClipToMask(cgContext, CGRectMake(0, 0, w, h), mask);
	
	// Set the color and fill
	[fillColor set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, w, h)];
//	[[[NSGradient alloc] initWithStartingColor:frontColor endingColor:backColor] drawInRect:NSMakeRect(0,0,w,h) angle:45];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end