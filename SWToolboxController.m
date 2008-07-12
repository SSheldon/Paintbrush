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

@implementation SWToolboxController

#define LARGE_HEIGHT 467
#define MID_HEIGHT 432
#define SMALL_HEIGHT 367

+ (id)sharedToolboxPanelController {
	// Static ensures that only one will exist
    static SWToolboxController *sharedToolboxPanelController;
	
    if (!sharedToolboxPanelController) {
        sharedToolboxPanelController = [[SWToolboxController allocWithZone:NULL] init];
    }
	
    return sharedToolboxPanelController;
}

- (id)init
{
	if(self = [super initWithWindowNibName:@"Toolbox"]) {
		// Lots o' tools
		toolList = [[NSMutableDictionary alloc] init];
		[toolList setObject:[[SWPencilTool alloc] init] forKey:@"Pencil"];
		[toolList setObject:[[SWRectangleTool alloc] init] forKey:@"Rectangle"];
		[toolList setObject:[[SWRoundedRectangleTool alloc] init] forKey:@"RoundedRectangle"];
		[toolList setObject:[[SWEllipseTool alloc] init] forKey:@"Ellipse"];
		[toolList setObject:[[SWLineTool alloc] init] forKey:@"Line"];
		[toolList setObject:[[SWCurveTool alloc] init] forKey:@"Curve"];
		[toolList setObject:[[SWEraserTool alloc] init] forKey:@"Eraser"];
		[toolList setObject:[[SWFillTool alloc] init] forKey:@"Fill"];
		[toolList setObject:[[SWSelectionTool alloc] init] forKey:@"Selection"];
		[toolList setObject:[[SWTextTool alloc] init] forKey:@"Text"];
		[toolList setObject:[[SWBombTool alloc] init] forKey:@"Bomb"]; // Not currently in use...
		[toolList setObject:[[SWEyeDropperTool alloc] init] forKey:@"EyeDropper"];
		[toolList setObject:[[SWZoomTool alloc] init] forKey:@"Zoom"];
		[toolList setObject:[[SWAirbrushTool alloc] init] forKey:@"Airbrush"];
		
		// It's a panel, not a real window
		[(NSPanel *)[super window] setBecomesKeyOnlyIfNeeded:YES];
	}
	return self;
}

- (void)awakeFromNib
{
	[lineSlider setIntValue:3];
	[self changeLineWidth:lineSlider];
	[self changeForegroundColor:foregroundColorWell];
	[self changeBackgroundColor:backgroundColorWell];
	[self changeTool:toolMatrix];
	[self changeFill:fillMatrix];
	//[[toolMatrix window] setBackgroundColor:[NSColor colorWithDeviceWhite:.85 alpha:1.0]];
}

- (void)windowDidLoad
{
	//NSLog(@"Nib file is loaded"); 
}


////////////////////////////////////////////////////////////////////////////////
//////////		Accessors, aka "Getters"
////////////////////////////////////////////////////////////////////////////////


- (SWTool *)currentTool
{
	return currentTool;
}

- (NSColor *)foregroundColor
{
	return foregroundColor;
}

- (NSColor *)backgroundColor
{
	return backgroundColor;
}

- (int)lineWidth
{
	return lineWidth;
}

- (SWColorWell *)foregroundColorWell
{
	return foregroundColorWell;
}

- (SWColorWell *)backgroundColorWell
{
	return backgroundColorWell;
}


////////////////////////////////////////////////////////////////////////////////
//////////		Tool changing
////////////////////////////////////////////////////////////////////////////////


- (IBAction)changeForegroundColor:(id)sender
{
	foregroundColor = [sender color];

	[currentTool setFrontColor:foregroundColor];
}

- (IBAction)changeBackgroundColor:(id)sender
{
	backgroundColor = [sender color];
	
	[currentTool setBackColor:backgroundColor];
}

