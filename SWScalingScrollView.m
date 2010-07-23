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


#import "SWScalingScrollView.h"
#import "SWCenteringClipView.h"
#import "SWDocument.h"

static NSString *scaleMenuLabels[] = { @"25%", @"50%", @"100%", @"200%", @"400%", @"800%", @"1600%"};
static CGFloat scaleMenuFactors[] = { 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0};
static unsigned defaultIndex = 2;

@implementation SWScalingScrollView

- (id)initWithFrame:(NSRect)rect 
{
    if ((self = [super initWithFrame:rect])) {
        scaleFactor = 1.0;
    }
    return self;
}


- (void)makeScalePopUpButton 
{
    if (scalePopUpButton == nil) {
        unsigned cnt, numberOfDefaultItems = (sizeof(scaleMenuLabels) / sizeof(NSString *));
        id curItem;
		
        // create it
		scalePopUpButton = [[NSPopUpButton allocWithZone:[self zone]] initWithFrame:NSMakeRect(0.0, 0.0, 1.0, 1.0) pullsDown:NO];
		[(NSPopUpButtonCell *)[scalePopUpButton cell] setBezelStyle:NSShadowlessSquareBezelStyle];
		//[scalePopUpButton setBezelStyle:NSShadowlessSquareBezelStyle];
		[[scalePopUpButton cell] setArrowPosition:NSPopUpArrowAtBottom];
        
        // fill it
        for (cnt = 0; cnt < numberOfDefaultItems; cnt++) {
            [scalePopUpButton addItemWithTitle:NSLocalizedString(scaleMenuLabels[cnt], nil)];
            curItem = [scalePopUpButton itemAtIndex:cnt];
            if (scaleMenuFactors[cnt] != 0.0) {
                [curItem setRepresentedObject:[NSNumber numberWithFloat:scaleMenuFactors[cnt]]];
            }
        }
        [scalePopUpButton selectItemAtIndex:defaultIndex];
		
        // hook it up
        [scalePopUpButton setTarget:self];
        [scalePopUpButton setAction:@selector(scalePopUpAction:)];
		
        // set a suitable font
        [scalePopUpButton setFont:[NSFont controlContentFontOfSize:[NSFont smallSystemFontSize]]];
		
        // Make sure the popup is big enough to fit the cells.
        [scalePopUpButton sizeToFit];
		
		// don't let it become first responder
		[scalePopUpButton setRefusesFirstResponder:YES];
		
        // put it in the scrollview
        [self addSubview:scalePopUpButton];
    }
}

- (void)tile 
{
    // Let the superclass do most of the work.
    [super tile];
	
    if (![self hasHorizontalScroller]) {
        if (scalePopUpButton) [scalePopUpButton removeFromSuperview];
        scalePopUpButton = nil;
    } else {
		NSScroller *horizScroller;
		NSRect horizScrollerFrame, buttonFrame;
		
		if (!scalePopUpButton) {
			[self makeScalePopUpButton];
		}
		
		horizScroller = [self horizontalScroller];
		horizScrollerFrame = [horizScroller frame];
		buttonFrame = [scalePopUpButton frame];
		
		// Now we'll just adjust the horizontal scroller size and set the button size and location.
		horizScrollerFrame.size.width = horizScrollerFrame.size.width - buttonFrame.size.width;
		horizScrollerFrame.origin.x = buttonFrame.size.width;
		[horizScroller setFrame:horizScrollerFrame];

		// Puts it on the left
		buttonFrame.origin.x = 0;
		buttonFrame.size.height = horizScrollerFrame.size.height + 1.0;
		buttonFrame.origin.y = [self bounds].size.height - buttonFrame.size.height + 1.0;
		[scalePopUpButton setFrame:buttonFrame];
	}
}

- (void)scalePopUpAction:(id)sender 
{
    NSNumber *selectedFactorObject = [[sender selectedCell] representedObject];
    
    if (selectedFactorObject == nil) {
        DebugLog(@"Scale popup action: setting arbitrary zoom factors is not yet supported.");
        return;
    } else {
        [self setScaleFactor:[selectedFactorObject floatValue] adjustPopup:NO];
    }
}

