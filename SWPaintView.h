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


#import <Cocoa/Cocoa.h>

@class SWToolboxController;
@class SWToolbox;
@class SWTool;

@interface SWPaintView : NSView {
	NSBitmapImageRep *mainImage;
	NSBitmapImageRep *bufferImage;
	NSPoint currentPoint;
	NSColor *frontColor;
	NSColor *backColor;
	NSData *undoData;
	NSBezierPath *expPath;
	SWToolboxController *toolboxController;
	SWToolbox *toolbox;
	SWTool *currentTool;

	BOOL isPayingAttention;
	
	NSColor *backgroundColor;
	
	// Grid related
	BOOL showsGrid;
	CGFloat gridSpacing;
	NSColor *gridColor;
}

//- (id)initWithFrame:(NSRect)frameRect animate:(BOOL)shouldAnimate;
- (void)preparePaintView;
- (NSRect)calculateWindowBounds:(NSRect)frameRect;
- (void)setToolbox:(SWToolbox *)tb;
- (void)setImage:(NSBitmapImageRep *)newImage scale:(BOOL)scale;
- (void)setCurrentTool:(SWTool *)newTool;
- (void)setBackgroundColor:(NSColor *)color;
//- (void)undoImage:(NSData *)imageData;
- (void)undoResize:(NSData *)mainImageData oldFrame:(NSRect)frame;
- (void)pasteData:(NSData *)data;
- (void)prepUndo:(id)sender;
- (void)clearOverlay;
- (NSBitmapImageRep *)mainImage;
- (NSBitmapImageRep *)bufferImage;


// Grid related
//- (IBAction)showGrid:(id)sender;
- (void)setShowsGrid:(BOOL)shouldShowGrid;
- (void)setGridSpacing:(CGFloat)spacing;
- (void)setGridColor:(NSColor *)color;
- (BOOL)showsGrid;
- (CGFloat)gridSpacing;
- (NSColor *)gridColor;
- (NSBezierPath *)gridInRect:(NSRect)rect;

@end

//void DrawGridWithSettingsInRect(CGFloat spacing, NSColor *color, NSRect rect, NSPoint gridOrigin);