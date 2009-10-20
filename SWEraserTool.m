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


#import "SWEraserTool.h"

@implementation SWEraserTool

// Generates the path to be drawn to the image
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	if (!path) {
		path = [NSBezierPath new];
		[path setLineWidth:lineWidth];		
	}
	//if (lineWidth == 1) {
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
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];
		SWLockFocus(mainImage);
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		if (flags & NSAlternateKeyMask) {
			[frontColor setStroke];	
		} else {
			[backColor setStroke];
		}
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
		[NSGraphicsContext restoreGraphicsState];
		savedPoint = point;
		
		SWUnlockFocus(mainImage);
		
		path = nil;
	} else {		
		SWLockFocus(bufferImage);
		
		// The best way I can come up with to clear the image
		[SWImageTools clearImage:bufferImage];
		
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];

		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];
		if (flags & NSAlternateKeyMask) {
			[frontColor setStroke];	
		} else {
			[backColor setStroke];
		}
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
