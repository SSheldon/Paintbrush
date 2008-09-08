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


#import "SWSizeWindowController.h"
#import "SWDocument.h"

@implementation SWSizeWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"SizeWindow"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChange:)
												 name:NSControlTextDidChangeNotification
											   object:nil];
	return self;
}

- (void)awakeFromNib
{
	// Read the defaults for width and height
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber *width = [defaults objectForKey:@"HorizontalSize"];
	NSNumber *height = [defaults objectForKey:@"VerticalSize"];
	[widthField setIntValue:[width integerValue]];
	[heightField setIntValue:[height integerValue]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification 
														object:nil];
}

// If the user changes the size of the image using the NSPopUpButton,
// change the two text fields to stay synchronized with it
- (IBAction)changeSizeButton:(id)sender
{
	if ([sender selectedItem] == clipboard) {
		NSData *data = [SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]];
		if (data) {
			NSImage *temp = [[NSImage alloc] initWithData:data];
			[widthField setIntValue:[temp size].width];
			[heightField setIntValue:[temp size].height];
		}
	} else {
		NSString *newSize = [sizeButton titleOfSelectedItem];
		NSScanner *scanner = [NSScanner scannerWithString:newSize];
		NSInteger width, height;
		
		// Parse the string to decide on a width and height
		if ([scanner scanInteger:&width] && [scanner scanString:@"x" intoString:NULL] && [scanner scanInteger:&height]) {
			//NSLog(@"%d %d", width, height);
			[widthField setIntValue:width];
			[heightField setIntValue:height];
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (menuItem == clipboard) {
		return ([SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);
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

	NSString *string = [NSString stringWithFormat:@"%d x %d", width, height];
	for (NSMenuItem *item in [sizeButton itemArray]) {
		if ([[item title] isEqualTo:string]) {
			[sizeButton selectItem:item];
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
	if ([[sender title] isEqualTo:@"OK"]){
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

- (BOOL)scales
{
	return scales;
}

- (void)setScales:(BOOL)s
{
	scales = s;
}


@end
