//
//  SWSavePanelAccessoryViewController.m
//  Paintbrush2
//
//  Created by Mike Schreiber on 11/7/09.
//  Copyright 2009 University of Arizona. All rights reserved.
//

#import "SWSavePanelAccessoryViewController.h"


NSString * const kSWCurrentFileType = @"currentFileType";

@implementation SWSavePanelAccessoryViewController


@synthesize currentFileType;


// Overridden to initially populate the popup button
- (void)loadView
{
	[super loadView];
	
	// Use the file types
	NSArray *fileTypes = [SWImageTools imageFileTypes];
	for (NSString *type in fileTypes)
		[fileTypeButton addItemWithTitle:type];	
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
	} else {
		// In all other cases, just use this view
		[containerView addSubview:defaultView];
	}
	
}


- (void)setFileTypes:(NSArray *)fileTypes
{
	if (fileTypes) {
		for (NSString *type in fileTypes)
			[fileTypeButton addItemWithTitle:type];	
	}
}


// When they change fileType, swap views
- (IBAction)fileTypeDidChange:(id)sender
{
	// Convert the filetype for use as a file extension
	NSString *buttonSelection = [sender titleOfSelectedItem];
	NSString *lowerCaseFileType = [buttonSelection lowercaseString];
	NSString *finalString = nil;
	if ([lowerCaseFileType length] == 3) {
		finalString = lowerCaseFileType;		
	} else {
		// Two special cases at the moment
		if ([lowerCaseFileType isEqualToString:@"tiff"])
			finalString = @"tif";
		else if ([lowerCaseFileType isEqualToString:@"jpeg"])
			finalString = @"jpg";
		else
			finalString = @"";
	}
	
	// Use the explicit mutator, to trigger KVO
	[self setCurrentFileType:finalString];
	
	// Update the container view for the new filetype
	[self updateViewForFileType:buttonSelection];
}


@end
