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


#import "SWPaintView.h"
#import "SWCenteringClipView.h"
#import "SWScalingScrollView.h"
#import "SWToolList.h"
#import "SWToolbox.h"
#import "SWToolboxController.h"
#import "SWAppController.h"

@implementation SWPaintView

- (void)preparePaintView
{
	NSRect frameRect = [self frame];
	
	toolboxController = [SWToolboxController sharedToolboxPanelController];
	isPayingAttention = YES;

	// Create the two images we'll be using
	[SWImageTools initImageRep:&mainImage withSize:frameRect.size];
	[SWImageTools initImageRep:&bufferImage withSize:frameRect.size];

	
	// New document, not an opened image: gotta paint the background color
//	[NSGraphicsContext saveGraphicsState];
//	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:mainImage]];
	SWLockFocus(mainImage);
	[[toolboxController backgroundColor] setFill];
	NSRectFill(frameRect);
	SWUnlockFocus(mainImage);
//	[NSGraphicsContext restoreGraphicsState];
	
	[SWImageTools drawToImage:bufferImage fromImage:mainImage withComposition:NO];
	
	// Tracking area
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self frame]
														options: NSTrackingMouseMoved | NSTrackingCursorUpdate
							| NSTrackingEnabledDuringMouseDrag | NSTrackingActiveWhenFirstResponder
														  owner:self
													   userInfo:nil] autorelease]];
	[[self window] setAcceptsMouseMovedEvents:YES];
		
	// Grid related
	showsGrid = NO;
	gridSpacing = 1;
	gridColor = [NSColor gridColor];
	
	[self setNeedsDisplay:YES];	
}


- (NSRect)calculateWindowBounds:(NSRect)frameRect {
	// Set the window's maximum size to the size of the screen
	// Does not seem to work all the time
	NSRect screenRect = [[NSScreen mainScreen] frame];
	
	// Center the shrunken/enlarged window with respect to its initial location
	NSRect tempRect = [[super window] frameRectForContentRect:frameRect];
	NSPoint newOrigin = [[super window] frame].origin;
	
	tempRect.size.width += [NSScroller scrollerWidth];
	tempRect.size.height += [NSScroller scrollerWidth];
	
	newOrigin.y += floor(0.5 * ([[super window] frame].size.height - tempRect.size.height));
	newOrigin.x += floor(0.5 * ([[super window] frame].size.width - tempRect.size.width));
	tempRect.origin = newOrigin;
	
	// Ensures that the document is never wider than the screen
	tempRect.size.width = MIN(screenRect.size.width, tempRect.size.width);
	
	// Assert some minimum and maximum values!
	tempRect.size.width = MAX([[super window] minSize].width, tempRect.size.width);
	tempRect.size.height = MAX([[super window] minSize].height, tempRect.size.height);
	
	tempRect.origin.x = MAX(tempRect.origin.x, 0);
	
	return tempRect;
}


