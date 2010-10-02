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


#import "SWEraserTool.h"
#import "SWDocument.h"

@implementation SWEraserTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (!path)
	{
		path = [[NSBezierPath bezierPath] retain];
		[path setLineWidth:lineWidth];		
	}
	//if (lineWidth <= 1) 
	//{
	// Off-by-half: Cocoa drawing is done based on gridlines AROUND pixels.  
	// We want to actually fill the pixels themselves!
	begin.x += 0.5;
	begin.y += 0.5;
	end.x += 0.5;
	end.y += 0.5;
	//}
	[path moveToPoint:begin];
	[path lineToPoint:end];
	
	return path;
}


- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	// Use the points clicked to build a redraw rectangle
	[super addRedrawRectFromPoint:point toPoint:savedPoint];
	
	if (event == MOUSE_UP) 
	{
		[document handleUndoWithImageData:nil frame:NSZeroRect];
		[SWImageTools drawToImage:mainImage fromImage:bufferImage withComposition:YES];
		[SWImageTools clearImage:bufferImage];

		[path release];
		path = nil;
	} 
	else 
	{		
		SWLockFocus(bufferImage);
		
		// The best way I can come up with to clear the image
		[SWImageTools clearImage:bufferImage];
		
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		if (flags & NSAlternateKeyMask)
			[frontColor setStroke];
		else
			[backColor setStroke];	
		
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		[NSGraphicsContext restoreGraphicsState];
		savedPoint = point;
		
		SWUnlockFocus(bufferImage);
	}
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"eraser-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(2,13)];
	}
	return customCursor;
}

- (NSColor *)drawingColor
{
	return backColor;
}

- (NSString *)description
{
	return @"Eraser";
}

@end
