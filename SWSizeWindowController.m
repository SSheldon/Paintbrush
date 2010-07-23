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
