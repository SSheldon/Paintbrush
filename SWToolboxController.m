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


#import "SWToolboxController.h"
#import "SWToolList.h"
#import "SWColorWell.h"

// Heights for the panel, based on what is shown
#define LARGE_HEIGHT 467
#define SMALL_HEIGHT 367

@implementation SWToolboxController

@synthesize lineWidth;
@synthesize selectionTransparency;
@synthesize currentTool;
@synthesize fillStyle;
@synthesize foregroundColor;
@synthesize backgroundColor;

+ (id)sharedToolboxPanelController
{
	// By calling it static, a second instance of the pointer will never be created
	static SWToolboxController *sharedController;
	
	if (!sharedController) {
		sharedController = [[SWToolboxController alloc] initWithWindowNibName:@"Toolbox"];
	}
	
	return sharedController;
}

// Override the initializer
- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName]) {		
		// Lots o' tools
		toolList = [[NSMutableDictionary alloc] init];
		[toolList setObject:[[SWPencilTool alloc] initWithController:self] forKey:@"Pencil"];
		[toolList setObject:[[SWRectangleTool alloc] initWithController:self] forKey:@"Rectangle"];
		[toolList setObject:[[SWRoundedRectangleTool alloc] initWithController:self] forKey:@"RoundedRectangle"];
		[toolList setObject:[[SWEllipseTool alloc] initWithController:self] forKey:@"Ellipse"];
		[toolList setObject:[[SWLineTool alloc] initWithController:self] forKey:@"Line"];
		[toolList setObject:[[SWCurveTool alloc] initWithController:self] forKey:@"Curve"];
		[toolList setObject:[[SWEraserTool alloc] initWithController:self] forKey:@"Eraser"];
		[toolList setObject:[[SWFillTool alloc] initWithController:self] forKey:@"Fill"];
		[toolList setObject:[[SWSelectionTool alloc] initWithController:self] forKey:@"Selection"];
		[toolList setObject:[[SWTextTool alloc] initWithController:self] forKey:@"Text"];
		[toolList setObject:[[SWBombTool alloc] initWithController:self] forKey:@"Bomb"];
		[toolList setObject:[[SWEyeDropperTool alloc] initWithController:self] forKey:@"EyeDropper"];
		[toolList setObject:[[SWZoomTool alloc] initWithController:self] forKey:@"Zoom"];
		[toolList setObject:[[SWAirbrushTool alloc] initWithController:self] forKey:@"Airbrush"];
				
	}
	
	return self;
}

// Alert the observers that something's going on
- (void)awakeFromNib
{
	[self setCurrentTool:[toolList objectForKey:@"Pencil"]];
	
	[self setLineWidthDisplay:3];
	[self setForegroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[self setFillStyle:STROKE_ONLY];
	[self setSelectionTransparency:NO];
}

// The slider moved, meaning the line width should change
- (void)setLineWidth:(NSInteger)width
{
	// Allows for more line widths with less tick marks
	lineWidth = 2*width - 1;

	[currentTool setLineWidth:lineWidth];
}

- (void)setLineWidthDisplay:(NSInteger)width
{
	[self setLineWidth:width];
}

- (NSInteger)lineWidthDisplay
{
	return (1+lineWidth) / 2;
}

// Override the default to make some additions
- (void)setCurrentTool:(SWTool *)tool
{
	currentTool = tool;
	
	// Handle resizing of tool palette, based on which tool is selected
	NSRect aRect = [[super window] frame];
	if ([currentTool shouldShowFillOptions] || [currentTool shouldShowTransparencyOptions]) {
		aRect.origin.y += (aRect.size.height - LARGE_HEIGHT);
		aRect.size.height = LARGE_HEIGHT;
	} else {
		aRect.origin.y += (aRect.size.height - SMALL_HEIGHT);
		aRect.size.height = SMALL_HEIGHT;
	}
	[[super window] setFrame:aRect display:YES animate:YES];
}

- (void)keyDown:(NSEvent *)event
{
	// At the moment, all the keyboard shortcuts are set in Interface Builder
	NSUInteger modifiers = [event modifierFlags];
	
	if (modifiers & NSAlternateKeyMask) {
		// They held option
		if ([event keyCode] == 125) {
			// They pressed down
			[self setLineWidth:[self lineWidth]-1];
		} else if ([event keyCode] == 126) {
			// They pressed up
			[self setLineWidth:[self lineWidth]+1];
		}
	}
}

// The IBActions we'll need
// Replaces the front color with the back, and vice-versa
- (IBAction)flipColors:(id)sender 
{
	NSColor *tempColor = [foregroundColor copy];
	[self setForegroundColor:backgroundColor];
	[self setBackgroundColor:tempColor];
}

- (IBAction)changeCurrentTool:(id)sender
{
	[currentTool tieUpLooseEnds];
	NSString *string = [[sender selectedCell] title];
	SWTool *theTool = [toolList objectForKey:string];
	[self setCurrentTool:theTool];
}

- (IBAction)changeFillStyle:(id)sender
{
	[self setFillStyle:[sender selectedTag]];
}

- (IBAction)changeSelectionTransparency:(id)sender
{
	[self setSelectionTransparency:[sender selectedTag]];
}

// If "Paste" or "Select All" is chosen, we should switch to the scissors tool
- (void)switchToScissors:(id)sender
{
	[self setCurrentTool:[toolList objectForKey:@"Selection"]];
}

@end