- (void)drawRect:(NSRect)rect
{
	if (rect.size.width != 0 && rect.size.height != 0) {
		
		//NSRect drawRect = NSMakeRect(round(rect.origin.x), round(rect.origin.y), round(rect.size.width), round(rect.size.height));
		[NSGraphicsContext saveGraphicsState];

		// If you don't do this, the image looks blurry when zoomed in
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
//		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
		
		// Fill the background, but maintain transparency of mainImage
		//[[toolbox backgroundColor] set];
		//[NSBezierPath fillRect:[self bounds]];
		
//		if (backgroundColor) {
//			[backgroundColor setFill];
//			NSRectFillUsingOperation(rect, NSCompositeSourceOver);
//			//NSRectFill(rect);
//		}		
		
		// Draw the pattern first
//		if (bgImagePattern) {
//			NSColor *bgImageColor = [[NSColor colorWithPatternImage:bgImagePattern] retain];
//			[bgImageColor setFill];
//			NSBitmapImageRep *rep;
//			[SWImageTools initImageRep:&rep withSize:[self frame].size];
//			[SWImageTools clearImage:rep];
//			if ([rep size].width != 0 && [rep size].height != 0) {
//				SWLockFocus(mainImage);
//				CGContextDrawTiledImage([[NSGraphicsContext currentContext] graphicsPort], CGRectMake(0, 0, [bgImagePattern size].width, [bgImagePattern size].height), [[NSBitmapImageRep imageRepWithData:[bgImagePattern TIFFRepresentation]] CGImage]);
//				SWUnlockFocus(mainImage);
//			}
////			CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], 
////							   NSRectToCGRect([self bounds]), [rep CGImage]);
//
//		}
		
		// Draw the NSBitmapImageRep to the view
		if (mainImage) {
			//[mainImage draw];
			CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], 
							   NSRectToCGRect([self bounds]), [mainImage CGImage]);
		}
		
		// If there's an overlay image being used at the moment, draw it
		if (bufferImage) {
			//[bufferImage drawAtPoint:NSZeroPoint];
			CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], 
							   NSRectToCGRect([self bounds]), [bufferImage CGImage]);
		}
		
		// If the grid is turned on, draw that too
		if (showsGrid && [(SWScalingScrollView *)[[self superview] superview] scaleFactor] > 2.0) {
			[gridColor set];
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[self gridInRect:[self frame]] stroke];
		}
		
//		if (expPath) {
//			[[NSColor blueColor] set];
//			[expPath stroke];
//		}
		
		[NSGraphicsContext restoreGraphicsState];
	}
}


//- (NSMenu *)menuForEvent:(NSEvent *)theEvent
//{
//	NSLog(@"Wow!");
//	NSLog(@"%d", [theEvent type]);
//	return [SWPaintView defaultMenu];
//}

+ (NSMenu *)defaultMenu {
	//NSMenu *theMenu = [super initWithWindowNibName:@"Preferences"];
    NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Contextual Menu"] autorelease];
    [theMenu insertItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"" atIndex:1];
    [theMenu insertItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"" atIndex:2];
	[theMenu insertItem:[NSMenuItem separatorItem] atIndex:3];
    [theMenu insertItemWithTitle:@"Zoom In" action:@selector(zoomIn:) keyEquivalent:@"" atIndex:4];
    [theMenu insertItemWithTitle:@"Zoom Out" action:@selector(zoomOut:) keyEquivalent:@"" atIndex:5];
    [theMenu insertItemWithTitle:@"Actual Size" action:@selector(actualSize:) keyEquivalent:@"" atIndex:6];
    return theMenu;
}


// Used to assign the toolbox
- (void)setToolbox:(SWToolbox *)tb
{
	[tb retain];
	[toolbox release];
	toolbox = tb;
	
	// Update the cursor
	[self cursorUpdate:nil];
}


- (void)updateCurrentTool {
	//[currentTool resetRedrawRect];
	//NSLog(@"Toolbox is %@", toolbox);
	//NSLog(@"%@ versus %@", currentTool, [toolbox currentTool]);
	if (currentTool != [toolbox currentTool]) {
		currentTool = [toolbox currentTool];
		[self clearOverlay];
	}
}

#pragma mark Mouse/keyboard events: the cornerstone of the drawing process

////////////////////////////////////////////////////////////////////////////////
//////////		Mouse/keyboard events: the cornerstone of the drawing process
////////////////////////////////////////////////////////////////////////////////


- (void)mouseDown:(NSEvent *)event
{
//	NSLog(@"Down, control = %d", ([event modifierFlags] & NSControlKeyMask));
//	if (!([event modifierFlags] & NSControlKeyMask)) {
		isPayingAttention = YES;
		NSPoint p = [event locationInWindow];
		NSPoint downPoint = [self convertPoint:p fromView:nil];
		
		// Necessary for when the view is zoomed above 100%
		currentPoint.x = floor(downPoint.x);
		currentPoint.y = floor(downPoint.y);
		
		[self updateCurrentTool];

		[currentTool setSavedPoint:currentPoint];
		
		// If it's shifted, do something about it
		[currentTool setFlags:[event modifierFlags]];
		[currentTool performDrawAtPoint:currentPoint 
						  withMainImage:mainImage 
							bufferImage:bufferImage 
							 mouseEvent:MOUSE_DOWN];
		
		[self setNeedsDisplayInRect:[currentTool invalidRect]];
		//[self setNeedsDisplay:YES];		
//	}
}

