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


@interface SWImageTools : NSObject

+ (void)invertImage:(NSBitmapImageRep *)image;
+ (void)clearImage:(NSBitmapImageRep *)image;
+ (void)clearImage:(NSBitmapImageRep *)image inRect:(NSRect)rect;
+ (void)drawToImage:(NSBitmapImageRep *)dest 
		  fromImage:(NSBitmapImageRep *)src
	withComposition:(BOOL)shouldCompositeOver;
+ (void)drawToImage:(NSBitmapImageRep *)dest 
		  fromImage:(NSBitmapImageRep *)src 
			atPoint:(NSPoint)point
	withComposition:(BOOL)shouldCompositeOver;
+ (void)initImageRep:(NSBitmapImageRep **)imageRep withSize:(NSSize)size;
+ (void)flipImageHorizontal:(NSBitmapImageRep *)bitmap;
+ (void)flipImageVertical:(NSBitmapImageRep *)bitmap;
+ (NSString *)convertFileType:(NSString *)fileType;
+ (BOOL)color:(NSColor *)c1 isEqualToColor:(NSColor *)c2;
+ (void)stripImage:(NSBitmapImageRep *)imageRep ofColor:(NSColor *)color;
+ (NSData *)readImageFromPasteboard:(NSPasteboard *)pb;
+ (NSBitmapImageRep *)cropImage:(NSBitmapImageRep *)image toRect:(NSRect)rect;

// User requested feature!
+ (NSBitmapImageRep *)createMonochromeImage:(NSBitmapImageRep *)baseImage;

// A few things I'd like to try
void SWLockFocus(NSBitmapImageRep *image);
void SWUnlockFocus(NSBitmapImageRep *image);

@end
