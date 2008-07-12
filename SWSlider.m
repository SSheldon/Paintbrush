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


#import "SWSlider.h"
#import "SWToolboxController.h"

@implementation SWSlider

// We override this method of NSResponder so that when the user scrolls while hovering
// over the scroller, the value changes. This works for both X and Y scrolling, though
// any deltaX will be given higher precedence. This results in a smooth and natural
// scrolling motion, similar to that found with the volume scroller in iTunes
- (void)scrollWheel:(NSEvent *)theEvent
{
	CGFloat deltaX = [theEvent deltaX];
	CGFloat deltaY = [theEvent deltaY];
	if (deltaX) {
		// For some reason, deltaX is a negative value when scrolling to the right
		savedScroll -= deltaX;
	} else if (deltaY) {
		savedScroll += deltaY;
		NSLog(@"They scrolled y by %lf", deltaY);
	}
	
	if (fabs(savedScroll) >= 1.0) {
		[self setIntegerValue:[self integerValue] + (savedScroll / fabs(savedScroll))];	
		savedScroll = 0.0;
	}
	
	// Notify the toolbox controller that we've moved the slider through
	// an alternate channel
	[[SWToolboxController sharedToolboxPanelController] changeLineWidth:self];
}


@end