- (void)mouseDragged:(NSEvent *)event
{
//	NSLog(@"Dragged, control = %d", ([event modifierFlags] & NSControlKeyMask));
	if (isPayingAttention) {
		NSPoint p = [event locationInWindow];
		NSPoint dragPoint = [self convertPoint:p fromView:nil];
		
		// Necessary for when the view is zoomed above 100%
		currentPoint.x = floor(dragPoint.x);
		currentPoint.y = floor(dragPoint.y);
		
		[currentTool setFlags:[event modifierFlags]];
		[currentTool performDrawAtPoint:currentPoint 
						  withMainImage:mainImage 
							bufferImage:bufferImage 
							 mouseEvent:MOUSE_DRAGGED];
		
		[self setNeedsDisplayInRect:[currentTool invalidRect]];
	}
}

- (void)mouseUp:(NSEvent *)event
{
//	NSLog(@"Up, control = %d", ([currentTool flags] & NSControlKeyMask));
	if (isPayingAttention) {
		NSPoint p = [event locationInWindow];
		NSPoint upPoint = [self convertPoint:p fromView:nil];
		
		// Necessary for when the view is zoomed above 100%
		currentPoint.x = floor(upPoint.x);
		currentPoint.y = floor(upPoint.y);
		[currentTool setFlags:[event modifierFlags]];
		NSBezierPath *path = [currentTool performDrawAtPoint:currentPoint 
											   withMainImage:mainImage 
												 bufferImage:bufferImage 
												  mouseEvent:MOUSE_UP];
		
		if (path) {
			expPath = path;
		}
		
		[self setNeedsDisplayInRect:[currentTool invalidRect]];
		//[self setNeedsDisplay:YES];
	}
}

// We want right-clicks to result in the use of the background color
- (void)rightMouseDown:(NSEvent *)theEvent
{
	[self updateCurrentTool];
	NSUInteger flags = [theEvent modifierFlags] | ([currentTool shouldShowContextualMenu] ? NSControlKeyMask : NSAlternateKeyMask);
	
	NSEvent *modifiedEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
												location:[theEvent locationInWindow] 
										   modifierFlags:flags
											   timestamp:[theEvent timestamp]
											windowNumber:[theEvent windowNumber]
												 context:[theEvent context]
											 eventNumber:[theEvent eventNumber]
											  clickCount:[theEvent clickCount]
												pressure:[theEvent pressure]];
	[NSApp postEvent:modifiedEvent atStart:YES];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	NSUInteger flags = [theEvent modifierFlags] | ([currentTool shouldShowContextualMenu] ? NSControlKeyMask : NSAlternateKeyMask);
	
	NSEvent *modifiedEvent = [NSEvent mouseEventWithType:NSLeftMouseDragged
												location:[theEvent locationInWindow] 
										   modifierFlags:flags
											   timestamp:[theEvent timestamp]
											windowNumber:[theEvent windowNumber]
												 context:[theEvent context]
											 eventNumber:[theEvent eventNumber]
											  clickCount:[theEvent clickCount]
												pressure:[theEvent pressure]];
	[NSApp postEvent:modifiedEvent atStart:YES];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	NSUInteger flags = [theEvent modifierFlags] | ([currentTool shouldShowContextualMenu] ? NSControlKeyMask : NSAlternateKeyMask);
	
	NSEvent *modifiedEvent = [NSEvent mouseEventWithType:NSLeftMouseUp
												location:[theEvent locationInWindow] 
										   modifierFlags:flags
											   timestamp:[theEvent timestamp]
											windowNumber:[theEvent windowNumber]
												 context:[theEvent context]
											 eventNumber:[theEvent eventNumber]
											  clickCount:[theEvent clickCount]
												pressure:[theEvent pressure]];
	[NSApp postEvent:modifiedEvent atStart:YES];
}


