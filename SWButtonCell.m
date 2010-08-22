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


#import "SWButtonCell.h"


@implementation SWButtonCell

- (void)setAlternateImage:(NSImage *)image
{
	// We never want an alternate image other than ours to be set
	return;
}

- (id)initWithCoder:(NSCoder *)coder
{
	[super initWithCoder:coder];
	
	backupImage = [[self image] retain];
	
	// Generate the two images we'll use for the other states
	[self generateAltImage];
	[self generateHovImage];
	
	return self;
}

- (void)generateAltImage
{
	if (!altImage) 
	{
		NSImage *normal = [self image];
		NSImage *highlight;
		NSSize size = [normal size];
		
		if (NSEqualSizes(size, NSMakeSize(32, 32)))
			highlight = [NSImage imageNamed:@"pressedsmall.png"];			
		else if (NSEqualSizes(size, NSMakeSize(64, 32)))
			highlight = [NSImage imageNamed:@"pressedwide.png"];
		else if (NSEqualSizes(size, NSMakeSize(64, 48)))
			highlight = [NSImage imageNamed:@"pressedwidetall.png"];
		else
			return;
		
		altImage = [[NSImage alloc] initWithSize:size];
		[altImage lockFocus];
		[highlight drawAtPoint:NSZeroPoint
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver
					  fraction:1.0];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowBlurRadius:4.0];
		[shadow setShadowColor:[NSColor whiteColor]];
		[shadow set];
		[normal drawAtPoint:NSZeroPoint
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:1.0];
		[shadow release];
		[altImage unlockFocus];
	}
}

- (void)generateHovImage
{
	if (!hovImage)
	{
		NSImage *normal = [self image];
		NSImage *highlight;
		NSSize size = [normal size];
		
		if (NSEqualSizes(size, NSMakeSize(32, 32)))
			highlight = [NSImage imageNamed:@"hoveredsmall.png"];			
		else if (NSEqualSizes(size, NSMakeSize(64, 32)))
			highlight = [NSImage imageNamed:@"hoveredwide.png"];
		else if (NSEqualSizes(size, NSMakeSize(64, 48)))
			highlight = [NSImage imageNamed:@"hoveredwidetall.png"];
		else
			return;
		
		hovImage = [[NSImage alloc] initWithSize:size];
		[hovImage lockFocus];
		[highlight drawAtPoint:NSZeroPoint
					  fromRect:NSZeroRect
					 operation:NSCompositeSourceOver
					  fraction:1.0];
		
		[normal drawAtPoint:NSZeroPoint
				   fromRect:NSZeroRect
				  operation:NSCompositeSourceOver
				   fraction:1.0];
		[hovImage unlockFocus];
	}
}

- (void)setIsHovered:(BOOL)flag;
{
	if (flag)
		[self setImage:hovImage];
	else
		[self setImage:backupImage];
}

- (NSImage *)alternateImage
{
	if (!altImage) {
		[self generateAltImage];
	}
	return altImage;
}

- (void)dealloc
{
	[altImage release];
	[hovImage release];
	[backupImage release];
	
	[super dealloc];
}


@end
