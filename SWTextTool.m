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


#import "SWTextTool.h"

@implementation SWTextTool

- (id)initWithController:(SWToolboxController *)controller
{
	if (self = [super initWithController:controller]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(insertText:)
													 name:@"SWTextEntered"
												   object:nil];
		canInsert = NO;
		stringToInsert = nil;
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSImage *)anImage 
						 secondImage:(NSImage *)secondImage 
						  mouseEvent:(SWMouseEvent)event
{
	_anImage = anImage;
	_secondImage = secondImage;
	
	if (canInsert && event == MOUSE_MOVED) {
		SWClearImage(secondImage);
		[secondImage lockFocus];
		
		// Assign the redrawRect based on the string's size and the insertion point
		NSRect rectA = [stringToInsert boundingRectWithSize:[stringToInsert size] options:NSStringDrawingUsesDeviceMetrics];
		NSRect rectB = [stringToInsert boundingRectWithSize:[stringToInsert size] options:NSStringDrawingUsesFontLeading];

		NSRect rect = NSUnionRect(rectA, rectB);
		CGFloat xOffset = abs(rect.origin.x);
		rect.size.width += xOffset;
		rect.origin = point;
		rect.origin.y -= (rectB.size.height - rectA.size.height);
		
		[super addRectToRedrawRect:rect];
		
		rect.origin.x += xOffset;
		rect.size.width += xOffset;
		
		[stringToInsert drawInRect:rect];
		[secondImage unlockFocus];

		[NSApp sendAction:@selector(refreshImage:)
					   to:nil
					 from:self];
	} else if (event == MOUSE_DOWN) {
		if (canInsert) {
			[NSApp sendAction:@selector(prepUndo:)
						   to:nil
						 from:nil];
			[anImage lockFocus];
			[secondImage drawAtPoint:NSZeroPoint 
							fromRect:NSZeroRect 
						   operation:NSCompositeSourceOver 
							fraction:1.0];
			[anImage unlockFocus];
			canInsert = NO;
			stringToInsert = nil;
			
			SWClearImage(secondImage);

			[NSApp sendAction:@selector(refreshImage:)
						   to:nil
						 from:nil];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SWText" object:frontColor];
			canInsert = YES;
		} 
	}
	return nil;
}

// Summoned by the NSNotificationCenter when the user clicks "OK" in the sheet
- (void)insertText:(NSNotification *)note
{
	stringToInsert = [[NSAttributedString alloc] initWithAttributedString:[[note userInfo] objectForKey:@"newText"]];
	[NSApp sendAction:@selector(refreshImage:)
				   to:nil
				 from:nil];
}

// Overridden for drawing to the buffer image
- (void)mouseHasMoved:(NSPoint)point
{
	if (stringToInsert) {
		[self performDrawAtPoint:point withMainImage:_anImage secondImage:_secondImage mouseEvent:MOUSE_MOVED];		
	}
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	stringToInsert = nil;
	canInsert = NO;
}

- (NSCursor *)cursor
{
	return [NSCursor IBeamCursor];
}


// Overridden for right-click
- (BOOL)shouldShowContextualMenu
{
	return YES;
}

- (NSString *)description
{
	return @"Text";
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
