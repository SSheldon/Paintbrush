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


#import "SWFillTool.h"
#import "SWSelectionBuilder.h"
#import "SWDocument.h"


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
	if (event == MOUSE_DOWN) 
	{

		// Get the width and height of the image
		w = [mainImage size].width;
		h = [mainImage size].height;
		
		_mainImage = mainImage;
		
		// Which color are we using?
		fillColor = [(flags & NSAlternateKeyMask) ? backColor : frontColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		
		// Check to make sure if we should even bother trying to fill - 
		// if it's the same color, there's nothing to do
		if (![SWImageTools color:[mainImage colorAtX:point.x y:(h - point.y)] 
				  isEqualToColor:fillColor]) 
		{
			// Prep an undo - we're about to change things!
			[document handleUndoWithImageData:nil frame:NSZeroRect];
			
			// Create the image mask we will be using to fill the selecteds region
			CGImageRef mask = [self floodFillSelect:NSMakePoint(point.x, point.y+1) tolerance:0.0];
			
			// And then fill it!
			[self fillMask:mask withColor:fillColor];
			
			// And then release it!
			CGImageRelease(mask);
			
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
	
	// For filling with transparent colors
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];		

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
