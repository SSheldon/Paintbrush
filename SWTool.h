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


#import <Cocoa/Cocoa.h>

//#define MOUSE_DOWN 0
//#define MOUSE_DRAGGED 1
//#define MOUSE_UP 2

typedef enum { MOUSE_DOWN, MOUSE_DRAGGED, MOUSE_UP } SWMouseEvent;

@interface SWTool : NSObject {
	NSColor *frontColor;
	NSColor *backColor;
	NSImage *drawToMe;
	NSImage *_anImage;
	NSImage *_secondImage;
	NSBezierPath *path;
	CGFloat lineWidth;
	BOOL shouldFill;
	BOOL shouldStroke;
	NSUInteger flags;
	NSPoint savedPoint;
	NSRect redrawRect, savedRect;
}

// Some setters
- (void)setFrontColor:(NSColor *)front;
- (void)setBackColor:(NSColor *)back;
- (void)setLineWidth:(CGFloat)width;
- (void)shouldFill:(BOOL)fill stroke:(BOOL)stroke;


- (NSPoint)savedPoint;
- (NSString *)type;
- (NSColor *)drawingColor;
- (void)setFrontColor:(NSColor *)front backColor:(NSColor *)back lineWidth:(CGFloat)width shouldFill:(BOOL)fill shouldStroke:(BOOL)stroke;
- (void)setModifierFlags:(NSUInteger)modifierFlags;
- (void)setSavedPoint:(NSPoint)aPoint;
- (void)tieUpLooseEnds;
- (void)mouseHasMoved:(NSPoint)aPoint;
- (BOOL)isEqualToTool:(SWTool *)aTool;

// Used for faster drawing: don't redraw the entire screen, just this portion
- (NSRect)setRedrawRectFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2;
- (NSRect)addRectToRedrawRect:(NSRect)newRect;
- (NSRect)invalidRect;
- (void)resetRedrawRect;

- (NSBezierPath *)path;

// A few useful C functions
BOOL colorsAreEqual(NSColor *clicked, NSColor *painting);

@end

@interface SWTool (Abstract)

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end;
- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(SWMouseEvent)event;
- (NSString *)name;
- (NSCursor *)cursor;
- (BOOL)shouldShowFillOptions;

@end
