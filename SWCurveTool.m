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


#import "SWCurveTool.h"

@implementation SWCurveTool

- (id)initWithController:(SWToolboxController *)controller
{
	if (self = [super initWithController:controller]) {
		numberOfClicks = 0;
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path moveToPoint:beginPoint];
	if (lineWidth == 1) {
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
					   withMainImage:(NSImage *)anImage 
						 secondImage:(NSImage *)secondImage 
						  mouseEvent:(SWMouseEvent)event
{	
	if (event == MOUSE_DOWN) {
		numberOfClicks++;
		primaryColor = (flags & NSAlternateKeyMask) ? backColor : frontColor;
	}
	
	SWClearImage(secondImage);
	drawToMe = secondImage;
	
	_secondImage = secondImage;
	_anImage = anImage;
	
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
			if (event == MOUSE_UP) {
				[NSApp sendAction:@selector(prepUndo:)
							   to:nil
							 from:nil];				
				drawToMe = anImage;
				numberOfClicks = 0;
			}
			break;
		default:
			break;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	[primaryColor setStroke];
	NSBezierPath *p = [self pathFromPoint:savedPoint toPoint:point];
	[p stroke];
	
	[drawToMe unlockFocus];
	
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
	[super tieUpLooseEnds];
	
	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_secondImage && _anImage && numberOfClicks > 0) {
		
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];	
		
		[_anImage lockFocus];
		[_secondImage drawAtPoint:NSZeroPoint
						 fromRect:NSZeroRect
						operation:NSCompositeSourceOver
						 fraction:1.0];
		[_anImage unlockFocus];
	}
	
	numberOfClicks = 0;
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (NSString *)description
{
	return @"Curve";
}

@end
