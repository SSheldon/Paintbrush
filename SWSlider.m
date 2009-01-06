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
	}
	
	if (fabs(savedScroll) >= 1.0) {
		NSInteger newValue = [self integerValue] + (savedScroll / fabs(savedScroll));
		NSInteger newValue2 = fmin(fmax(1, newValue), [self maxValue]);
		//[self setIntegerValue:newValue2];
		savedScroll = 0.0;
		
		// Notify the toolbox controller that we've moved the slider through
		// an alternate channel
		SWToolboxController *t = [SWToolboxController sharedToolboxPanelController];
		[t setLineWidthDisplay:newValue2];
	}
}


@end
