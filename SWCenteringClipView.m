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


#import "SWCenteringClipView.h"
#import "SWScalingScrollView.h"

@implementation SWCenteringClipView

@synthesize bgImage;

- (void)drawRect:(NSRect)rect {
	// Draw a dark gray gradient background, using the new NSGradient class that has been added in Leopard.
	if (backgroundGradient == nil) {
        backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.88 alpha:1.0]
															endingColor:[NSColor colorWithCalibratedWhite:0.78 alpha:1.0]];
	}
	[backgroundGradient drawInRect:[self bounds] angle:90.0];

	NSRect docRect = [[self documentView] bounds];
	
	if (!bgImageColor && bgImage) {
		bgImageColor = [[NSColor colorWithPatternImage:bgImage] retain];
	}
	
	if (bgImageColor) {
		[bgImageColor setFill];
	} else {
		// Fallback if we haven't received the bgImage
		[[NSColor whiteColor] setFill];		
	}

	[NSGraphicsContext saveGraphicsState];
	
	// Create the shadow below and to the right of the shape.
	if (shadow == nil) {
		shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset:NSMakeSize(5.0, -5.0)];
		[shadow setShadowBlurRadius:15.0];
		
		// Use a partially transparent color for shapes that overlap.
		[shadow setShadowColor:[[NSColor lightGrayColor]
								colorWithAlphaComponent:0.1]];		
	}
	
	[shadow set];
	
	// Draw the background -- either an image pattern or a color
	NSRectFill(docRect);
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)centerDocument
{
	NSRect docRect = [[self documentView] frame];
	NSRect clipRect = [self bounds];

	// We can leave these values as integers (don't need the "2.0")
	if (docRect.size.width < clipRect.size.width) {
		clipRect.origin.x = roundf((docRect.size.width - clipRect.size.width) / 2.0);
	}
	
	if ( docRect.size.height < clipRect.size.height ) {
		clipRect.origin.y = roundf((docRect.size.height - clipRect.size.height) / 2.0);
	}
	
	// Probably the most efficient way to move the bounds origin.
	[self scrollToPoint:clipRect.origin];
}

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
	NSRect docRect = [[self documentView] frame];
	NSRect clipRect = [self bounds];
	NSPoint newScrollPoint = proposedNewOrigin;
	CGFloat maxX = docRect.size.width - clipRect.size.width;
	CGFloat maxY = docRect.size.height - clipRect.size.height;
	
	// If the clip view is wider than the doc, we can't scroll horizontally
	if (docRect.size.width < clipRect.size.width) {
		newScrollPoint.x = round(maxX / 2.0);
	} else {
		newScrollPoint.x = round(MAX(0,MIN(newScrollPoint.x,maxX)));
	}
	
	// If the clip view is taller than the doc, we can't scroll vertically
	if (docRect.size.height < clipRect.size.height) {
		newScrollPoint.y = round( maxY / 2.0 );
	} else {
		newScrollPoint.y = round( MAX(0,MIN(newScrollPoint.y,maxY)) );
	}

	return newScrollPoint;
}

- (void)viewBoundsChanged:(NSNotification *)notification
{
	[super viewBoundsChanged:notification];
	[self centerDocument];
}

- (void)viewFrameChanged:(NSNotification *)notification
{
	[super viewFrameChanged:notification];
	[self centerDocument];
}

// ----------------------------------------
// These superclass methods change the bounds rect directly without sending any notifications,
// so we're not sure what other work they silently do for us. As a result, we let them do their
// work and then swoop in behind to change the bounds origin ourselves. This appears to work
// just fine without us having to reinvent the methods from scratch.

- (void)setBoundsOrigin:(NSPoint)newOrigin
{
	[super setBoundsOrigin:newOrigin];
	[self centerDocument];
}

- (void)setBoundsSize:(NSSize)newSize
{
	[super setBoundsSize:newSize];
	[self centerDocument];
}

- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];
	[self centerDocument];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
	[super setFrameOrigin:newOrigin];
	[self centerDocument];
}

- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[self centerDocument];
}

- (void)setFrameRotation:(CGFloat)angle
{
	[super setFrameRotation:angle];
	[self centerDocument];
}

// Keeps the focus on the top-left corner
- (BOOL)isFlipped
{
	return YES;
}

- (void)dealloc
{
	[backgroundGradient release];
	[shadow release];
	[super dealloc];
}


@end
