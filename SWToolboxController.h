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
#import "SWToolList.h"
#import "SWColorWell.h"

@interface SWToolboxController : NSWindowController {
	
	IBOutlet SWColorWell *foregroundColorWell;
	IBOutlet SWColorWell *backgroundColorWell;
	IBOutlet NSMatrix *toolMatrix;
	IBOutlet NSMatrix *fillMatrix;
	IBOutlet NSMatrix *selectionMatrix;
	IBOutlet NSSlider *lineSlider;
	NSColor *foregroundColor;
	NSColor *backgroundColor;
	SWTool *currentTool;
	NSInteger lineWidth;
	BOOL shouldFill;
	BOOL shouldStroke;
	NSMutableDictionary *toolList;
}

+ (id)sharedToolboxPanelController;

// Accessors
- (SWTool *)currentTool;
- (NSColor *)foregroundColor;
- (NSColor *)backgroundColor;
- (NSInteger)lineWidth;
- (SWColorWell *)foregroundColorWell;
- (SWColorWell *)backgroundColorWell;

// Mutators
- (IBAction)changeForegroundColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeTool:(id)sender;
- (IBAction)changeFill:(id)sender;
- (IBAction)changeLineWidth:(id)sender;

// Other stuff
- (void)switchToScissors:(id)sender;
- (BOOL)shouldOmitBackground;
- (IBAction)showWindow:(id)sender;
- (IBAction)hideWindow:(id)sender;
- (IBAction)flipColors:(id)sender;


@end