// Called whenever one of the buttons in the tool matrix is pressed
- (IBAction)changeTool:(id)sender
{
	[currentTool tieUpLooseEnds];
	currentTool = [toolList objectForKey:[[sender selectedCell] title]];
	
	[currentTool setFrontColor:foregroundColor
					 backColor:backgroundColor
					 lineWidth:2 * [lineSlider intValue] - 1
					shouldFill:shouldFill
				  shouldStroke:shouldStroke];
	
	// Handle resizing of tool palette, based on which tool is selected
	NSRect aRect = [[super window] frame];
	if ([currentTool shouldShowFillOptions]) {
		aRect.origin.y += (aRect.size.height - LARGE_HEIGHT);
		aRect.size.height = LARGE_HEIGHT;

		[[super window] setFrame:aRect display:YES animate:YES];
		
		[[selectionMatrix animator] setHidden:YES];
		[[fillMatrix animator] setHidden:NO];
	} else if ([currentTool isKindOfClass:[SWSelectionTool class]]) {
		// Selection tool
		aRect.origin.y += (aRect.size.height - MID_HEIGHT);
		aRect.size.height = MID_HEIGHT;
		
		[[super window] setFrame:aRect display:YES animate:YES];
		
		[[fillMatrix animator] setHidden:YES];
		[[selectionMatrix animator] setHidden:NO];
	} else {
		aRect.origin.y += (aRect.size.height - SMALL_HEIGHT);
		aRect.size.height = SMALL_HEIGHT;
		
		[[fillMatrix animator] setHidden:YES];
		[[selectionMatrix animator] setHidden:YES];

		[[super window] setFrame:aRect display:YES animate:YES];
	}
}

// The bonus NSMatrix, only for ovals and rectangles
- (IBAction)changeFill:(id)sender
{
	if ([[[fillMatrix selectedCell] title] isEqualToString:@"No Fill"]) {
		shouldFill = NO;
		shouldStroke = YES;
	} else if ([[[fillMatrix selectedCell] title] isEqualToString:@"No Border"]) {
		shouldFill = YES;
		shouldStroke = NO;
	} else {
		shouldFill = YES;
		shouldStroke = YES;
	}
	[currentTool shouldFill:shouldFill stroke:shouldStroke];
}

// The slider moved, meaning the line width should change
- (IBAction)changeLineWidth:(id)sender
{
	// Allows for more line widths with less tick marks
	lineWidth = 2 * [sender intValue] - 1;
	// Let's try exponential growth:
	//lineWidth = ceil(pow([sender intValue], 2) / 2);
	[currentTool setLineWidth:lineWidth];
}


////////////////////////////////////////////////////////////////////////////////
//////////		Other miscellaneous methods
////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldOmitBackground
{
	return ([[[selectionMatrix selectedCell] title] isEqualToString:@"Transparency"]);
}

- (void)keyDown:(NSEvent *)event
{
	// At the moment, all the keyboard shortcuts are set in Interface Builder
	NSUInteger modifiers = [event modifierFlags];
	
	if (modifiers & NSAlternateKeyMask) {
		// They held option
		if ([event keyCode] == 125) {
			// They pressed down
			[lineSlider setFloatValue:[lineSlider floatValue] - 1];
			[self changeLineWidth:lineSlider];
		} else if ([event keyCode] == 126) {
			// They pressed up
			[lineSlider setFloatValue:[lineSlider floatValue] + 1];
			[self changeLineWidth:lineSlider];
		}
	}
}

// If "Paste" or "Select All" is chosen, we should switch to the scissors tool
- (void)switchToScissors:(id)sender
{
	[toolMatrix selectCellWithTag:2];
	[self changeTool:toolMatrix];
}

- (IBAction)showWindow:(id)sender {
	[[self window] orderFront:sender];
	//[[[self window] animator] setAlphaValue:1.0];
}

- (IBAction)hideWindow:(id)sender {
	//[[[self window] animator] setAlphaValue:0.0];
	[[self window] orderOut:sender];
}

// Replaces the front color with the back, and vice-versa
- (IBAction)flipColors:(id)sender {
	[foregroundColorWell setColor:backgroundColor];
	[backgroundColorWell setColor:foregroundColor];
	[self changeForegroundColor:foregroundColorWell];
	[self changeBackgroundColor:backgroundColorWell];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