// Currently only necessary for the text tool, but we'll see where we go with it
- (void)mouseMoved:(NSEvent *)event
{
	//NSLog(@"Moved");
	NSPoint p = [event locationInWindow];
	NSPoint motionPoint = [self convertPoint:p fromView:nil];
	
	// Necessary for when the view is zoomed above 100%
	motionPoint.x = floor(motionPoint.x) + 0.5;
	motionPoint.y = floor(motionPoint.y) + 0.5;	
	[currentTool mouseHasMoved:motionPoint];
	//motionPath = [currentTool pathFromPoint:motionPoint toPoint:motionPoint];
	//[self setNeedsDisplay:YES];
}


// Overridden to set the correct cursor
- (void)cursorUpdate:(NSEvent *)event
{
	if (toolbox && [toolbox currentTool]) {
		NSCursor *cursor = [[toolbox currentTool] cursor];
		if (cursor != [(NSClipView *)[self superview] documentCursor]) {
			[(NSClipView *)[self superview] setDocumentCursor:cursor];
		}		
	}
}


// Handles keyboard events
- (void)keyDown:(NSEvent *)event
{
	// Escape key
	if ([event keyCode] == 53) {
		isPayingAttention = NO;
		[currentTool tieUpLooseEnds];
		[SWImageTools clearImage:bufferImage];
		[self setNeedsDisplay:YES];
		
	} else if ([event keyCode] == 51 || [event keyCode] == 117) {
		// Delete keys (back and forward)
		[self clearOverlay];
	} else {
		[[[toolboxController window] contentView] keyDown:event];
	}
}

#pragma mark MyDocument tells PaintView this information from the Toolbox

////////////////////////////////////////////////////////////////////////////////
//////////		MyDocument tells PaintView this information from the Toolbox
////////////////////////////////////////////////////////////////////////////////


- (void)setImage:(NSBitmapImageRep *)newImage scale:(BOOL)scale
{	
	[SWImageTools clearImage:mainImage];
	[SWImageTools clearImage:bufferImage];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:mainImage]];
	if (scale) {
		// Stretch the image to the correct size
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		[newImage drawInRect:[self bounds]];
	} else {
		[[toolboxController backgroundColor] setFill];
		NSRectFill([self bounds]);
		[newImage drawAtPoint:NSMakePoint(0, [self bounds].size.height - [newImage size].height)];
	}
	[NSGraphicsContext restoreGraphicsState];
	[self setNeedsDisplay:YES];
}

- (void)setCurrentTool:(SWTool *)newTool
{
	[newTool retain];
	[currentTool release];
	currentTool = newTool;
}

- (void)setBackgroundColor:(NSColor *)color
{
	[color retain];
	[backgroundColor release];
	backgroundColor = color;
}

#pragma mark Handling undo: a "prep" and then the actual method

////////////////////////////////////////////////////////////////////////////////
//////////		Handling undo: a "prep" and then the actual method
////////////////////////////////////////////////////////////////////////////////


- (void)prepUndo:(id)sender
{
	NSUndoManager *undo = [self undoManager];
	NSRect oldFrame = NSZeroRect;
	if (sender && [(NSDictionary *)sender objectForKey:@"Image"]) {
		if ([(NSDictionary *)sender objectForKey:@"Frame"]) {
			// It was a resize... oh dear!
			oldFrame = [[(NSDictionary *)sender objectForKey:@"Frame"] rectValue];
			[[undo prepareWithInvocationTarget:self] undoResize:(NSData *)[sender objectForKey:@"Image"] oldFrame:oldFrame];
			if (![undo isUndoing]) {
				[undo setActionName:@"Resize"];
			}			
			//[[undo prepareWithInvocationTarget:self] undoResize:[mainImage TIFFRepresentation] oldFrame:oldFrame];
		} else {
			[[undo prepareWithInvocationTarget:self] undoResize:(NSData *)[sender objectForKey:@"Image"] oldFrame:oldFrame];
			if (![undo isUndoing]) {
				[undo setActionName:@"Drawing"];
			}			
//			[[undo prepareWithInvocationTarget:self] undoImage:(NSData *)[sender objectForKey:@"Image"]];
		}
	} else {
		//[[undo prepareWithInvocationTarget:self] undoImage:[mainImage TIFFRepresentation]];
		[[undo prepareWithInvocationTarget:self] undoResize:[mainImage TIFFRepresentation] oldFrame:oldFrame];
		if (![undo isUndoing]) {
			[undo setActionName:@"Drawing"];
		}
	}
}

