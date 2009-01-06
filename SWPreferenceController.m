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


#import "SWPreferenceController.h"
#import "SWAppController.h"

@implementation SWPreferenceController

- (id)init
{
	if (self = [super initWithWindowNibName:@"Preferences"]) {
	}
 	return self;
}

- (void)awakeFromNib
{
	[fileTypeButton addItemWithTitle:@"PNG"];
	[fileTypeButton addItemWithTitle:@"JPEG"];
	[fileTypeButton addItemWithTitle:@"GIF"];
	[fileTypeButton addItemWithTitle:@"BMP"];
	[fileTypeButton addItemWithTitle:@"TIFF"];
	
	NSToolbar *toolbar = [[self window] toolbar];
	[toolbar setSelectedItemIdentifier:[[[toolbar items] objectAtIndex:0] itemIdentifier]];
	
	// Set the initial preference view
	[[self window] setContentSize:[generalPrefsView frame].size];
	[[[self window] contentView] addSubview:generalPrefsView];
	[[self window] setTitle:@"General"];
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

// Sets the default filetype for new documents (can always be set in the save dialog, however
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
//	NSLog(@"Spin the spinner! %d", [sender integerValue]);
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
			*title = @"General";
			break;
		case 1:
			*view = advancedPrefsView;
			*title = @"Advanced";
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
	NSMutableArray *selectable = [NSMutableArray new];
	for (NSToolbarItem *nsti in [toolbar items]) {
		[selectable addObject:[nsti itemIdentifier]];
	}
	return selectable;
}


@end
