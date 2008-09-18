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


#import "SWAppController.h"
#import "SWSizeWindowController.h"
#import "SWPreferenceController.h"
#import "SWToolboxController.h"
#import "SWDocument.h"

@implementation SWAppController


- (id)init
{
	// Leopard's AppKit version is ≥ 949, while older versions of the OS hae a lower number. This 
	// program requires 10.5 or higher, so this checks to make sure. I'm sure there's an easier
	// way to do this, but whatever - this works fine

	// NOTE: 10.5.3 is version 949.33
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		// Pop up a warning dialog... 
		NSRunAlertPanel(@"Sorry, this program requires Mac OS X 10.5.3 or later", @"You are running %@", 
						@"OK", nil, nil, [[NSProcessInfo alloc] operatingSystemVersionString]);
		NSLog(@"%lf", NSAppKitVersionNumber);
		// then quit the program
		[NSApp terminate:self]; 
		
	} else if (self = [super init]) {
		
		// Create a dictionary
		NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
		// Put initial defaults in the dictionary
		[defaultValues setObject:[NSNumber numberWithInt:640] forKey:@"HorizontalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:480] forKey:@"VerticalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:10] forKey:@"UndoLevels"];
		[defaultValues setObject:@"PNG" forKey:@"FileType"];
		
		// Register the dictionary of defaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(killTheSheet:) 
													 name:SUUpdaterWillRestartNotification 
												   object:nil];

		[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
		[NSColorPanel setPickerMode:NSCrayonModeColorPanel];
		[[SWToolboxController sharedToolboxPanelController] showWindow:self];
	}
	
	return self;
}

// Makes the toolbox panel appear and disappear
- (IBAction)showToolboxPanel:(id)sender
{
	SWToolboxController *toolboxPanel = [SWToolboxController sharedToolboxPanelController];
	if ([[toolboxPanel window] isVisible]) {
		[toolboxPanel close];
	} else {
		[toolboxPanel showWindow:self];
	}
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (!preferenceController) {
		preferenceController = [[SWPreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}

- (void)killTheSheet:(id)sender
{
	for (NSWindow *window in [NSApp windows]) {
		if ([window isSheet] && [[[window windowController] class] isEqualTo:[SWSizeWindowController class]]) {
			// Close all the size sheets, but no other ones
			[window close];
			//[NSApp endSheet:window returnCode:NSCancelButton];
		}
	}
}

- (IBAction)quit:(id)sender
{
	[self killTheSheet:nil];
	[NSApp terminate:self];
}

// Creates a new instance of SWDocument based on the image in the clipboard
- (IBAction)newFromClipboard:(id)sender
{
	NSData *data = [SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]];
	if (data) {
		[SWDocument setWillShowSheet:NO];
		[NSApp sendAction:@selector(newDocument:)
					   to:nil 
					 from:self];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if (action == @selector(newFromClipboard:)) {
		return ([SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);

	}
	return YES;
}


#pragma mark URLS to web pages/email addresses

////////////////////////////////////////////////////////////////////////////////
//////////		URLs to web pages/email addresses
////////////////////////////////////////////////////////////////////////////////


- (IBAction)donate:(id)sender
{	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:
												   @"http://sourceforge.net/project/project_donations.php?group_id=191288"]];
}

- (IBAction)forums:(id)sender
{	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/forum/?group_id=191288"]];
	
}

- (IBAction)contact:(id)sender
{	
	// Open the URL.
	(void) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:soggywaffles@gmail.com"]];
}

- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}

@end
