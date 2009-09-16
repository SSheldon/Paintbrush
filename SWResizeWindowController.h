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


#import <Cocoa/Cocoa.h>


typedef enum {
	PERCENT = 0,
	PIXELS = 1
} SWUnit;


@interface SWResizeWindowController : NSWindowController {	
	IBOutlet NSTextField *heightFieldNew;
	IBOutlet NSTextField *widthFieldNew;
	
	IBOutlet NSTextField *heightFieldOriginal;
	IBOutlet NSTextField *widthFieldOriginal;
	
	IBOutlet NSPopUpButton *heightUnits;
	IBOutlet NSPopUpButton *widthUnits;
	
	// Store the original size for a moment
	NSSize originalSize;
	
	// Don't forget about the new size!
	NSSize newSize;
	
	// Percent or pixels?
	SWUnit selectedUnit;
	
	BOOL scales;
}


// OK or Cancel
- (IBAction)endSheet:(id)sender;

// Changing the units of measurement
- (IBAction)changeUnits:(id)sender;

// A few accessors and mutators
- (NSInteger)width;
- (NSInteger)height;
- (void)setCurrentSize:(NSSize)currSize;
- (BOOL)scales;
- (void)setScales:(BOOL)s;

@property (assign) SWUnit selectedUnit;

@end
