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


#import "SWEllipseTool.h"
#import "SWDocument.h"

@implementation SWEllipseTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path moveToPoint:begin];
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		NSInteger x = (end.x-begin.x) / abs(end.x-begin.x);
		NSInteger y = (end.y-begin.y) / abs(end.y-begin.y);
		[path appendBezierPathWithOvalInRect:NSMakeRect(begin.x, begin.y, x*size, y*size)];
	} else {
		[path appendBezierPathWithOvalInRect:NSMakeRect(begin.x, begin.y, (end.x - begin.x), (end.y - begin.y))];
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
	
	SWLockFocus(drawToMe); 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	// Which colors should we draw with?
	if (event == MOUSE_DOWN) {
		if (flags & NSAlternateKeyMask) {
			primaryColor = backColor;
			secondaryColor = frontColor;
		} else {
			primaryColor = frontColor;
			secondaryColor = backColor;
		}
	}
	
	if (shouldFill && shouldStroke) {
		[primaryColor setStroke];
		[secondaryColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	} else if (shouldFill) {
		[primaryColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
	} else if (shouldStroke) {
		[primaryColor setStroke];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	}

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

- (BOOL)shouldShowFillOptions
{
	return YES;
}

- (NSString *)description
{
	return @"Ellipse";
}

@end
