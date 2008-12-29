/**
 * Copyright 2007-2009 Soggy Waffles
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



#import "SWTextToolWindowController.h"
#import "SWToolboxController.h"
#import "SWTool.h"

@implementation SWTextToolWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"TextEntry"];
	return self;
}

- (void)awakeFromNib
{
	[textView setFont:[NSFont fontWithName:@"Helvetica" size:16.0]];
	[textView selectAll:textView];
}

// When the user clicks "OK"
- (IBAction)enterText:(id)sender
{
	NSRange range;
	range.length = [[textView string] length];
	range.location = 0;
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithAttributedString:
									  [textView attributedSubstringFromRange:range]];
	NSDictionary *d = [NSDictionary dictionaryWithObject:attrString forKey:@"newText"];
	NSNotification *n = [NSNotification notificationWithName:@"SWTextEntered"
													  object:self
													userInfo:d];
	
	// Notify the text tool that I have clicked OK
	[[NSNotificationCenter defaultCenter] postNotification:n];
	[textView selectAll:textView];
	[self close];
	[NSApp endSheet:[self window]];
}

// A cancel click calls this method
- (IBAction)cancel:(id)sender
{
	[textView selectAll:textView];
	[self close];
	[NSApp endSheet:[self window]];
	SWTool *currentTool = [[SWToolboxController sharedToolboxPanelController] currentTool];
	[currentTool tieUpLooseEnds];
}

- (void)dealloc
{
	[textView release];
	[super dealloc];
}

@end
