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


#import "SWZoomTool.h"
#import "SWPaintView.h"
#import "SWDocument.h"
#import "SWScalingScrollView.h"

@implementation SWZoomTool

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	// Only zoom on a down-click
	if (event == MOUSE_DOWN) {
		NSDocumentController *controller = [NSDocumentController sharedDocumentController];
		id document = [controller documentForWindow: [NSApp mainWindow]];
		
		// If it's a Paintbrush document, get its PaintView
		if (document && [document isKindOfClass:[SWDocument class]]) {
			SWScalingScrollView *scrollView = (SWScalingScrollView *) [[[document paintView] superview] superview];
			
			// Were they zooming in or out?
			if (flags & NSAlternateKeyMask) {
				[scrollView setScaleFactor:([scrollView scaleFactor] / 2.0) atPoint:point adjustPopup:YES];
			} else {
				[scrollView setScaleFactor:([scrollView scaleFactor] * 2.0) atPoint:point adjustPopup:YES];				
			}
		}
	}
	return nil;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		NSImage *customImage = [NSImage imageNamed:@"zoom-cursor-2.png"];
		customCursor = [[NSCursor alloc] initWithImage:customImage hotSpot:NSMakePoint(1,15)];
	}
	return customCursor;
}

- (NSString *)description
{
	return @"Zoom";
}

@end
