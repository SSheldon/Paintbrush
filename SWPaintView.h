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
@class SWToolbox;
@class SWTool;
@class SWDocument;
@class SWImageDataSource;

@interface SWPaintView : NSView 
{
	// Have a connection to the SWDocument instance that owns this view
	IBOutlet SWDocument *document;
	
	// The data source: light of our life
	SWImageDataSource *dataSource;
	
	NSPoint currentPoint;
	NSColor *frontColor;
	NSColor *backColor;
	NSData *undoData;
	NSBezierPath *expPath;
	SWToolboxController *toolboxController;
	SWToolbox *toolbox;

	BOOL isPayingAttention;
	
	NSColor *backgroundColor;
	
	// Grid related
	BOOL showsGrid;
	CGFloat gridSpacing;
	NSColor *gridColor;
}

- (void)preparePaintViewWithDataSource:(SWImageDataSource *)ds
							   toolbox:(SWToolbox *)tb;
- (NSRect)calculateWindowBounds:(NSRect)frameRect;
- (void)setBackgroundColor:(NSColor *)color;
- (void)clearOverlay;

// Getting info
//- (NSPoint)currentMouseLocation;

// Grid related
- (void)setShowsGrid:(BOOL)shouldShowGrid;
- (void)setGridSpacing:(CGFloat)spacing;
- (void)setGridColor:(NSColor *)color;
- (BOOL)showsGrid;
- (CGFloat)gridSpacing;
- (NSColor *)gridColor;
- (NSBezierPath *)gridInRect:(NSRect)rect;

@end

//void DrawGridWithSettingsInRect(CGFloat spacing, NSColor *color, NSRect rect, NSPoint gridOrigin);