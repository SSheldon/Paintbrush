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
