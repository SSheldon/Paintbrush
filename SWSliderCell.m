/**
 * Copyright 2007-2009 Soggy Waffles
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


#import "SWSliderCell.h"


@implementation SWSliderCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	[super initWithCoder:aDecoder];
	knobImage = [NSImage imageNamed:@"knob"];
	NSLog(@"Made the slider");
	return self;
}

// Overridden to 
- (void)drawKnob:(NSRect)knobRect {
	NSLog(@"%@", [NSValue valueWithRect:knobRect]);
	[knobImage compositeToPoint:NSMakePoint(knobRect.origin.x,knobRect.origin.y+knobRect.size.height) 
					  operation:NSCompositeSourceOver];
}

@end
