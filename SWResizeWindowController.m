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


//- (void)dealloc
//{
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
//	[super dealloc];
//}
//
//
// If the user changes the size of the image using the NSPopUpButton,
// change the two text fields to stay synchronized with it
//
//
//- (IBAction)changeSizeButton:(id)sender
//{
//	if ([sender selectedItem] == clipboard) {
//		NSData *data = [SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]];
//		if (data) {
//			NSBitmapImageRep *temp = [[NSBitmapImageRep alloc] initWithData:data];
//			[widthInputField setIntValue:[temp size].width];
//			[heightInputField setIntValue:[temp size].height];
//			[temp release];
//		}
//	} else {
//		NSString *newSize = [sizeButton titleOfSelectedItem];
//		NSScanner *scanner = [NSScanner scannerWithString:newSize];
//		NSInteger width, height;
//		
//		// Parse the string to decide on a width and height
//		if ([scanner scanInteger:&width] && [scanner scanString:@"x" intoString:NULL] && [scanner scanInteger:&height]) {
//			//NSLog(@"%d %d", width, height);
//			[widthInputField setIntValue:width];
//			[heightInputField setIntValue:height];
//		}
//	}
//}
//
//- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
//{
//	if (menuItem == clipboard) {
//		return ([SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);
//	}
//	return YES;
//}

// Each time the user types in the width or height field, check to see if it's
// one of the preset values in the popup button
//- (void)textDidChange:(NSNotification *)aNotification
//{
//	NSInteger width = [widthInputField integerValue];
//	NSInteger height = [heightInputField integerValue];
//	BOOL isFound = NO;
	
//	NSString *string = [NSString stringWithFormat:@"%d x %d", width, height];
//	for (NSMenuItem *item in [sizeButton itemArray]) {
//		if ([[item title] isEqualTo:string]) {
//			[sizeButton selectItem:item];
//			isFound = YES;
//			break;
//		}
//	}
//	
//	if (!isFound) {
//		[sizeButton selectItemWithTitle:@"Custom"];
//	}
//}


- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[heightFieldOriginal setIntegerValue:originalSize.height];
	[widthFieldOriginal setIntegerValue:originalSize.width];
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
	return [widthFieldNew integerValue];
}

- (NSInteger)height
{
	return [heightFieldNew integerValue];
}

- (void)setWidth:(NSInteger)newWidth
{
	[widthFieldNew setIntegerValue:newWidth];
}

- (void)setHeight:(NSInteger)newHeight
{
	[heightFieldNew setIntegerValue:newHeight];
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