- (CGFloat)scaleFactor 
{
    return scaleFactor;
}

// Used by the Zoom tool: zooms and centers on a specific point
- (void)setScaleFactor:(CGFloat)factor atPoint:(NSPoint)point adjustPopup:(BOOL)flag
{
	[self setScaleFactor:factor adjustPopup:flag];
	
	SWCenteringClipView *clipView = (SWCenteringClipView *)[[self documentView] superview];
	NSSize size = [clipView bounds].size;

	// Sets the top-left corner to the point clicked
	// NO NEED WHEN THE VIEW IS FLIPPED, as it is starting with v2.1
//	point.y = [clipView documentRect].size.height - point.y - 1;
	
	// Scroll to the correct centered spot thing
	point.x -= size.width / 2;
	point.y -= size.height / 2;
	[clipView setBoundsOrigin:[clipView constrainScrollPoint:point]];
}


- (void)setScaleFactor:(CGFloat)newScaleFactor adjustPopup:(BOOL)flag 
{
    if (scaleFactor != newScaleFactor) {
		NSSize curDocFrameSize, newDocBoundsSize, curDocBoundsSize;
		NSPoint newDocBoundsOrigin;
		// Make a backup!
		//CGFloat oldScaleFactor = scaleFactor;
		
		SWCenteringClipView *clipView = (SWCenteringClipView *)[[self documentView] superview];
		
        if (flag) {	// Coming from elsewhere, first validate it
            NSInteger cnt = 0, numberOfDefaultItems = (sizeof(scaleMenuFactors) / sizeof(CGFloat));
			
            // We only work with the preset zoom values, so choose one of the appropriate values 
			//  (Fudge a little for floating point comparison to work)
            while (cnt < numberOfDefaultItems && newScaleFactor * .99 > scaleMenuFactors[cnt]) {
				cnt++;
			}
            if (cnt == numberOfDefaultItems) {
				cnt--;
				return;
			}
            [scalePopUpButton selectItemAtIndex:cnt];
            scaleFactor = scaleMenuFactors[cnt];
        } else {
            scaleFactor = newScaleFactor;
        }
				
		// Get the frame.  The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		
		// Get the size for fun calculations
		curDocBoundsSize = [clipView bounds].size;
		
		// The new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width / scaleFactor;
		newDocBoundsSize.height = curDocFrameSize.height / scaleFactor;
				
		// Likewise, adjust the bottom-left corner to maintain centered-ness
		newDocBoundsOrigin.x = [clipView bounds].origin.x + (curDocBoundsSize.width - newDocBoundsSize.width) / 2;
		newDocBoundsOrigin.y = [clipView bounds].origin.y + (curDocBoundsSize.height - newDocBoundsSize.height) / 2;

		// Finally, inform the clip view of the changes we've made		
		[clipView setBoundsSize:newDocBoundsSize];
		[clipView setBoundsOrigin:newDocBoundsOrigin];
		
		// Make sure the window size is correct
		NSRect frame = [[self window] frame];
				
		// Initially constrain the window size
		if (scaleFactor > 1.0) {
			NSRect contentRect = [[self window] contentRectForFrameRect:NSMakeRect(0,0,frame.size.width-[NSScroller scrollerWidth],
																				   frame.size.height-[NSScroller scrollerWidth])];
			contentRect.size.width =  round(contentRect.size.width / scaleFactor) * scaleFactor + [NSScroller scrollerWidth];
			contentRect.size.height = round(contentRect.size.height / scaleFactor) * scaleFactor + [NSScroller scrollerWidth];
			
			NSRect newRect = [[self window] frameRectForContentRect:contentRect];
			
			frame.size = newRect.size;
		}
		
		CGFloat factor = fmax(1.0, scaleFactor);
		[[self window] setResizeIncrements:NSMakeSize(factor, factor)];
		[[self window] setFrame:frame display:YES animate:YES];
		
		// Constrain the origin
		[clipView setBoundsOrigin:[clipView constrainScrollPoint:[clipView bounds].origin]];
	}
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)dealloc
{
	[scalePopUpButton release];
	[super dealloc];
}

@end
