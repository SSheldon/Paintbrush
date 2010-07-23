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


#import "SWTextToolWindowController.h"
#import "SWToolbox.h"
#import "SWTool.h"
#import "SWDocument.h"

@implementation SWTextToolWindowController

- (id)initWithDocument:(SWDocument *)doc
{
	self = [super initWithWindowNibName:@"TextEntry"];
	document = doc;
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
	NSAttributedString *attrString = [[[NSAttributedString alloc] initWithAttributedString:
									  [textView attributedSubstringFromRange:range]] autorelease];
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
	if (document)
		[[document toolbox] tieUpLooseEndsForCurrentTool];
}

//- (void)dealloc
//{
//	[textView release];
//	[super dealloc];
//}

@end
