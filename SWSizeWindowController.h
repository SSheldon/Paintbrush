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


#import <Cocoa/Cocoa.h>


@interface SWSizeWindowController : NSWindowController {
	IBOutlet NSPopUpButton *sizeButton;
	IBOutlet NSTextField *heightField;
	IBOutlet NSTextField *widthField;
	
	BOOL scales;
}

// Called whenever the size is manually changed by the user
- (IBAction)changeSizeButton:(id)sender;

// OK or Cancel
- (IBAction)endSheet:(id)sender;

// A few accessors and mutators
- (NSInteger)width;
- (NSInteger)height;
- (BOOL)scales;
- (void)setScales:(BOOL)s;

@end
