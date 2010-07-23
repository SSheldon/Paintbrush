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


#import <Cocoa/Cocoa.h>

@class SWToolboxController;
@class SWDocument;

typedef enum 
{
	MOUSE_DOWN, 
	MOUSE_DRAGGED,
	MOUSE_UP,
	MOUSE_MOVED
} SWMouseEvent;

@interface SWTool : NSObject
{
	NSColor *frontColor;
	NSColor *backColor;
	NSBitmapImageRep *drawToMe;
	NSBitmapImageRep *_mainImage;
	NSBitmapImageRep *_bufferImage;
	NSBezierPath *path;
	CGFloat lineWidth;
	BOOL shouldFill;
	BOOL shouldStroke;
	BOOL shouldShowFillOptions;
	BOOL shouldShowTransparencyOptions;
	NSUInteger flags;
	NSPoint savedPoint;
	NSRect redrawRect, savedRect;
	SWToolboxController *toolboxController;
	
	NSCursor *customCursor;
	
	// We need to talk to the document once in a while
	SWDocument *document;
}

- (id)initWithController:(SWToolboxController *)controller;
//- (id)copyWithZone:(NSZone *)zone;

// Some setters
- (void)setFrontColor:(NSColor *)front;
- (void)setBackColor:(NSColor *)back;
- (void)setLineWidth:(CGFloat)width;
- (void)setShouldFill:(BOOL)fill stroke:(BOOL)stroke;


- (NSPoint)savedPoint;
- (NSColor *)drawingColor;
- (void)setSavedPoint:(NSPoint)aPoint;
- (void)tieUpLooseEnds;
- (void)mouseHasMoved:(NSPoint)aPoint;
- (BOOL)isEqualToTool:(SWTool *)aTool;
- (void)deleteKey;

// Used for faster drawing: don't redraw the entire screen, just this portion
- (NSRect)addRedrawRectFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2;
- (NSRect)addRectToRedrawRect:(NSRect)newRect;
- (NSRect)invalidRect;
- (void)resetRedrawRect;
- (BOOL)shouldShowContextualMenu;
//- (BOOL)shouldShowFillOptions;
//- (BOOL)shouldShowTransparencyOptions;
- (NSBezierPath *)path;

@property (readonly) BOOL shouldShowFillOptions;
@property (readonly) BOOL shouldShowTransparencyOptions;
@property (assign) NSUInteger flags;
@property (retain, readwrite) SWDocument * document;

@end


// Abstract category on SWTool -- the base class doesn't implement these methods at all
@interface SWTool (Abstract)
- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end;
- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event;
- (NSCursor *)cursor;

@end
