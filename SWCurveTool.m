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


#import "SWCurveTool.h"
#import "SWDocument.h"

@implementation SWCurveTool

- (id)initWithController:(SWToolboxController *)controller
{
	if (self = [super initWithController:controller])
		numberOfClicks = 0;

	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath bezierPath];
	[path setLineWidth:lineWidth];
	[path moveToPoint:beginPoint];
	if (lineWidth <= 1) 
	{
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	
	// Shift should only affect the line on the first click
	if (numberOfClicks == 1 && (flags & NSShiftKeyMask)) {		
		// x and y are either positive or negative 1
		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
		
		// Theta is the angle formed by the mouse, in degrees (rad * 180/π)
		// atan()'s result is in radians
		CGFloat theta = 180*atan((end.y-begin.y)/(end.x-begin.x)) / pi;
		
		// Deciding whether it should be horizontal, vertical, or at 45º
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		
		// Deciding whether it should be horizontal, vertical, or at 45º
		if (abs(theta) <= 67.5 && abs(theta) >= 22.5) {
			endPoint = NSMakePoint(size*x + beginPoint.x, size*y + beginPoint.y);
		} else if (abs(theta) > 67.5) {
			endPoint = NSMakePoint(0+beginPoint.x, (endPoint.y-beginPoint.y)+beginPoint.y);
		} else {
			endPoint = NSMakePoint((endPoint.x - beginPoint.x)+beginPoint.x, 0+beginPoint.y);
		}
		
		// Gotta keep it from curving too early - we changed endPoint, so we change cp2 on click 1
		cp2 = endPoint;

	}
	[path curveToPoint:endPoint controlPoint1:cp1 controlPoint2:cp2];
	
	return path;
}


- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{	
	if (event == MOUSE_DOWN) {
		numberOfClicks++;
		primaryColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
	}
	
	[SWImageTools clearImage:bufferImage];
	drawToMe = bufferImage;
	
	_bufferImage = bufferImage;
	_mainImage = mainImage;
	
	// Different meaning for different clicks
	switch(numberOfClicks) {
		case 1:
			beginPoint = cp1 = savedPoint;
			endPoint = cp2 = point;
			break;
		case 2:
			cp1 = point;
			//redrawRect = [[self pathFromPoint:savedPoint toPoint:point] bounds];
			break;
		case 3:
			cp2 = point;
			if (event == MOUSE_UP) 
			{
				[document handleUndoWithImageData:nil frame:NSZeroRect];
				drawToMe = mainImage;
				numberOfClicks = 0;
			}
			break;
		default:
			break;
	}
	
	SWLockFocus(drawToMe);
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[primaryColor setStroke];
	NSBezierPath *p = [self pathFromPoint:savedPoint toPoint:point];
	[p stroke];
	
	SWUnlockFocus(drawToMe);
	
	// Use the points clicked to build a redraw rectangle
	NSRect curveRect = [p bounds];
	curveRect.origin.x -= lineWidth;
	curveRect.origin.y -= lineWidth;
	curveRect.size.width += 2*lineWidth;
	curveRect.size.height += 2*lineWidth;
	[super addRectToRedrawRect:curveRect];
	return nil;
}

- (void)setNumberOfClicks:(NSInteger)clicks
{
	numberOfClicks = clicks;
}

- (NSInteger)numberOfClicks
{
	return numberOfClicks;
}

- (void)tieUpLooseEnds
{
	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_bufferImage && _mainImage && numberOfClicks > 0) 
	{
		numberOfClicks = 0;
		[document handleUndoWithImageData:nil frame:NSZeroRect];
		[SWImageTools drawToImage:_mainImage fromImage:_bufferImage withComposition:YES];
	}
	
	[super tieUpLooseEnds];
}

- (NSCursor *)cursor
{
	if (!customCursor)
		customCursor = [[NSCursor crosshairCursor] retain];

	return customCursor;
}

- (NSString *)description
{
	return @"Curve";
}

@end
