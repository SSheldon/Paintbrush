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


#import "SWEyeDropperTool.h"


@implementation SWEyeDropperTool

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(SWMouseEvent)event;
{
	// This only needs to happen once
	if (event == MOUSE_DOWN) {
		imageRep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
		[imageRep setColorSpaceName:NSDeviceRGBColorSpace];
	}
	
	// This should happen regardless of the type of click
	NSColor *colorClicked = [imageRep colorAtX:point.x y:([imageRep pixelsHigh] - point.y - 1)];
	
	if (colorClicked != nil) {
		colorClicked = [colorClicked colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		if (flags & NSAlternateKeyMask) {
			[[[SWToolboxController sharedToolboxPanelController] backgroundColorWell] setColor:colorClicked];
			[[SWToolboxController sharedToolboxPanelController] changeBackgroundColor:
			 [[SWToolboxController sharedToolboxPanelController] backgroundColorWell]];
		} else {
			[[[SWToolboxController sharedToolboxPanelController] foregroundColorWell] setColor:colorClicked];
			[[SWToolboxController sharedToolboxPanelController] changeForegroundColor:
			 [[SWToolboxController sharedToolboxPanelController] foregroundColorWell]];			
		}
	}
}

- (NSString *)name
{
	return @"EyeDropper";
}

- (NSCursor *)cursor
{
	NSImage *customImage = [NSImage imageNamed:@"eyedrop-cursor.png"];
	NSCursor *customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,15)];
	return customCursor;
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}	


@end
