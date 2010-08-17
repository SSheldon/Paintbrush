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


#import "SWColorWell.h"
#import "SWColorSelector.h"

@implementation SWColorWell

@synthesize isHovered;


- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	
	hovImage = [NSImage imageNamed:@"hoveredwell.png"];
	pressedImage = [NSImage imageNamed:@"pressedwell.png"];
	
	return self;
}


// Overwriting NSColorWell to add one interesting feature: when an active
//  well is selected (deactivating it), the associated NSColorPanel is 
//  closed, reinforcing the fact that it has been deselected, as well as
//  eliminating the possibility of CGFloat-clicking and unknowingly
//  deactivating the well.
- (void)deactivate 
{
	// While we're at it, redraw everything
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWColorSet" object:nil];
	[super deactivate];
	[[NSColorPanel sharedColorPanel] close];
}


// Instead of doing the regular drawing, we're kicking it up a notch!  Bam!
- (void)drawRect:(NSRect)rect
{
	if (isHovered) 
		rect = NSInsetRect(rect, 3.0, 3.0);
	else
		rect = NSInsetRect(rect, 4.0, 4.0);
	
	// An SWColorWell can be hovered, selected, or neither
	if ([self isActive]) 
	{
		[pressedImage drawAtPoint:NSZeroPoint 
						 fromRect:NSZeroRect 
						operation:NSCompositeSourceOver 
						 fraction:1.0];	
	} 
	else if (isHovered) 
	{
		[hovImage drawAtPoint:NSZeroPoint 
					 fromRect:NSZeroRect 
					operation:NSCompositeSourceOver 
					 fraction:1.0];
	}
	
	rect.origin.x += 0.5;
	rect.origin.y += 0.5;
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:4 yRadius:4];
	[path setLineWidth:1.0];
	
	// Draw the fill now
	[[self color] setFill];		
	[path fill];
	
	[[NSColor grayColor] setStroke];
	[path stroke];
}


// When either of these three actions happens, make sure we redraw BOTH rects!  Very important.
- (void)setColor:(NSColor *)color
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWColorSet" object:nil];
	[super setColor:color];
}

- (void)mouseDown:(NSEvent *)event
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWColorSet" object:nil];
	[super mouseDown:event];
	[[self superview] mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWColorSet" object:nil];
	[super mouseUp:event];
	[[self superview] mouseUp:event];
}

- (BOOL)isOpaque
{
	return NO;
}

@end
