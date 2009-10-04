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


#import "SWImageTools.h"
#import <QuartzCore/QuartzCore.h>


@implementation SWImageTools

// Uses Core Image filters to invert the colors of the image
+ (void)invertImage:(NSBitmapImageRep *)image
{
	NSLog(@"Working on it!");
//	[image lockFocus];
//	NSGraphicsContext *gc = [NSGraphicsContext currentContext];
//	CIContext *context = [gc CIContext];
	
/*	// Get the width and height of the image
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
	[imageRep release];
	
	imageRep = [[NSBitmapImageRep alloc] initWithCIImage:result];
	
	[image lockFocus];
	[imageRep drawAtPoint:NSZeroPoint];
	[image unlockFocus];
	[imageRep release];
*/}

void SWClearImage(NSBitmapImageRep *image)
{
	NSRect rect = NSMakeRect(0,0,[image pixelsWide],[image pixelsHigh]);
	SWClearImageRect(image,rect);
}


void SWClearImageRect(NSBitmapImageRep *image, NSRect rect)
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:image]];
	[[NSColor clearColor] setFill];
	NSRectFill(rect);
	[NSGraphicsContext restoreGraphicsState];
}


// Assume both images are allocated, same size
void SWCopyImage(NSBitmapImageRep *dest, NSBitmapImageRep *src)
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:dest]];
	[src draw];
	[NSGraphicsContext restoreGraphicsState];
}


void SWFlipImageVertical(NSBitmapImageRep *bitmap)
{
	// Make a copy of our image for using is a second
	NSBitmapImageRep *tempImage;
	SWImageRepWithSize(&tempImage, NSMakeSize([bitmap pixelsWide], [bitmap pixelsHigh]));
	SWCopyImage(tempImage, bitmap);
	NSAffineTransform *transform = [NSAffineTransform transform];
	
	// Create the transform
	[transform scaleXBy:1.0 yBy:-1.0];
	NSLog(@"%d", [bitmap pixelsHigh]);
	[transform translateXBy:0 yBy:(0-[bitmap pixelsHigh])];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
	[transform concat];
	[tempImage draw];
	[NSGraphicsContext restoreGraphicsState];
}


void SWImageRepWithSize(NSBitmapImageRep **imageRep, NSSize size)
{
	NSUInteger w = size.width;
	NSUInteger h = size.height;
	NSUInteger rowBytes = ((NSInteger)(ceil(w)) * 4 + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good

	*imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil 
														pixelsWide:w
														pixelsHigh:h
													 bitsPerSample:8 
												   samplesPerPixel:4 
														  hasAlpha:YES 
														  isPlanar:NO 
													colorSpaceName:NSDeviceRGBColorSpace 
													  bitmapFormat:0 
													   bytesPerRow:rowBytes
													  bitsPerPixel:32];
	
}


void SWLockFocus(NSBitmapImageRep *image)
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:image]];
}


void SWUnlockFocus(NSBitmapImageRep *image)
{
	[NSGraphicsContext restoreGraphicsState];
}


@end
