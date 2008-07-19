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


#import "SWTool.h"

@implementation SWTool

- (id)init
{
	if(self = [super init]) {
//		path = [[NSBezierPath alloc] init];
//		[path setLineCapStyle:NSRoundLineCapStyle];
		[self resetRedrawRect];
	}
	return self;
}

- (void)resetRedrawRect
{
	redrawRect = savedRect = NSMakeRect(CGFLOAT_MAX, CGFLOAT_MAX, 0.0, 0.0);
}

- (NSColor *)drawingColor
{
	return frontColor;
}


- (CGFloat)lineWidth
{
	return lineWidth;
}

- (void)setFrontColor:(NSColor *)front
{
	frontColor = front;
}

- (void)setBackColor:(NSColor *)back
{
	backColor = back;
}

- (void)setLineWidth:(CGFloat)width
{
	lineWidth = width;
}

- (void)shouldFill:(BOOL)fill stroke:(BOOL)stroke
{
	shouldFill = fill;
	shouldStroke = stroke;
}

- (void)setFrontColor:(NSColor *)front 
			backColor:(NSColor *)back 
			lineWidth:(CGFloat)width 
		   shouldFill:(BOOL)fill 
		 shouldStroke:(BOOL)stroke
{
	frontColor = front;
	backColor = back;
	lineWidth = width;
	shouldFill = fill;
	shouldStroke = stroke;
}

- (NSPoint)savedPoint
{
	return savedPoint;
}

- (void)setSavedPoint:(NSPoint)aPoint
{
	savedPoint = aPoint;
}

- (void)setModifierFlags:(NSUInteger)modifierFlags
{
	flags = modifierFlags;
}

- (void)tieUpLooseEnds
{
	// Must be overridden if you want something more interesting to happen
	//NSLog(@"%@ tool is tying up loose ends", [self name]);
}

- (BOOL)isEqualToTool:(SWTool *)aTool
{
	return ([[self class] isEqualTo:[aTool class]]);
}

- (void)mouseHasMoved:(NSPoint)aPoint
{
	// Does nothing! It's up to the subclasses to implement this one
}

- (NSBezierPath *)path
{
	return path;
}

// Used to make the drawing faster
// TODO: deprecate this method
//- (NSRect)setRedrawRectFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2
//{
//	NSRect tempRect = NSZeroRect;
//	tempRect.origin = NSMakePoint((fmin(p1.x, p2.x) - (lineWidth/2) - 1), (fmin(p1.y, p2.y) - (lineWidth/2) - 1));
//	tempRect.size = NSMakeSize((abs(p1.x - p2.x) + lineWidth + 2), (abs(p1.y - p2.y) + lineWidth + 2));
//	//redrawRect = tempRect;
//	if (tempRect.origin.x != savedRect.origin.x || tempRect.origin.y != savedRect.origin.y) {
//		redrawRect = NSMakeRect(fmin(tempRect.origin.x, savedRect.origin.x), fmin(tempRect.origin.y, savedRect.origin.y), 
//								(tempRect.size.width + savedRect.size.width), (tempRect.size.height + savedRect.size.height));
//	} else {
//		redrawRect = NSMakeRect(fmin(tempRect.origin.x, savedRect.origin.x), fmin(tempRect.origin.y, savedRect.origin.y), 
//								fmax(tempRect.size.width, savedRect.size.width), fmax(tempRect.size.height, savedRect.size.height));
//	}
//
//	savedRect = tempRect;
//
//	return redrawRect;
//}

- (NSRect)setRedrawRectFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2
{
	NSRect tempRect;
	tempRect.origin = NSMakePoint((fmin(p1.x, p2.x) - (lineWidth/2) - 1), (fmin(p1.y, p2.y) - (lineWidth/2) - 1));
	tempRect.size = NSMakeSize((abs(p1.x - p2.x) + lineWidth + 2), (abs(p1.y - p2.y) + lineWidth + 2));
	return [self addRectToRedrawRect:tempRect];
}

// TODO: Finish implementing this method - it will replace the older setRedrawRectFromPoint:toPoint:
- (NSRect)addRectToRedrawRect:(NSRect)newRect
{
	// Here's some funky math to make it work... don't question the algorithm!
	//NSRect sumRect;
	//sumRect.origin.x = fmin(newRect.origin.x, savedRect.origin.x);
	//sumRect.origin.y = fmin(newRect.origin.y, savedRect.origin.y);
	//sumRect.size.width = fmax(NSMaxX(newRect), NSMaxX(savedRect)) - sumRect.origin.x;
	//sumRect.size.height = fmax(NSMaxY(newRect), NSMaxY(savedRect)) - sumRect.origin.y;
	
	redrawRect = NSUnionRect(newRect, savedRect);
	
	//NSLog(@"%@", [NSValue valueWithRect:newRect]);
	
	// Save the current new rectangle
	savedRect = newRect;
	
	return redrawRect;
}

- (NSRect)invalidRect
{
	//NSLog(@"%lf, %lf, %lf, %lf", 0, 0, [_anImage size].width, [_anImage size].height);
	return redrawRect;
}


BOOL colorsAreEqual(NSColor *clicked, NSColor *painting)
{
	NSInteger r1, r2, g1, g2, b1, b2;
	
	r1 = roundf(255*[clicked redComponent]);
	r2 = roundf(255*[painting redComponent]);
	g1 = roundf(255*[clicked greenComponent]);
	g2 = roundf(255*[painting greenComponent]);
	b1 = roundf(255*[clicked blueComponent]);
	b2 = roundf(255*[painting blueComponent]);
	//NSLog(@"%d = %d, %d = %d, %d = %d", r1, r2, g1, g2, b1, b2);
	return (r1==r2) && (g1==g2) && (b1==b2);
}

@end
