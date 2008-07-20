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
#import "SWToolList.h"
#import "SWToolboxController.h"

@interface SWPaintView : NSView {
	NSImage *mainImage;
	NSImage *secondImage;
	NSPoint downPoint;
	NSPoint currentPoint;
	NSColor *frontColor;
	NSColor *backColor;
	NSBitmapImageRep *imageRep;
	NSData *undoData;
	SWToolboxController *toolbox;
	SWTool *currentTool;

	BOOL isPayingAttention;
	BOOL hasRun;
	
	// Grid related
	BOOL showsGrid;
	CGFloat gridSpacing;
	NSColor *gridColor;
}

//- (id)initWithFrame:(NSRect)frameRect animate:(BOOL)shouldAnimate;
- (NSRect)calculateWindowBounds:(NSRect)frameRect;
- (void)setImage:(NSImage *)newImage scale:(BOOL)scale;
- (void)setCurrentTool:(SWTool *)newTool;
- (void)undoImage:(NSData *)imageData;
- (void)undoResize:(NSData *)mainImageData oldSize:(NSSize)size;
- (void)pasteData:(NSData *)data;
- (void)prepUndo:(id)sender;
- (void)clearOverlay;
- (BOOL)hasRun;
- (NSImage *)mainImage;
- (NSImage *)secondImage;


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