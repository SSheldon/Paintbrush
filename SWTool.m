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


#import "SWTool.h"
#import "SWToolboxController.h"

@implementation SWTool

@synthesize flags;

- (id)initWithController:(SWToolboxController *)controller
{
	if(self = [super init]) {
		[self resetRedrawRect];
		toolbox = controller;
		[controller addObserver:self 
					 forKeyPath:@"lineWidth" 
						options:NSKeyValueObservingOptionNew 
						context:NULL];
		[controller addObserver:self 
					 forKeyPath:@"foregroundColor" 
						options:NSKeyValueObservingOptionNew 
						context:NULL];
		[controller addObserver:self 
					 forKeyPath:@"backgroundColor" 
						options:NSKeyValueObservingOptionNew 
						context:NULL];
		[controller addObserver:self 
					 forKeyPath:@"fillStyle" 
						options:NSKeyValueObservingOptionNew 
						context:NULL];
	}
	return self;
}

// Returns a copy of this object
//- (id)copyWithZone:(NSZone *)zone
//{
//    SWTool *copy = [[[self class] allocWithZone: zone] initWithController:toolbox];
//	
//    return copy;
//}

// The tools will observe several values set by the toolbox
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	id thing = [change objectForKey:NSKeyValueChangeNewKey];
	
	if ([keyPath isEqualToString:@"lineWidth"]) {
		[self setLineWidth:[thing integerValue]];
	} else if ([keyPath isEqualToString:@"foregroundColor"]) {
		[self setFrontColor:thing];
	} else if ([keyPath isEqualToString:@"backgroundColor"]) {
		[self setBackColor:thing];
	} else if ([keyPath isEqualToString:@"fillStyle"]) {
		SWFillStyle fillStyle = [thing integerValue];
		[self setShouldFill:(fillStyle == FILL_ONLY || fillStyle == FILL_AND_STROKE) 
					 stroke:(fillStyle == STROKE_ONLY || fillStyle == FILL_AND_STROKE)];
	}
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

- (void)setShouldFill:(BOOL)fill stroke:(BOOL)stroke
{
	shouldFill = fill;
	shouldStroke = stroke;
}

//- (void)setFrontColor:(NSColor *)front 
//			backColor:(NSColor *)back 
//			lineWidth:(CGFloat)width 
//		   shouldFill:(BOOL)fill 
//		 shouldStroke:(BOOL)stroke
//{
//	frontColor = front;
//	backColor = back;
//	lineWidth = width;
//	shouldFill = fill;
//	shouldStroke = stroke;
//}

- (NSPoint)savedPoint
{
	return savedPoint;
}

- (void)setSavedPoint:(NSPoint)aPoint
{
	savedPoint = aPoint;
}

- (void)deleteKey
{
	// ?
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

// By default, no contextual menu
- (BOOL)shouldShowContextualMenu
{
	return NO;
}

// Used to make the drawing faster
- (NSRect)addRedrawRectFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2
{
	NSRect tempRect;
	tempRect.origin = NSMakePoint(round(fmin(p1.x, p2.x) - (lineWidth/2) - 1), round(fmin(p1.y, p2.y) - (lineWidth/2) - 1));
	tempRect.size = NSMakeSize((abs(p1.x - p2.x) + lineWidth + 2), (abs(p1.y - p2.y) + lineWidth + 2));
	return [self addRectToRedrawRect:tempRect];
}

- (NSRect)addRectToRedrawRect:(NSRect)newRect
{
	// The redraw region should include both the current rectangle and
	// the last action's rectangle
	redrawRect = NSUnionRect(newRect, savedRect);
	
	// Save the current new rectangle for next time
	savedRect = newRect;
	
	// Just to be save, outsed the right of the rectangle by an extra pixel
	// Hack to fix bug with some fonts and the text tool
	redrawRect.size.width += 1.0;
	
	return redrawRect;
}

- (NSRect)invalidRect
{
	return redrawRect;
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

- (BOOL)shouldShowTransparencyOptions
{
	return NO;
}

- (NSString *)emptyString
{
	return @"";
}

BOOL colorsAreEqual(NSColor *clicked, NSColor *painting)
{
	CGFloat r1, r2, g1, g2, b1, b2, a1, a2;
	[clicked getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[painting getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	r1 = roundf(255*r1);
	r2 = roundf(255*r2);
	g1 = roundf(255*g1);
	g2 = roundf(255*g2);
	b1 = roundf(255*b1);
	b2 = roundf(255*b2);
	//NSLog(@"%d = %d, %d = %d, %d = %d", r1, r2, g1, g2, b1, b2);
	return (r1==r2) && (g1==g2) && (b1==b2);
}

@end
