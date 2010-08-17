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


#import "SWColorSelector.h"
#import "SWColorWell.h"


@implementation SWColorSelector

- (id)initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	
	[self addTrackingArea:[[NSTrackingArea alloc] initWithRect:[self frame]
													   options: NSTrackingActiveInActiveApp | NSTrackingInVisibleRect 
						   | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited
														 owner:self
													  userInfo:nil]];
	[[self window] setAcceptsMouseMovedEvents:YES];
	//	[self seta
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateWells:) 
												 name:@"SWColorSet" 
											   object:nil];
	
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


//- (void)observeValueForKeyPath:(NSString *)keyPath 
//					  ofObject:(id)object
//						change:(NSDictionary *)change 
//					   context:(void *)context
//{
//	if ([keyPath isEqualToString:@"foregroundColor"]) {
//		DebugLog(@"Changed foreground color");
//	} else if ([keyPath isEqualToString:@"backgroundColor"]) {
//		DebugLog(@"Changed background color");
//	} else {
//		DebugLog(@"BOOM");
//	}
//}

- (void)mouseExited:(NSEvent *)event
{
	[backWell setIsHovered:NO];
	[frontWell setIsHovered:NO];
	[self updateWells:nil];
}

- (void)mouseMoved:(NSEvent *)event
{
	NSPoint p = [event locationInWindow];
	NSPoint downPoint = [self convertPoint:p fromView:nil];
	if ([frontWell hitTest:downPoint])
	{
		[backWell setIsHovered:NO];
		[frontWell setIsHovered:YES];
	}
	else if ([backWell hitTest:downPoint]) 
	{
		[backWell setIsHovered:YES];
		[frontWell setIsHovered:NO];
	}
	else 
	{
		[backWell setIsHovered:NO];
		[frontWell setIsHovered:NO];
	}
	
	[self updateWells:nil];
}


- (void)mouseDown:(NSEvent *)event
{
	[self updateWells:nil];
}


// Called whenever one of the color wells has changed colors, so both can redraw
- (void)updateWells:(NSNotification *)n
{
	[backWell setNeedsDisplay:YES];
	[frontWell setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstMouse
{
	return YES;
}

@end
