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

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(insertText:)
													 name:@"SWTextEntered"
												   object:nil];
		//image = [NSImage alloc];
		canInsert = NO;
		stringToInsert = @"";
	}
	return self;
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	return nil;
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(SWMouseEvent)event
{
	_anImage = anImage;
	_secondImage = secondImage;
	
	if (event == MOUSE_DRAGGED) {
		// This loop removes all the representations in the overlay image, effectively clearing it
		for (NSImageRep *rep in [secondImage representations]) {
			[secondImage removeRepresentation:rep];
		}
		[secondImage lockFocus];
		
		// Assign the redrawRect based on the string's size and the insertion point
		//[super setRedrawRectFromPoint:point 
		//					  toPoint:NSMakePoint(point.x + [stringToInsert size].width, point.y + [stringToInsert size].height)];
		[super addRectToRedrawRect:NSMakeRect(point.x, point.y, [stringToInsert size].width, [stringToInsert size].height)];
		
		
		[stringToInsert drawAtPoint:point];
		[secondImage unlockFocus];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"SWRefresh" object:nil];
		[NSApp sendAction:@selector(refreshImage:)
					   to:nil
					 from:self];
	} else if (event == MOUSE_DOWN) {
		aPoint = point;
		if (canInsert) {
			// This loop removes all the representations in the overlay image, effectively clearing it
			for (NSImageRep *rep in [secondImage representations]) {
				[secondImage removeRepresentation:rep];
			}
			[NSApp sendAction:@selector(prepUndo:)
						   to:nil
						 from:nil];
			[anImage lockFocus];
			[stringToInsert drawAtPoint:point];
			[anImage unlockFocus];
			canInsert = NO;
			stringToInsert = @"";
			//[[NSNotificationCenter defaultCenter] postNotificationName:@"SWRefresh" object:nil];
			[NSApp sendAction:@selector(refreshImage:)
						   to:nil
						 from:nil];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SWText" object:frontColor];
			canInsert = YES;
		} 
	}
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
	if (![stringToInsert isEqualTo:@""]) {
		[self performDrawAtPoint:point withMainImage:_anImage secondImage:_secondImage mouseEvent:MOUSE_DRAGGED];		
	}
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	stringToInsert = @"";
	canInsert = NO;
}

- (NSString *)name
{
	return @"Text";
}

- (NSCursor *)cursor
{
	return [NSCursor IBeamCursor];
}

- (BOOL)shouldShowFillOptions
{
	return NO;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
