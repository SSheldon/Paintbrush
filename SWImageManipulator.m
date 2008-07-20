/**
 * Copyright 2007, 2008 Soggy Waffles
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


#import "SWImageManipulator.h"
#import <QuartzCore/QuartzCore.h>


@implementation SWImageManipulator

// Uses Core Image filters to invert the colors of the image
+ (void)invertImage:(NSImage *)image
{
	NSLog(@"Working on it!");
//	[image lockFocus];
//	NSGraphicsContext *gc = [NSGraphicsContext currentContext];
//	CIContext *context = [gc CIContext];
	
	// Get the width and height of the image
	NSInteger w = [image size].width;
	NSInteger h = [image size].height;
	
	NSUInteger rowBytes = ((NSInteger)(ceil(w)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good
	
	// Create a new NSBitmapImageRep for filling
	// Note: this instantiation is only valid for Leopard - Tiger needs something different
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
													   pixelsWide:w
													   pixelsHigh:h 
													bitsPerSample:8 
												  samplesPerPixel:4 
														 hasAlpha:YES 
														 isPlanar:NO 
												   colorSpaceName:NSDeviceRGBColorSpace 
													 bitmapFormat:NSAlphaFirstBitmapFormat 
													  bytesPerRow:rowBytes
													 bitsPerPixel:32];
	
	// Get the graphics context associated with the new ImageRep so we can draw to it
	NSGraphicsContext* imageContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:imageContext];
	
	// Draw the current image to the ImageRep
	[image drawAtPoint:NSZeroPoint
				fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
			   operation:NSCompositeSourceOver
				fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	CIFilter *colorInvert = [CIFilter filterWithName:@"CIColorInvert"];
	[colorInvert setValue: [[CIImage alloc] initWithBitmapImageRep:imageRep] forKey: @"inputImage"];
	CIImage *result = [colorInvert valueForKey: @"outputImage"];
	
	imageRep = [[NSBitmapImageRep alloc] initWithCIImage:result];
	
	[image lockFocus];
	[imageRep drawAtPoint:NSZeroPoint];
	[image unlockFocus];	
}

@end
