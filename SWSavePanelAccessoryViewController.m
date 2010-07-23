//
//  SWSavePanelAccessoryViewController.m
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


#import "SWSavePanelAccessoryViewController.h"
#import "SWDocument.h"


NSString * const kSWCurrentFileType = @"currentFileType";

@implementation SWSavePanelAccessoryViewController


@synthesize currentFileType;
@synthesize isAlphaEnabled;
@synthesize imageQuality;


// Overridden to initially populate the popup button
- (void)loadView
{
	[super loadView];
	
	// Use the file types
	NSArray *fileTypes = [SWDocument writableTypes];
	for (NSString *type in fileTypes)
		[fileTypeButton addItemWithTitle:type];
	
	// Initialize the values for the controls in the subviews
	[self setImageQuality:0.8];
	[self setIsAlphaEnabled:YES];
}


- (NSView *)viewForFileType:(NSString *)fileType
{
	// We got a query for a filetype -- make sure that it's selected
	[fileTypeButton selectItemWithTitle:fileType];
	
	// We have a few views that we could use, depending on the file type
	[self updateViewForFileType:fileType];
	
	return [self view];
}


// Sets up the accessory view for optimal awesomeness
- (void)updateViewForFileType:(NSString *)fileType
{
	// First empty out the container view
	for (NSView *subview in [containerView subviews])
		[subview removeFromSuperview];
	
	// Now we can add the correct subview
	if ([fileType isEqualToString:@"JPEG"]) {
		[containerView addSubview:jpegView];
	}/* else {
		// In all other cases, just use this view
		[containerView addSubview:defaultView];
	}*/
	
}


// When they change fileType, swap views
- (IBAction)fileTypeDidChange:(id)sender
{
	// Convert the filetype for use as a file extension
	NSString *buttonSelection = [sender titleOfSelectedItem];
	NSString *finalString = [SWImageTools convertFileType:buttonSelection];
	
	// Use the explicit mutator, to trigger KVO
	[self setCurrentFileType:finalString];
	
	// Update the container view for the new filetype
	[self updateViewForFileType:buttonSelection];
}


@end
