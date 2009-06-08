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
	STROKE_ONLY,
	FILL_ONLY,
	FILL_AND_STROKE
} SWFillStyle;

@class SWColorSelector;
@class SWTool;

@interface SWToolboxController : NSWindowController {	
	NSColor *foregroundColor;
	NSColor *backgroundColor;
	SWTool *currentTool;
	NSInteger lineWidth;
	SWFillStyle fillStyle;
	BOOL selectionTransparency;
	NSMutableDictionary *toolList;
	NSMutableArray *toolListArray;
	
	//IBOutlet SWColorSelector *colorSel;
}

// Accessors
+ (id)sharedToolboxPanelController;

// Mutators
- (IBAction)changeCurrentTool:(id)sender;
- (IBAction)changeFillStyle:(id)sender;
- (IBAction)changeSelectionTransparency:(id)sender;

// Other stuff
- (void)switchToScissors:(id)sender;
- (IBAction)flipColors:(id)sender;

@property (assign) NSInteger lineWidthDisplay;
@property (assign) NSInteger lineWidth;
@property (assign) BOOL selectionTransparency;
@property (assign) SWTool *currentTool;
@property (assign) SWFillStyle fillStyle;
@property (retain) NSColor *foregroundColor;
@property (retain) NSColor *backgroundColor;
@property (readonly) NSMutableArray *toolListArray;

@end
