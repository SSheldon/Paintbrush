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


#import "SWSelectionBuilder.h"

// Instead of defining a custom class for line segments that would only be used
//	in this file, just use NSDictionary and some keys.
#define kSegment_Left	@"segmentLeft"
#define kSegment_Right	@"segmentRight"
#define kSegment_Y		@"segmentY"

// We allocate the memory for the image mask here, but the CGImageRef is used
//	outside of here. So provide a callback to free up the memory after the
//	caller is done with the CGImageRef.
static void MaskDataProviderReleaseDataCallback(void *info, const void *data, size_t size)
{
	free((void*)data);
}

@interface SWSelectionBuilder (Private)

- (void) searchLineAtPoint:(NSPoint)point;
- (BOOL) markPointIfItMatches:(NSPoint)point;

- (BOOL) pixelMatches:(NSPoint)point;
- (BOOL) pixelEquality:(NSPoint)point;
- (unsigned int) pixelDifference:(NSPoint)point;

- (void) processSegment:(SWSegment *)segment;
- (CGImageRef) createMask;

@end

@implementation SWSelectionBuilder

- (id) initWithBitmapImageRep:(NSBitmapImageRep *)imageRep point:(NSPoint)point tolerance:(CGFloat)tolerance
{
	self = [super init];
	
	if ( self != nil ) {
		// Just retain the source image. We don't want to make a heavy copy of it
		//	(too expensive) but we don't want it going away on us
		mImageRep = [imageRep retain];
		[mImageRep getBitmapDataPlanes:&mBitmapData];
		
		// Record the width and height of the source image. We'll use it to
		//	figure out how big to make our mask.
		mWidth = [mImageRep pixelsWide];
		mHeight = [mImageRep pixelsHigh];
		
		// Calloc marks the mask as all black, or all masked in (i.e. the image
		//	would be all there, by default). So use memset() to mark them all
		//	transparent.
		mMaskRowBytes = (mWidth + 0x0000000F) & ~0x0000000F;
		mMaskData = calloc(mHeight, mMaskRowBytes);
		memset(mMaskData, 0xFF, mHeight * mMaskRowBytes);
		
		// Calloc marks them all as not visited
		mVisited = calloc(mHeight * mWidth, sizeof(BOOL));
		
		// Calloc this guy too, just for fun
		mSegments = calloc(mHeight * mWidth, sizeof(SWSegment));
		mSegCt = 0;
		
		// If the user clicked on a non-integral value, make it an integral value.
		//	We only deal with raw pixel data, not interpolated values. Also flip
		//	the y component because pixels start at the top left, but the view
		//	origin was at the bottom left
		mPickedPoint.x = floor(point.x);
		mPickedPoint.y = mHeight - floor(point.y);
		
		// Grab the pixel data at the location the user clicked on.
		[mImageRep getPixel:mPickedPixel atX:(int)mPickedPoint.x y:(int)mPickedPoint.y];
		
		// We need to scale the tolerance from [0..1] to [0..maxSampleValue], but to
		//	do that, we first need to figure out what the maximum sample value
		//	is. Compute how many bits are in a pixel component, then use that.
		int bitsPerSample = [mImageRep bitsPerPixel] / [mImageRep samplesPerPixel];
		int maxSampleValue = 0;
		int i = 0;
		for (i = 0; i < bitsPerSample; ++i)
			maxSampleValue = (maxSampleValue << 1) | 1;
		
		mTolerance = tolerance * maxSampleValue;
		
		// Create an intermediate stack to hold the line segments that still
		//	need to be processed.
		mStack = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	// Let go of our source image, free up our visited buffer, and our stack.
	[mImageRep release];
	free(mSegments);
	free(mVisited);

	// Note that we don't free mMaskData -- this is intentional, as it'll be freed
	// when the mask image is freed
	[mStack release];
	
	[super dealloc];
}

- (CGImageRef) mask
{
	// Prime the loop so we have something on the stack. searcLineAtPoint
	//	will look both to the right and left for pixels that match the 
	//	selected color. It will then throw that line segment onto the stack.
	[self searchLineAtPoint:mPickedPoint];
	
	// While the stack isn't empty, continue to process line segments that
	//	are on the stack.
	while ( [mStack count] > 0 ) {
		// Pop the top segment off the stack
//		NSDictionary* segment = [[[mStack lastObject] retain] autorelease];
		SWSegment *segment = [[mStack lastObject] pointerValue];
		[mStack removeLastObject];
		
		// Process the segment, by looking both above and below it for pixels
		//	that match the user picked pixel
		[self processSegment:segment];
	}
	
	// We're done, so convert our mask data into a real mask
	return [self createMask];
}

@end

@implementation SWSelectionBuilder (Private)

- (void) searchLineAtPoint:(NSPoint)point
{
	// This function will look at the point passed in to see if it matches
	//	the selected pixel. It will then look to the left and right of the
	//	passed in point for pixels that match. In addition to adding a line
	//	segment to the stack (to be processed later), it will mark the mVisited
	//	and mMaskData bitmaps to reflect if the pixels have been visited or
	//	should be selected.
	
	// First, we want to do some sanity checking. This includes making sure
	//	the point is in bounds, and that the specified point hasn't already
	//	been visited.
	if ( (point.y < 0) || (point.y >= mHeight) || (point.x < 0) || (point.x >= mWidth) )
		return;
	BOOL* hasBeenVisited = (mVisited + (long)point.y * mWidth + (long)point.x);
	if ( *hasBeenVisited )
		return;
	
	// Make sure the point we're starting at at least matches. If it doesn't,
	//	there's not a line segment here, and we can bail now.
	if ( ![self markPointIfItMatches:point] )
		return;
	
	// Search left, marking pixels as visited, and in or out of the selection
	CGFloat x = point.x - 1.0;
	CGFloat left = point.x;
	while ( x >= 0 ) {
		if ( [self markPointIfItMatches: NSMakePoint(x, point.y)] )
			left = x; // Expand our line segment to the left
		else
			break; // If it doesn't match, the we're done looking
		x = x - 1.0;
	}
	
	// Search right, marking pixels as visited, and in or out of the selection
	CGFloat right = point.x;
	x = point.x + 1.0;
	while ( x < mWidth ) {
		if ( [self markPointIfItMatches: NSMakePoint(x, point.y)] )
			right = x; // Expand our line segment to the right
		else
			break; // If it doesn't match, the we're done looking
		x = x + 1.0;
	}
	
	// Push the segment we just found onto the stack, so we can look above
	//	and below it later.
//	NSDictionary* segment = [NSDictionary dictionaryWithObjectsAndKeys:
//							 [NSNumber numberWithFloat:left], kSegment_Left,
//							 [NSNumber numberWithFloat:right], kSegment_Right,
//							 [NSNumber numberWithFloat:point.y], kSegment_Y,
//							 nil];
//	[mStack addObject:segment];	
	SWSegment *segment = &(mSegments[mSegCt]);
	mSegCt += 1;
	segment->left = left;
	segment->right = right;
	segment->y = point.y;
	[mStack addObject:[NSValue valueWithPointer:segment]];
}

- (BOOL) markPointIfItMatches:(NSPoint) point
{
	// This method examines a specific pixel to see if it should be in the selection
	//	or not, by determining if it is "close" to the user picked pixel. Regardless
	//	of it is in the selection, we mark the pixel as visited so we don't examine
	//	it again.
	
	// Do some sanity checking. If its already been visited, then it doesn't
	//	match
	BOOL* hasBeenVisited = (mVisited + (long)point.y * mWidth + (long)point.x);
	if ( *hasBeenVisited )
		return NO;
	
	// Ask a helper function to determine if the pixel passed in matches
	//	the user selected pixel
	BOOL matches = NO;
	//if ( [self pixelMatches:point] ) {
	
	// We are using pixelEquality because the tolerance is always 1.0 with 
	//  Paintbrush - in other words, if it ain't the same, we don't fill it
	if ( [self pixelEquality:point]) {
		// The pixels match, so return that answer to the caller
		matches = YES;
		
		// Now actually mark the mask
		unsigned char* maskRow = mMaskData + (mMaskRowBytes * (long)point.y);
		maskRow[(long)point.x] = 0x00; // all on
	}
	
	// We've made a decision about this pixel, so we've visted it. Mark it
	// as such.
	*hasBeenVisited = YES;
	
	return matches;
}

- (BOOL) pixelMatches:(NSPoint)point
{
	// We don't do exact matches (unless the tolerance is 0), so compute
	//	the "difference" between the user selected pixel and the passed in
	//	pixel. If it's less than the specified tolerance, then the pixels
	//	match.
	
	unsigned int difference = [self pixelDifference:point];	 
	return difference <= mTolerance;
}

- (BOOL) pixelEquality:(NSPoint)point
{
	// This method is used when we have a tolerance of 0 - it's faster for a
	// simple flood fill, which is what Paintbrush needs. Use pixelDifference
	// if you have the possibility of a non-zero tolerance.
	
	// We can't go linearly, as 10.4+ don't always pack bytes -- it may not be contiguous!
	// Instead, we must go row by row
	unsigned char * p = mBitmapData + ((int)point.y * [mImageRep bytesPerRow]);
	p += (int)point.x * [mImageRep samplesPerPixel];
	
	// Next get the components at that offset
	NSInteger red = *p;
	NSInteger green = *(p + 1);
	NSInteger blue = *(p + 2);
	NSInteger alpha = *(p + 3);			
	
	// Look for any difference between the pixels - if there is any variance,
	// the pixels are not identical
	return (alpha == 0 && mPickedPixel[3] == 0) ||
		(red == mPickedPixel[0] && green == mPickedPixel[1] && blue == mPickedPixel[2] && alpha == mPickedPixel[3]);
}

- (unsigned int) pixelDifference:(NSPoint)point
{
	// This method determines the "difference" between the specified pixel
	//	and the user selected pixel in a very simple and cheap way. It takes
	//	the difference of all the components (except alpha) and which ever
	//	has the greatest difference, that's the difference between the pixels.
	
	
	// First get the components for the point passed in
	NSUInteger pixel[kMaxSamples];
	[mImageRep getPixel:pixel atX:(int)point.x y:(int)point.y];
	
	// Determine the largest difference in the pixel components. Note that we
	//	assume the alpha channel is the last component, and we skip it.
	unsigned int maxDifference = 0;
	int samplesPerPixel = [mImageRep samplesPerPixel];	
	int i = 0;
	for (i = 0; i < (samplesPerPixel - 1); ++i) {
		//		if (mPickedPixel[i] != pixel[i]) {
		//			return -1;
		//		}
		unsigned int difference = abs((long)mPickedPixel[i] - (long)pixel[i]);
		if ( difference > maxDifference )
			maxDifference = difference;
	}
	
	return maxDifference;
}

//- (void) processSegment:(NSDictionary*)segment
- (void) processSegment:(SWSegment *)segment
{
	// Figure out where this segment actually lies, by pulling the line segment
	//	information out of the dictionary
//	NSNumber* leftNumber = [segment objectForKey:kSegment_Left];
//	NSNumber* rightNumber = [segment objectForKey:kSegment_Right];
//	NSNumber* yNumber = [segment objectForKey:kSegment_Y];
//	CGFloat left = [leftNumber floatValue];
//	CGFloat right = [rightNumber floatValue];
//	CGFloat y = [yNumber floatValue];
	
	// We're going to walk this segment, and test each integral point both
	//	above and below it. Note that we're doing a four point connect.
	CGFloat x = 0.0;
	for ( x = segment->left; x <= segment->right; x = x + 1.0 ) {
		[self searchLineAtPoint: NSMakePoint(x, segment->y - 1.0)]; // check above
		[self searchLineAtPoint: NSMakePoint(x, segment->y + 1.0)]; // check below
	}
}

- (CGImageRef) createMask
{
	// This function takes the raw mask bitmap that we filled in, and creates
	//	a CoreGraphics mask from it.
	
	// Gotta have a data provider to wrap our raw pixels. Provide a callback
	//	for the mask data to be freed. Note that we don't free mMaskData in our
	//	dealloc on purpose.
	CGDataProviderRef provider = CGDataProviderCreateWithData(nil, mMaskData, mMaskRowBytes * mHeight, &MaskDataProviderReleaseDataCallback);
	
	CGImageRef mask = CGImageMaskCreate(mWidth, mHeight, 8, 8, mMaskRowBytes, provider, nil, false);
	
	CGDataProviderRelease(provider);
	
	return mask;
}

@end

