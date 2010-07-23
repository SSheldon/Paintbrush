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
