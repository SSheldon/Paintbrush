//
//  SWSavePanelAccessoryViewController.h
//  Paintbrush2
//
//  Created by Mike Schreiber on 11/7/09.
//  Copyright 2009 University of Arizona. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const kSWCurrentFileType;

@interface SWSavePanelAccessoryViewController : NSViewController {
	// We maintain a different view for certain fileTypes, as well as a default one
	IBOutlet NSView *defaultView;
	IBOutlet NSView *jpegView;
	
	// This is the slot they can go in
	IBOutlet NSView *containerView;
	
	// The currently-selected filetype -- used for KVO
	NSString *currentFileType;
	
	// The controls in our views -- we start with the global popup button
	IBOutlet NSPopUpButton *fileTypeButton;
	
	// Used in the various subviews
	BOOL isAlphaEnabled;
	CGFloat imageQuality;
}

- (void)updateViewForFileType:(NSString *)fileType;
- (NSView *)viewForFileType:(NSString *)fileType;
- (IBAction)fileTypeDidChange:(id)sender;

@property (retain) NSString *currentFileType;

// These values are bound (binded?) to the controls in the various subviews
@property (assign) BOOL isAlphaEnabled;
@property (assign) CGFloat imageQuality;

@end
