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


#import "SWColorSelector.h"
#import "SWColorWell.h"


@implementation SWColorSelector

- (id)initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	
	[self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self frame]
													   options: NSTrackingActiveInActiveApp | NSTrackingInVisibleRect 
																| NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited
														 owner:self
													  userInfo:nil] autorelease]];
	[[self window] setAcceptsMouseMovedEvents:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateWells:) 
												 name:@"SWColorSet" 
											   object:nil];
	
	return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath 
//					  ofObject:(id)object
//						change:(NSDictionary *)change 
//					   context:(void *)context
//{
//	if ([keyPath isEqualToString:@"foregroundColor"]) {
//		NSLog(@"Changed foreground color");
//	} else if ([keyPath isEqualToString:@"backgroundColor"]) {
//		NSLog(@"Changed background color");
//	} else {
//		NSLog(@"BOOM");
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
	if ([frontWell hitTest:downPoint]) {
		[backWell setIsHovered:NO];
		[frontWell setIsHovered:YES];
	} else if ([backWell hitTest:downPoint]) {
		[backWell setIsHovered:YES];
		[frontWell setIsHovered:NO];
	} else {
		[backWell setIsHovered:NO];
		[frontWell setIsHovered:NO];
	}
	
	[self updateWells:nil];
}


// Called whenever one of the color wells has changed colors, so both can redraw
- (void)updateWells:(NSNotification *)n
{
	[frontWell setNeedsDisplay:YES];
	[backWell setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstMouse
{
	return YES;
}

@end
