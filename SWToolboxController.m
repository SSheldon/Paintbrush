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


#import "SWToolboxController.h"
#import "SWToolbox.h"
#import "SWToolList.h"
#import "SWColorSelector.h"
#import "SWDocument.h"

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
@synthesize activeDocument;
//@synthesize toolListArray;


// Curiosity...!
- (void)windowDidBecomeKey:(NSNotification *)notification
{
	NSWindow *window = [notification object];

	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	id document = [controller documentForWindow:window];
	if (document && [document class] == [SWDocument class]) {
        activeDocument = document;
		DebugLog(@"Key window is %@", document);		
	}
}


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
		// Curiosity...
		[[NSNotificationCenter defaultCenter] addObserver:self
			   selector:@selector(windowDidBecomeKey:)
				   name:NSWindowDidBecomeKeyNotification
				 object:nil];
		
	
		// Do some other initialization stuff
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		[NSBezierPath setDefaultLineJoinStyle:NSRoundLineJoinStyle];
		[NSBezierPath setDefaultWindingRule:NSEvenOddWindingRule];
	}
	
	return self;
}


// Alert the observers that something's going on
- (void)awakeFromNib
{	
	// Mah toolbox!  MINE!
	toolbox = [[SWToolbox alloc] initWithDocument:nil];
	
	// Set the starting toolbox info
	[self setLineWidthDisplay:3];
	[self setForegroundColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[self setFillStyle:STROKE_ONLY];
	[self setSelectionTransparency:NO];
	[self changeCurrentTool:toolMatrix];	
}


// Called externally at times
- (void)updateInfo
{
	[self setLineWidthDisplay:[self lineWidthDisplay]];
	[self setForegroundColor:[self foregroundColor]];
	[self setBackgroundColor:[self backgroundColor]];
	[self setFillStyle:[self fillStyle]];
	[self setSelectionTransparency:[self selectionTransparency]];
	[self changeCurrentTool:toolMatrix];	
}


// The slider moved, meaning the line width should change
- (void)setLineWidth:(NSInteger)width
{
	// Allows for more line widths with less tick marks
	lineWidth = 2*width - 2;

	//[currentTool setLineWidth:lineWidth];
}


- (void)setLineWidthDisplay:(NSInteger)width
{
	[self setLineWidth:width];
}


- (NSInteger)lineWidthDisplay
{
	return (1+lineWidth) / 2 + 1;
}


- (void)setCurrentTool:(NSString *)tool
{
	// Don't tie up loose ends if there's no tool!
	currentTool = tool;
	
	SWTool *tempTool = [toolbox toolForLabel:currentTool];
		
	[fillMatrix setHidden:(![tempTool shouldShowFillOptions])];
	[transparencyMatrix setHidden:(![tempTool shouldShowTransparencyOptions])];
	
	// Handle resizing of tool palette, based on which tool is selected
	NSRect aRect = [[super window] frame];
	if ([tempTool shouldShowFillOptions] || [tempTool shouldShowTransparencyOptions]) {
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
	// At the moment, most of the keyboard shortcuts are set in Interface Builder
	NSUInteger modifiers = [event modifierFlags];
	
	if (modifiers & NSAlternateKeyMask) {
		// They held option
		if ([event keyCode] == 125) {
			// They pressed down
			[self setLineWidthDisplay:fmax([self lineWidthDisplay]-1,1)];
		} else if ([event keyCode] == 126) {
			// They pressed up
			[self setLineWidthDisplay:[self lineWidthDisplay]+1];
		}
	} else {
		// Check the letter pressed
		NSString *string = [[event characters] lowercaseString];
		
		switch([string characterAtIndex:0]) {
			case 'a':
				DebugLog(@"AAA");
				break;
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


// We use the title of the cell to indicate which tool to use
//TODO: Make this localization-friendly
- (IBAction)changeCurrentTool:(id)sender
{
	NSString *string = [[sender selectedCell] title];
	if (string && ![string isEqualToString:@""])
		[self setCurrentTool:string];
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
	for (NSCell *cell in [toolMatrix cells])
	{
		if ([[cell title] isEqualToString:@"Selection"])
		{
			[toolMatrix selectCell:cell];
			[self changeCurrentTool:toolMatrix];
			break;
		}
	}
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[toolbox release];
	[super dealloc];
}

@end
