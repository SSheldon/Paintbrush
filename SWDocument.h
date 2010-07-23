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



#import <Cocoa/Cocoa.h>

@class SWPaintView;
@class SWScalingScrollView;
@class SWTool;
@class SWToolbox;
@class SWToolboxController;
@class SWSizeWindowController;
@class SWResizeWindowController;
@class SWCenteringClipView;
@class SWTextToolWindowController;
@class SWSavePanelAccessoryViewController;
@class SWImageDataSource;

@interface SWDocument : NSDocument
{
	IBOutlet SWPaintView *paintView;
	IBOutlet SWScalingScrollView *scrollView;	/* ScrollView containing document */
	
	// The image data
	SWImageDataSource * dataSource;
	
	// A bunch of controllers and one view
	SWToolboxController *toolboxController;
	SWToolbox *toolbox;
	SWCenteringClipView *clipView;
	SWTextToolWindowController *textController;
	SWSizeWindowController *sizeController;
	SWResizeWindowController *resizeController;
	SWSavePanelAccessoryViewController *savePanelAccessoryViewController;
	
	// Misc other member variables
	NSNotificationCenter *nc;
	NSString *currentFileType;
}

// Properties
@property (readonly) SWToolbox *toolbox;
@property (readonly) SWPaintView *paintView;


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
- (IBAction)invertColors:(id)sender;
- (void)showTextSheet:(NSNotification *)n;
- (void)undoLevelChanged:(NSNotification *)n;

// Sheets for size!
- (void)sizeSheetDidEnd:(NSWindow *)sheet
			 returnCode:(NSInteger)returnCode
			contextInfo:(void *)contextInfo;
- (IBAction)raiseSizeSheet:(id)sender;
- (IBAction)raiseResizeSheet:(id)sender;
- (void)setUpPaintView;

// Undo
- (void)handleUndoWithImageData:(NSData *)mainImageData 
						  frame:(NSRect)frame;

// For copy-and-paste
- (void)writeImageToPasteboard:(NSPasteboard *)pb;

+ (void)setWillShowSheet:(BOOL)showSheet;


@end