// Undo for drawing that doesn't change the canvas
//- (void)undoImage:(NSData *)mainImageData
//{
//	NSUndoManager *undo = [self undoManager];
//	[[undo prepareWithInvocationTarget:self] undoImage:[[self mainImage] TIFFRepresentation]];
//	if (![undo isUndoing]) {
//		[undo setActionName:@"Drawing"];
//	}
//	
//	imageRep = [[NSBitmapImageRep alloc] initWithData:mainImageData];
//	
//	[mainImage lockFocus];
//	[imageRep drawAtPoint:NSZeroPoint];
//	[mainImage unlockFocus];
//	[self clearOverlay];
//}

// Undo canvas resizing
- (void)undoResize:(NSData *)mainImageData oldFrame:(NSRect)frame
{
	NSUndoManager *undo = [self undoManager];
	NSRect currentFrame = NSZeroRect;
	currentFrame.size = [mainImage size];
	[[undo prepareWithInvocationTarget:self] undoResize:[mainImage TIFFRepresentation] oldFrame:currentFrame];
	if (![undo isUndoing]) {
		if (NSEqualRects(frame, NSZeroRect)) {
			[undo setActionName:@"Drawing"];
		} else {
			[undo setActionName:@"Resize"];
		}
	}
	
	if (!NSEqualRects(frame, NSZeroRect)) {
		[self setFrame:frame];
		[self preparePaintView];
		//NSRect tempRect = [self calculateWindowBounds:frame];
		//[[self window] setFrame:tempRect display:YES];
	}
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:mainImageData];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:mainImage]];
	[imageRep drawAtPoint:NSMakePoint(0, [self bounds].size.height - [imageRep pixelsHigh])];
	[imageRep release];
	[NSGraphicsContext restoreGraphicsState];
	[self clearOverlay];
}


////////////////////////////////////////////////////////////////////////////////
//////////      Grid-Related Methods
////////////////////////////////////////////////////////////////////////////////


// Generates the NSBezeierPath used as the grid
- (NSBezierPath *)gridInRect:(NSRect)rect
{
    NSUInteger curLine, endLine;
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
	
    // Columns
    curLine = ceil((NSMinX(rect)) / gridSpacing) + 1;
    endLine = ceil((NSMaxX(rect)) / gridSpacing) - 1;
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint((curLine * gridSpacing), NSMinY(rect))];
        [gridPath lineToPoint:NSMakePoint((curLine * gridSpacing), NSMaxY(rect))];
    }
	
    // Rows
    curLine = ceil((NSMinY(rect)) / gridSpacing) + 1;
    endLine = ceil((NSMaxY(rect)) / gridSpacing) - 1;
    for (; curLine<=endLine; curLine++) {
        [gridPath moveToPoint:NSMakePoint(NSMinX(rect), (curLine * gridSpacing))];
        [gridPath lineToPoint:NSMakePoint(NSMaxX(rect), (curLine * gridSpacing))];
    }
	
    //[gridPath setLineWidth:0.5];
    [gridPath setLineWidth:(1.0 / [(SWScalingScrollView *)[[self superview] superview] scaleFactor])];
    //[gridPath stroke];
	return gridPath;
}

// Switch the grid, if it isn't already the same as the parameter
- (void)setShowsGrid:(BOOL)shouldShowGrid 
{
	if (shouldShowGrid != showsGrid) {
		showsGrid = !showsGrid;
		[self setNeedsDisplay:YES];
	}
}

