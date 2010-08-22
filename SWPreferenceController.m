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


#import "SWPreferenceController.h"
#import "SWAppController.h"
#import "SWDocument.h"

@implementation SWPreferenceController

- (id)init
{
	if (self = [super initWithWindowNibName:@"Preferences"]) {
	}
 	return self;
}

- (void)awakeFromNib
{
	NSArray *fileTypes = [SWDocument writableTypes];
	for (NSString *type in fileTypes)
		[fileTypeButton addItemWithTitle:type];
	
	NSToolbar *toolbar = [[self window] toolbar];
	[toolbar setSelectedItemIdentifier:[[[toolbar items] objectAtIndex:0] itemIdentifier]];
	
	// Set the initial preference view
	[[self window] setContentSize:[generalPrefsView frame].size];
	[[[self window] contentView] addSubview:generalPrefsView];
	[[self window] setTitle:NSLocalizedString(@"General", @"Preferences window: general prefs")];
	currentViewTag = 0;
	//[[[self window] contentView] setWantsLayer:YES];
}

- (void)windowDidLoad
{
	// Load current defaults into the various fields
	[undoStepper setIntValue:[[[NSUserDefaults standardUserDefaults] valueForKey:kSWUndoKey] integerValue]];
	[undoTextField setIntValue:[[[NSUserDefaults standardUserDefaults] valueForKey:kSWUndoKey] integerValue]];
	[fileTypeButton selectItemWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"FileType"]];
}

// Sets the default fileType for new documents (can always be set in the save dialog, however)
- (IBAction)changeFileType:(id)sender {
	[[NSUserDefaults standardUserDefaults] setValue:[sender titleOfSelectedItem]
											 forKey:@"FileType"];
}


- (IBAction)changeUndoLimit:(id)sender {
	if ([sender integerValue] == 0) {
		[undoStepper setIntegerValue:0];
		[undoTextField setIntegerValue:0];
	} else if ([sender integerValue] < 0) {
		NSBeep();
		[undoStepper setIntegerValue:0];
		[undoTextField setIntegerValue:0];
	} else {
		[undoStepper setIntegerValue:[sender integerValue]];
		[undoTextField setIntegerValue:[sender integerValue]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[sender integerValue]]
											  forKey:kSWUndoKey];
	
	// Post a notification that the level has changed
	[[NSNotificationCenter defaultCenter] postNotificationName:kSWUndoKey 
														object:[NSNumber numberWithInteger:[sender integerValue]]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == undoTextField) {
		[self changeUndoLimit:[aNotification object]];
	}
}


////////////////////////////////////////////////////////////////////////////////
//////////		Things for the toolbar at the top
////////////////////////////////////////////////////////////////////////////////


- (void)viewForTag:(int)tag view:(NSView **)view title:(NSString **)title
{
	switch (tag) {
		case 0:
			*view = generalPrefsView;
			*title = NSLocalizedString(@"General", @"Preferences window: general prefs");
			break;
		case 1:
			*view = advancedPrefsView;
			*title = NSLocalizedString(@"Advanced", @"Preferences window: advanced prefs");
			break;
		default:
			break;
	}
}

- (NSRect)newFrameForNewContentView:(NSView *)view
{
	NSRect newFrameRect = [[self window] frameRectForContentRect:[view frame]];
	NSRect oldFrameRect = [[self window] frame];
	NSSize newSize = newFrameRect.size;
	NSSize oldSize = oldFrameRect.size;
	NSRect frame = [[self window] frame];
	frame.size = newSize;
	frame.origin.y = frame.origin.y - (newSize.height - oldSize.height);
	return frame;
}

- (IBAction)selectPrefPane:(id)sender
{
	NSInteger tag = [sender tag];
	NSView *view;
	NSString *title;
	[self viewForTag:tag view:&view title:&title];
	[[self window] setTitle:title];

	NSView *previousView;
	[self viewForTag:currentViewTag view:&previousView title:&title];
	currentViewTag = tag;
	NSRect newFrame = [self newFrameForNewContentView:view];
	
	// With Core Animation
//	[NSAnimationContext beginGrouping];
//	[[[self window] animator] setFrame:newFrame display:YES];
//	[[[[self window] contentView] animator] replaceSubview:previousView with:view];
//	[NSAnimationContext endGrouping];
	
	// Without Core Animation
	[previousView removeFromSuperview];
	[[self window] setFrame:newFrame display:YES animate:YES];
	[[[self window] contentView] addSubview:view];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	NSMutableArray *selectable = [[NSMutableArray alloc] initWithCapacity:[[toolbar items] count]];
	for (NSToolbarItem *nsti in [toolbar items]) 
	{
		[selectable addObject:[nsti itemIdentifier]];
	}
	return selectable;
}


@end
