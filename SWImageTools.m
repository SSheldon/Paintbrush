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
	NSBitmapImageRep *imageRep;
	[SWImageTools initImageRep:&imageRep withSize:[image size]];
	[SWImageTools drawToImage:imageRep fromImage:image withComposition:NO];
	
	CIFilter *colorInvert = [CIFilter filterWithName:@"CIColorInvert"];
	[colorInvert setValue: [[CIImage alloc] initWithBitmapImageRep:imageRep] forKey: @"inputImage"];
	CIImage *result = [colorInvert valueForKey: @"outputImage"];
	[imageRep release];
	
	imageRep = [[NSBitmapImageRep alloc] initWithCIImage:result];
	
	[SWImageTools drawToImage:image fromImage:imageRep withComposition:NO];
	[imageRep release];
}

+ (void)clearImage:(NSBitmapImageRep *)image
{
	NSRect rect = NSMakeRect(0,0,[image pixelsWide],[image pixelsHigh]);
	[SWImageTools clearImage:image inRect:rect];
}


+ (void)clearImage:(NSBitmapImageRep *)image inRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:image]];
	[[NSColor clearColor] setFill];
	NSRectFillUsingOperation(rect, NSCompositeCopy);
	[NSGraphicsContext restoreGraphicsState];
}


// Just calls the bigger one with a zeroed-out origin
+ (void)drawToImage:(NSBitmapImageRep *)dest 
		  fromImage:(NSBitmapImageRep *)src 
	withComposition:(BOOL)shouldCompositeOver
{
	[SWImageTools drawToImage:dest
					fromImage:src
					  atPoint:NSZeroPoint
			  withComposition:shouldCompositeOver];
}


// Assume both images are allocated, same size
+ (void)drawToImage:(NSBitmapImageRep *)dest 
		  fromImage:(NSBitmapImageRep *)src 
			atPoint:(NSPoint)point 
	withComposition:(BOOL)shouldCompositeOver
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:dest]];
	if (shouldCompositeOver)
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
	else
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeCopy];		
//	[src draw];
	CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], 
					   CGRectMake(point.x, point.y, [src pixelsWide], [src pixelsHigh]), [src CGImage]);
	[NSGraphicsContext restoreGraphicsState];
}


+ (void)flipImageHorizontal:(NSBitmapImageRep *)bitmap
{
	// Make a copy of our image for using is a second
	NSBitmapImageRep *tempImage;
	[SWImageTools initImageRep:&tempImage withSize:[bitmap size]];
	[SWImageTools drawToImage:tempImage fromImage:bitmap withComposition:NO];
	[SWImageTools clearImage:bitmap];
	NSAffineTransform *transform = [NSAffineTransform transform];
	
	// Create the transform
	[transform scaleXBy:-1.0 yBy:1.0];
	[transform translateXBy:(0-[bitmap pixelsWide]) yBy:0];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
	[transform concat];
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
	[tempImage draw];
	[NSGraphicsContext restoreGraphicsState];
	
	[tempImage release];
}


+ (void)flipImageVertical:(NSBitmapImageRep *)bitmap
{
	// Make a copy of our image for using is a second
	NSBitmapImageRep *tempImage;
	[SWImageTools initImageRep:&tempImage withSize:[bitmap size]];
	[SWImageTools drawToImage:tempImage fromImage:bitmap withComposition:NO];
	[SWImageTools clearImage:bitmap];
	NSAffineTransform *transform = [NSAffineTransform transform];
	
	// Create the transform
	[transform scaleXBy:1.0 yBy:-1.0];
	[transform translateXBy:0 yBy:(0-[bitmap pixelsHigh])];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap]];
	[transform concat];
	[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
	[tempImage draw];
	[NSGraphicsContext restoreGraphicsState];
	
	[tempImage release];
}


+ (void)initImageRep:(NSBitmapImageRep **)imageRep withSize:(NSSize)size
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
													colorSpaceName:NSCalibratedRGBColorSpace 
													   bytesPerRow:rowBytes
													  bitsPerPixel:32];
	// Initialize it to a completely transparent image
	[SWImageTools clearImage:*imageRep];
	
}


// A global list of file types -- autoreleased for your convenience!
+ (NSArray *)imageFileTypes
{
	return [NSArray arrayWithObjects:@"PNG", @"JPEG", @"GIF", @"BMP", @"TIFF", nil];
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
