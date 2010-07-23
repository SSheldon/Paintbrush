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

// Max would be CYMKA, but we only use RGBA
#define kMaxSamples	4

// Custom struct: this'll be easier to malloc/free than whole NSDictionaries
typedef struct SWSegment {
	NSInteger left;
	NSInteger right;
	NSInteger y;
} SWSegment;

@interface SWSelectionBuilder : NSObject {
	// The source image that we're using to build up a mask from
	NSBitmapImageRep	*mImageRep;
	
	// The bitmap data associated with the source image
	unsigned char		*mBitmapData;
	
	// The width and height of the source image, the resulting image mask,
	//	and the intermediate mVisited table
	size_t			mWidth;
	size_t			mHeight;

	// The raw data for the resulting image mask
	unsigned char	*mMaskData;
	size_t			mMaskRowBytes;
	
	// An intermediate table we use when examining the source image to determine
	//	if we have visited a specific pixel location. It is mWidth by mHeight
	//	in size.
	BOOL			*mVisited;
	
	// Handly little guy -- he's a collection of segments so we don't have to keep 
	//  creating and destroying them
	SWSegment		*mSegments;
	NSInteger		mSegCt;

	// Information about the pixel the user clicked on, including its coordinates
	//	and its pixel components.
	NSPoint			mPickedPoint;
	NSUInteger		mPickedPixel[kMaxSamples];
	
	// The tolerance scaled to the range used by the pixel components in the
	//	source image.
	unsigned int	mTolerance;
		
	// The stack of line segments we still need to process. When it goes empty
	//	we're done.
	NSMutableArray*	mStack;
}

- (id) initWithBitmapImageRep:(NSBitmapImageRep *)imageRep point:(NSPoint)point tolerance:(CGFloat)tolerance;

- (CGImageRef) mask;

@end
