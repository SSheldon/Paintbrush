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


#import "SWTool.h"
#import "SWToolboxController.h"

@implementation SWTool

@synthesize flags;
@synthesize document;

- (id)initWithController:(SWToolboxController *)controller
{
	if(self = [super init]) 
	{
		[self resetRedrawRect];
		toolboxController = controller;
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
	DebugLog(@"%@ tool is tying up loose ends", [self class]);
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

- (void)dealloc
{
	[customCursor release];
	[document release];
	[toolboxController removeObserver:self forKeyPath:@"lineWidth"];
	[toolboxController removeObserver:self forKeyPath:@"foregroundColor"];
	[toolboxController removeObserver:self forKeyPath:@"backgroundColor"];
	[toolboxController removeObserver:self forKeyPath:@"fillStyle"];
	[super dealloc];
}


@end