// Change the spacing of the grid, based off the slider in the GridController
- (void)setGridSpacing:(CGFloat)newGridSpacing 
{
	if (gridSpacing != newGridSpacing) {
		gridSpacing = newGridSpacing;
		[self setNeedsDisplay: YES];
	}
}

// Change the color of the grid from the default gray
- (void)setGridColor:(NSColor *)newGridColor 
{
	[newGridColor retain];
	[gridColor release];
	gridColor = newGridColor;
	[self setNeedsDisplay: YES];
}

// Should the grid be shown? Hmm...
- (BOOL)showsGrid 
{
	return showsGrid;
}

// Returns the spacing of the grid
- (CGFloat)gridSpacing 
{
	return gridSpacing;
}

// If there is a grid color, return it... otherwise, go with light gray
- (NSColor *)gridColor 
{
	return gridColor;
}

#pragma mark Miscellaneous

////////////////////////////////////////////////////////////////////////////////
//////////		Miscellaneous
////////////////////////////////////////////////////////////////////////////////


// Releases the overlay image, then tells the tool about it
- (void)clearOverlay
{
	[SWImageTools clearImage:bufferImage];
	[currentTool deleteKey];
	[currentTool tieUpLooseEnds];
	[self setNeedsDisplay:YES];
}

// Pastes data as an image
- (void)pasteData:(NSData *)data
{
	[currentTool tieUpLooseEnds];
	[toolboxController switchToScissors:nil];
	currentTool = [toolbox currentTool];
	[self cursorUpdate:nil];
	NSBitmapImageRep *temp = [[NSBitmapImageRep alloc] initWithData:data];
	
	//NSLog(@"%@ - [[self superview] bounds] == (%lf, %lf), @ %lf by %lf", [self superview],
	//	  [[self superview] bounds].origin.x, [[self superview] bounds].origin.y, 
	//	  [[self superview] bounds].size.width, [[self superview] bounds].size.height);
		  //[self bounds].origin.x, [self bounds].origin.y, 
		  //[self bounds].size.width, [self bounds].size.height);
	
	NSPoint origin = [[self superview] bounds].origin;
	if (origin.x < 0) origin.x = 0;
	if (origin.y < 0) origin.y = 0;

	origin.y = [self bounds].size.height - origin.y;
	origin.y -= [temp size].height;
	
	NSRect rect = NSZeroRect;
	rect.origin = origin;
	
	// Use ceiling because pixels can be fractions, but the tool assumes integer values								 
	rect.size = NSMakeSize(ceil([temp size].width), ceil([temp size].height));
	
	[SWImageTools clearImage:bufferImage];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bufferImage]];
	[temp drawAtPoint:rect.origin];
	[NSGraphicsContext restoreGraphicsState];
	
	[(SWSelectionTool *)currentTool setClippingRect:rect
										   forImage:bufferImage];
	[temp release];
	[self setNeedsDisplay:YES];
}

// Returns the mainImage
- (NSBitmapImageRep *)mainImage
{
	return mainImage;
}

// Returns the overlay
- (NSBitmapImageRep *)bufferImage
{
	return bufferImage;
}


// Tells the mainImage to refresh itself. Can be called from anywhere in the application.
- (void)refreshImage:(id)sender
{
	if (sender) {
		[self setNeedsDisplayInRect:[sender invalidRect]];
	} else {
		[self setNeedsDisplay:YES];
	}
}

// We can't promise we're opaque!
- (BOOL)isOpaque
{
	return NO;
}


// Necessary to allow keyboard events and stuff
- (BOOL)acceptsFirstResponder
{
	return YES;
}


- (BOOL)isFlipped
{
	return YES;
}

   
- (void)dealloc
{
	if (undoData) {
		[undoData release];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[frontColor release];
	[backColor release];
	[mainImage release];
	//[imageRep release];
	[toolbox release];
	[[self undoManager] removeAllActions]; 
	// Note: do NOT release the current tool, as it is just a pointer to the
	// object inherited from ToolboxController
 
	[super dealloc];
}

@end
