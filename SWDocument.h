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



#import <Cocoa/Cocoa.h>

@class SWPaintView;
@class SWScalingScrollView;
@class SWTool;
@class SWPaintView;
@class SWToolboxController;
@class SWSizeWindowController;
@class SWCenteringClipView;
@class SWTextToolWindowController;

@interface SWDocument : NSDocument
{
	IBOutlet SWPaintView *paintView;
	IBOutlet NSWindow *window;
	IBOutlet SWScalingScrollView *scrollView;	/* ScrollView containing document */


	
	// A bunch of controllers and one view
	SWToolboxController *toolboxController;
	SWCenteringClipView *clipView;
	SWTextToolWindowController *textController;
	SWSizeWindowController *sizeController;
	NSImage *openedImage;
	SWTool *currentTool;
	NSNotificationCenter *nc;
	NSRect openingRect;
}

// Methods called by menu items
- (IBAction)flipHorizontal:(id)sender;
- (IBAction)flipVertical:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)actualSize:(id)sender;
//- (IBAction)fullScreen:(id)sender;
- (IBAction)crop:(id)sender;
//- (IBAction)invertColors:(id)sender;
- (void)showTextSheet:(NSNotification *)n;
- (void)undoLevelChanged:(NSNotification *)n;

// Access the document's view (and provide access to the image)
- (SWPaintView *)paintView;

// Sheets for size!
- (void)sizeSheetDidEnd:(NSWindow *)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void *)contextInfo;
- (IBAction)raiseSizeSheet:(id)sender;
- (void)setUpPaintView;

// For copy-and-paste
- (void)writeImageToPasteboard:(NSPasteboard *)pb;
+ (NSData *)readImageFromPasteboard:(NSPasteboard *)pb;

+ (void)setWillShowSheet:(BOOL)showSheet;

@end
