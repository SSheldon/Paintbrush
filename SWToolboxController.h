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

typedef enum {
	STROKE_ONLY,
	FILL_ONLY,
	FILL_AND_STROKE
} SWFillStyle;

@class SWColorSelector;
@class SWMatrix;
@class SWToolbox;
@class SWDocument;

@interface SWToolboxController : NSWindowController {	
	NSColor *foregroundColor;
	NSColor *backgroundColor;
	NSString *currentTool;
	NSInteger lineWidth;
	SWFillStyle fillStyle;
	BOOL selectionTransparency;
	
	IBOutlet SWMatrix *toolMatrix;
	IBOutlet SWMatrix *transparencyMatrix;
	IBOutlet SWMatrix *fillMatrix;	
	
	// My toolbox -- used when there's no active document
	SWToolbox *toolbox;
    
    // Active Document
    SWDocument *activeDocument;
}

// Accessors
+ (id)sharedToolboxPanelController;

// Mutators
- (IBAction)changeCurrentTool:(id)sender;
- (IBAction)changeFillStyle:(id)sender;
- (IBAction)changeSelectionTransparency:(id)sender;

// Other stuff
- (void)updateInfo;
- (void)switchToScissors:(id)sender;
- (IBAction)flipColors:(id)sender;

@property (assign) NSInteger lineWidthDisplay;
@property (assign,nonatomic) NSInteger lineWidth;
@property (assign) BOOL selectionTransparency;
@property (assign,nonatomic) NSString *currentTool;
@property (assign) SWFillStyle fillStyle;
@property (retain) NSColor *foregroundColor;
@property (retain) NSColor *backgroundColor;
//
@property (readonly) SWDocument *activeDocument;
//@property (readonly) NSMutableArray *toolListArray;

@end
