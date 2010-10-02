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


#import "SWLineTool.h"
#import "SWDocument.h"

@implementation SWLineTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath bezierPath];
	[path setLineWidth:lineWidth];
	[path moveToPoint:begin];
	if (lineWidth <= 1) 
	{
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		// x and y are either positive or negative 1
		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/¹)
		// atan()'s result is in radians
		CGFloat theta = 180*atan((end.y-begin.y)/(end.x-begin.x)) / pi;
		
		// Deciding whether it should be horizontal, vertical, or at 45¼
		NSPoint newPoint = NSZeroPoint;
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			// ¹/4
			newPoint = NSMakePoint(size*x, size*y);
		} else if (abs(theta) > 67.5) {
			// ¹/2
			newPoint = NSMakePoint(0, (end.y-begin.y));
		} else {
			// 0
			newPoint = NSMakePoint((end.x - begin.x), 0);
		}
		
		[path relativeLineToPoint:newPoint];
	} else {
		[path lineToPoint:end];
	}
	
	return path;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	// Use the points clicked to build a redraw rectangle
	[super addRedrawRectFromPoint:savedPoint toPoint:point];

	[SWImageTools clearImage:bufferImage];
	
	if (event == MOUSE_UP) 
	{
		[document handleUndoWithImageData:nil frame:NSZeroRect];
		drawToMe = mainImage;
	}
	else
		drawToMe = bufferImage;
	
	// Which color do we use?
	if (event == MOUSE_DOWN)
		primaryColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
	
	SWLockFocus(drawToMe); 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[primaryColor setStroke];
	[[self pathFromPoint:savedPoint toPoint:point] stroke];
	
	SWUnlockFocus(drawToMe);
	return nil;
	
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		customCursor = [[NSCursor crosshairCursor] retain];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Line";
}

@end
