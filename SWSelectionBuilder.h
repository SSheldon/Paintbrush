/**
 * Copyright 2007-2009 Soggy Waffles
 *
 * This file is part of Paintbrush.
 *
 * Paintbrush is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */


#import <Cocoa/Cocoa.h>

// Max would be CYMKA, but we only use RGBA
#define kMaxSamples	4

@interface SWSelectionBuilder : NSObject {
	// The source image that we're using to build up a mask from
	NSBitmapImageRep	*mImageRep;
	
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
