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


#import "SWMatrix.h"
#import "SWButtonCell.h"

@implementation SWMatrix

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self frame]
													   options: NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect
														 owner:self
													  userInfo:nil] autorelease]];
	
	[[self window] setAcceptsMouseMovedEvents:YES];
	hoveredPoint = NSMakePoint(-1,-1);
	hoveredCell = nil;
	
	return self;
}

// When the mouse exits the tracking area, remove any highlights
- (void)mouseExited:(NSEvent *)theEvent
{
	[hoveredCell setIsHovered:NO];
	hoveredPoint = NSMakePoint(-1,-1);
	hoveredCell = nil;
}

// When the mouse moves, make sure the correct button is hovered
- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint p = [theEvent locationInWindow];
	NSPoint converted = [self convertPoint:p fromView:nil];
	
	// Calculate which row and column this point equates to
	NSInteger row, col;
	[self getRow:&row column:&col forPoint:converted];
	
	// Is it a new cell?
	if (hoveredPoint.x != row || hoveredPoint.y != col) {
		hoveredPoint = NSMakePoint(row,col);
		
		// Switch to the new cell
		[hoveredCell setIsHovered:NO];
		hoveredCell = [self cellAtRow:row column:col];
		
		[hoveredCell setIsHovered:YES];			
	}
}

@end
