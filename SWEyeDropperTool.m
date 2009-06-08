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


#import "SWEyeDropperTool.h"
#import "SWToolboxController.h"


@implementation SWEyeDropperTool

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)anImage 
						 secondImage:(NSBitmapImageRep *)secondImage 
						  mouseEvent:(SWMouseEvent)event
{
	// This only needs to happen once
	if (event == MOUSE_DOWN) {
		if (imageRep) {
			[imageRep release];
		}
		imageRep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
		[imageRep setColorSpaceName:NSDeviceRGBColorSpace];
	}
	
	// This should happen regardless of the type of click
	NSColor *colorClicked = [imageRep colorAtX:point.x y:([imageRep pixelsHigh] - point.y - 1)];
	
	if (colorClicked != nil) {
		colorClicked = [colorClicked colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
		if (flags & NSAlternateKeyMask) {
			[[SWToolboxController sharedToolboxPanelController] setBackgroundColor:colorClicked];
		} else {
			[[SWToolboxController sharedToolboxPanelController] setForegroundColor:colorClicked];
		}
	}

	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"eyedrop-cursor.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,15)];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Eyedropper";
}


@end
