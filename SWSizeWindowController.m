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


#import "SWSizeWindowController.h"
#import "SWDocument.h"


static NSString *sizeMenuLabels[] = { @"640_480", @"800_600", @"1024_768", @"1280_1024" };
static NSUInteger sizeMenuWidths[] = { 640, 800, 1024, 1280 };
static NSUInteger sizeMenuHeights[] = { 480, 600, 768, 1024 };
static NSUInteger numItems = sizeof(sizeMenuLabels) / sizeof(sizeMenuLabels[0]); // How many size menu items are there?
static NSUInteger sizeOffset = 3; // How many non-size menu items are there?


@implementation SWSizeWindowController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


- (void)windowDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSControlTextDidChangeNotification
											   object:nil];
	
	// Read the defaults for width and height
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber *width = [defaults objectForKey:@"HorizontalSize"];
	NSNumber *height = [defaults objectForKey:@"VerticalSize"];
	[widthField setIntValue:[width integerValue]];
	[heightField setIntValue:[height integerValue]];
	
	// Populate the sizeButton
	[sizeButton removeAllItems];
	
	// Add the custom items to the popup
	NSMenu *buttonMenu = [sizeButton menu];
	clipboard = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"From Clipboard", @"Size of the image copied to the clipboard")
										   action:@selector(changeSizeButton:)
									keyEquivalent:@""];
	[buttonMenu addItem:clipboard];
	[buttonMenu addItemWithTitle:NSLocalizedString(@"Custom", @"Custom size")
						  action:@selector(changeSizeButton:)
				   keyEquivalent:@""];
	[buttonMenu addItem:[NSMenuItem separatorItem]];
	
	// Add the zoom levels
	NSUInteger cnt;
	for (cnt = 0; cnt < numItems; cnt++) {
		[buttonMenu addItemWithTitle:NSLocalizedString(sizeMenuLabels[cnt], nil)
							  action:@selector(changeSizeButton:)
					   keyEquivalent:@""];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification 
														object:nil];
}


// If the user changes the size of the image using the NSPopUpButton,
// change the two text fields to stay synchronized with it
- (IBAction)changeSizeButton:(id)sender
{
	if ([sizeButton selectedItem] == clipboard) {
		NSData *data = [SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]];
		if (data) {
			NSBitmapImageRep *temp = [[NSBitmapImageRep alloc] initWithData:data];
			[widthField setIntValue:[temp size].width];
			[heightField setIntValue:[temp size].height];
			[temp release];
		}
	} else {
		NSInteger index = [sizeButton indexOfSelectedItem];
		if (index >= sizeOffset) {
			// The user selected one of the size presets
			index -= sizeOffset;
			[widthField setIntValue:sizeMenuWidths[index]];
			[heightField setIntValue:sizeMenuHeights[index]];
		}
	}
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (menuItem == clipboard) {
		return ([SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);
	}
	return YES;
}


// Each time the user types in the width or height field, check to see if it's
// one of the preset values in the popup button
- (void)textDidChange:(NSNotification *)aNotification
{
	NSInteger width = [widthField integerValue];
	NSInteger height = [heightField integerValue];
	BOOL isFound = NO;
	
	NSUInteger cnt;
	for (cnt = 0; cnt < numItems; cnt++) {
		if (width == sizeMenuWidths[cnt] && height == sizeMenuHeights[cnt]) {
			[sizeButton selectItemAtIndex:(cnt+sizeOffset)];
			isFound = YES;
			break;
		}
	}
	
	if (!isFound) {
		[sizeButton selectItemWithTitle:@"Custom"];
	}
}


// After they click OK or Cancel
- (IBAction)endSheet:(id)sender
{
	if ([sender tag] == NSOKButton) {
		if ([widthField integerValue] > 0 && [heightField integerValue] > 0) {
			
			// Save entered values as defaults
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSNumber *width = [NSNumber numberWithInt:[widthField integerValue]];
			NSNumber *height = [NSNumber numberWithInt:[heightField integerValue]];
			[defaults setObject:width forKey:@"HorizontalSize"];
			[defaults setObject:height forKey:@"VerticalSize"];
			
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
	return [widthField integerValue];
}


- (NSInteger)height
{
	return [heightField integerValue];
}


- (void)setWidth:(NSInteger)newWidth
{
	[widthField setIntegerValue:newWidth];
}


- (void)setHeight:(NSInteger)newHeight
{
	[heightField setIntegerValue:newHeight];
}


@end
