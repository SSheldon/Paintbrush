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
	PERCENT = 0,
	PIXELS = 1
} SWUnit;


@interface SWResizeWindowController : NSWindowController {	
	IBOutlet NSTextField *heightFieldNew;
	IBOutlet NSTextField *widthFieldNew;
	
	IBOutlet NSTextField *heightFieldOriginal;
	IBOutlet NSTextField *widthFieldOriginal;
	
	IBOutlet NSPopUpButton *heightUnits;
	IBOutlet NSPopUpButton *widthUnits;
	
	// Store the original size for a moment
	NSSize originalSize;
	
	// Don't forget about the new size!
	NSSize newSize;
	
	// Percent or pixels?
	SWUnit selectedUnit;
	
	BOOL scales;
}


// OK or Cancel
- (IBAction)endSheet:(id)sender;

// Changing the units of measurement
- (IBAction)changeUnits:(id)sender;

// A few accessors and mutators
- (NSInteger)width;
- (NSInteger)height;
- (void)setCurrentSize:(NSSize)currSize;
- (BOOL)scales;
- (void)setScales:(BOOL)s;

@property (assign) SWUnit selectedUnit;

@end
