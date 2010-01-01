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


#import "SWResizeWindowController.h"
#import "SWDocument.h"

@implementation SWResizeWindowController

@synthesize selectedUnit;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


// Each time the user types in the width or height field, check to see if it's
// one of the preset values in the popup button
- (void)textDidChange:(NSNotification *)aNotification
{
	NSInteger width, height;
	switch (selectedUnit) {
		case PERCENT:
			width = [widthFieldNew integerValue] * originalSize.width / 100;
			height = [heightFieldNew integerValue] * originalSize.height / 100;
			break;
		case PIXELS:
			width = [widthFieldNew integerValue];
			height = [heightFieldNew integerValue];
			break;
		default:
			DebugLog(@"Error!  The selected units are wrong!");
			return;
	}
	
	newSize = NSMakeSize(width, height);
}


- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSControlTextDidChangeNotification
											   object:nil];
	
	[heightFieldOriginal setIntegerValue:originalSize.height];
	[widthFieldOriginal setIntegerValue:originalSize.width];
	
	newSize = originalSize;
	
	switch (selectedUnit) {
		case PERCENT:
			[widthFieldNew setIntegerValue:100];
			[heightFieldNew setIntegerValue:100];
			break;
		case PIXELS:
			[widthFieldNew setIntegerValue:newSize.width];
			[heightFieldNew setIntegerValue:newSize.height];
			break;
		default:
			break;
	}
}


// Convert between percentage and pixels
- (IBAction)changeUnits:(id)sender
{
	switch (selectedUnit) {
		case PERCENT:
			[widthFieldNew setIntegerValue:(100 * newSize.width / originalSize.width)];
			[heightFieldNew setIntegerValue:(100 * newSize.height / originalSize.height)];
			break;
		case PIXELS:
			[widthFieldNew setIntegerValue:newSize.width];
			[heightFieldNew setIntegerValue:newSize.height];
			break;
		default:
			break;
	}
}


// After they click OK or Cancel
- (IBAction)endSheet:(id)sender
{
	if ([sender tag] == NSOKButton) {
		if ([widthFieldNew integerValue] > 0 && [heightFieldNew integerValue] > 0) {
			
			// Save entered values as defaults
//			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//			NSNumber *width = [NSNumber numberWithInt:[widthFieldNew integerValue]];
//			NSNumber *height = [NSNumber numberWithInt:[heightFieldNew integerValue]];
//			[defaults setObject:width forKey:@"HorizontalSize"];
//			[defaults setObject:height forKey:@"VerticalSize"];
			
			[[self window] orderOut:sender];
			[NSApp endSheet:[self window] returnCode:NSOKButton];
		} else {
			NSBeep();
		}
	} else {
		// They clicked cancel
		[[self window] orderOut:sender];
		[NSApp endSheet:[self window] returnCode:NSCancelButton];
	}	
}

- (NSInteger)width
{
	return newSize.width;
}

- (NSInteger)height
{
	return newSize.height;
}

- (void)setCurrentSize:(NSSize)currSize
{
	originalSize = currSize;
}

- (BOOL)scales
{
	return scales;
}

- (void)setScales:(BOOL)s
{
	scales = s;
}


@end
