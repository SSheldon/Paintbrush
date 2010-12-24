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


#import "SWTextTool.h"
#import "SWDocument.h"
#import "SWPaintView.h"

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
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{
	_mainImage = mainImage;
	_bufferImage = bufferImage;
	
	[SWImageTools clearImage:bufferImage];
	if (canInsert) 
	{
		if (event == MOUSE_MOVED)
			drawToMe = bufferImage;
		else if (event == MOUSE_DOWN)
		{
			// We're about to draw, so prep an undo
			[document handleUndoWithImageData:nil frame:NSZeroRect];

			drawToMe = mainImage;
			canInsert = NO;
		}
		else
			return nil; // Return in all other cases
		
		// The size of the string, as a guesstimate
		NSSize textSize = [stringToInsert size];
		
		// Assign the redrawRect based on the string's size and the insertion point
		NSRect rect = [stringToInsert boundingRectWithSize:[stringToInsert size] 
												   options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics];
		
		CGFloat xOffset = abs(rect.origin.x);
		CGFloat yOffset = abs(rect.origin.y);
		rect.size.width += xOffset + textSize.width;
		rect.size.height += yOffset + textSize.height;
		
		// Shift it
		rect.origin = NSMakePoint(floorf(point.x), floorf(point.y));
		rect.origin.y -= rect.size.height;
		rect.origin.y += yOffset;

		[super addRectToRedrawRect:rect];
		rect.origin.x += xOffset;

		// Fix the origin, since we're dealing with flipped stuff
		rect.origin.y = [drawToMe pixelsHigh] - rect.origin.y - rect.size.height;
		
		SWLockFocus(drawToMe);
		NSAffineTransform *transform = [NSAffineTransform transform];			
		// Create the transform
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform translateXBy:0 yBy:(0-[drawToMe pixelsHigh])];
		[transform concat];
		[stringToInsert drawAtPoint:rect.origin];
		[NSGraphicsContext restoreGraphicsState];
		SWUnlockFocus(drawToMe);
		
		[NSApp sendAction:@selector(refreshImage:)
					   to:nil
					 from:self];
	}
	else if (event == MOUSE_DOWN) 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SWText" object:frontColor];
		canInsert = YES;
	}
	return nil;
}

// Summoned by the NSNotificationCenter when the user clicks "OK" in the sheet
- (void)insertText:(NSNotification *)note
{
	[stringToInsert release];
	stringToInsert = [[NSAttributedString alloc] initWithAttributedString:[[note userInfo] objectForKey:@"newText"]];
	
	// Get the current point and then draw it
	// Doesn't work quite right yet
//	NSPoint point = [[document paintView] currentMouseLocation];
//	[self mouseHasMoved:point];
	
	[NSApp sendAction:@selector(refreshImage:)
				   to:nil
				 from:nil];
}

// Overridden for drawing to the buffer image
- (void)mouseHasMoved:(NSPoint)point
{
	if (stringToInsert) 
	{
		[self performDrawAtPoint:point withMainImage:_mainImage bufferImage:_bufferImage mouseEvent:MOUSE_MOVED];		
	}
}

- (void)tieUpLooseEnds
{
	[stringToInsert release];
	stringToInsert = nil;
	canInsert = NO;
	
	[super tieUpLooseEnds];
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		customCursor = [[NSCursor IBeamCursor] retain];
	}
	return customCursor;
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
	[stringToInsert release];
	[super dealloc];
}

@end
