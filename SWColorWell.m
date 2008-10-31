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


#import "SWColorWell.h"

@implementation SWColorWell

// Overwriting NSColorWell to add one interesting feature: when an active
//  well is selected (deactivating it), the associated NSColorPanel is 
//  closed, reinforcing the fact that it has been deselected, as well as
//  eliminating the possibility of CGFloat-clicking and unknowingly
//  deactivating the well.
- (void)deactivate {
	[super deactivate];
	[[NSColorPanel sharedColorPanel] close];
}

- (void)drawRect:(NSRect)rect
{
	//[super drawRect:rect];
	[self lockFocus];
	//rect = NSInsetRect(rect, 3.0, 3.0);
	[[self color] setFill];
	[NSBezierPath fillRect:rect];
//	rect = NSInsetRect(rect, 10, 10);
//	[[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.0] setFill];
//	NSRectFill(rect);
	[self unlockFocus];
}

- (BOOL)isOpaque
{
	return NO;
}

@end
