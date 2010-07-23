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


#import "SWAppController.h"
#import "SWSizeWindowController.h"
#import "SWPreferenceController.h"
#import "SWToolboxController.h"
#import "SWDocument.h"
#import <Sparkle/Sparkle.h>

NSString * const kSWUndoKey = @"UndoLevels";

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
						@"OK", nil, nil, [[[NSProcessInfo alloc] operatingSystemVersionString] autorelease]);
		DebugLog(@"Failed to run: running version %lf", NSAppKitVersionNumber);
		// then quit the program
		[NSApp terminate:self]; 
		
	} else if (self = [super init]) {
		
		// Create a dictionary
		NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
		// Put initial defaults in the dictionary
		[defaultValues setObject:[NSNumber numberWithInt:640] forKey:@"HorizontalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:480] forKey:@"VerticalSize"];
		[defaultValues setObject:[NSNumber numberWithInt:10] forKey:kSWUndoKey];
		[defaultValues setObject:@"PNG" forKey:@"FileType"];
		
		// Register the dictionary of defaults
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];		

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

// Called immediately before relaunching by Sparkle
- (void)updaterWillRelaunchApplication:(SUUpdater *)updater
{
	[self killTheSheet:nil];
}

- (IBAction)quit:(id)sender
{
	[self killTheSheet:nil];
	[NSApp terminate:self];
}

// Creates a new instance of SWDocument based on the image in the clipboard
- (IBAction)newFromClipboard:(id)sender
{
	NSData *data = [SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]];
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
		return ([SWImageTools readImageFromPasteboard:[NSPasteboard generalPasteboard]] != nil);

	}
	return YES;
}


#pragma mark URLS to web pages/email addresses

////////////////////////////////////////////////////////////////////////////////
//////////		URLs to web pages/email addresses
////////////////////////////////////////////////////////////////////////////////


- (IBAction)donate:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:
												   @"http://sourceforge.net/project/project_donations.php?group_id=191288"]];
}

- (IBAction)forums:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/forum/?group_id=191288"]];
	
}

- (IBAction)contact:(id)sender
{	
	// Open the URL
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:soggywaffles@gmail.com"]];
}

- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}

@end
