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


#import "SWImageTools.h"
#import "SWDocument.h"
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
	SWLockFocus(image);
	[[NSColor clearColor] setFill];
	NSRectFillUsingOperation(rect, NSCompositeCopy);
	SWUnlockFocus(image);
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

	*imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil 
														pixelsWide: w
														pixelsHigh: h
													 bitsPerSample: 8 
												   samplesPerPixel: 4 
														  hasAlpha: YES 
														  isPlanar: NO 
													colorSpaceName: NSCalibratedRGBColorSpace 
													   bytesPerRow: 0	// "you figure it out"
													  bitsPerPixel: 32];
	// Initialize it to a completely transparent image
	[SWImageTools clearImage:*imageRep];
	
}


// Requested by a user -- converts an image to a monochrome bitmap
+ (NSBitmapImageRep *)createMonochromeImage:(NSBitmapImageRep *)baseImage
{
	NSUInteger w = [baseImage pixelsWide];
	NSUInteger h = [baseImage pixelsHigh];
	
	// Need a place to put the monochrome pixels.
	NSBitmapImageRep *bwRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil  // Nil pointer tells the kit to allocate the pixel buffer for us.
																	  pixelsWide: w 
																	  pixelsHigh: h
																   bitsPerSample: 1
																 samplesPerPixel: 1  
																		hasAlpha: NO
																		isPlanar: NO 
																  colorSpaceName: NSCalibratedWhiteColorSpace // 0 = black, 1 = white in this color space.
																	 bytesPerRow: 0     // Passing zero means "you figure it out."
																	bitsPerPixel: 0];  // This must agree with bitsPerSample and samplesPerPixel.
	
	// Get a pointer to the pixel data -- both the new one and the old one
	unsigned char *colorData = [baseImage bitmapData];
	unsigned char *bwData = [bwRep bitmapData];
	unsigned char *thisPixel = bwData;
	
	CGFloat maxColorValue = pow(2, [baseImage bitsPerSample]);
	
	NSUInteger row, col;
	NSUInteger bitInByte = 0;
	unsigned char currByte = 0;
	for (row = 0; row < h; row++) {
		for (col = 0; col < w; col++) {
			
			// First calculate the offset for the point passed in
			NSUInteger offset = (w * row) + col;
			offset *= [baseImage samplesPerPixel];
			
			// Next get the components at that offset
			NSUInteger red = colorData[offset + 0];
			NSUInteger green = colorData[offset + 1];
			NSUInteger blue = colorData[offset + 2];
			
			// NTSC color weighting formula
			NSUInteger value = (unsigned char)rint(((0.299 * red) + (0.587 * green) + (0.114 * blue)) / maxColorValue);
			
			// Add it to our byte
			currByte |= value << bitInByte++;
			if (bitInByte == 8) {
				// We've reached a full byte -- add it to the data
				*thisPixel = currByte;
				currByte = 0;
				bitInByte = 0;
				
				// Increment the pointer
				thisPixel++;
			}
		}		
	}
	
	return [bwRep autorelease];
}


// This method converts human-readable strings (PNG, TIFF, etc) to system-happy extensions
+ (NSString *)convertFileType:(NSString *)fileType
{
	NSString *finalString = nil;
	NSString *lowerCaseFileType = [fileType lowercaseString];
	if ([lowerCaseFileType length] == 3) 
	{
		finalString = lowerCaseFileType;		
	}
	else
	{
		// Two special cases at the moment
		if ([lowerCaseFileType isEqualToString:@"tiff"])
			finalString = @"tif";
		else if ([lowerCaseFileType isEqualToString:@"jpeg"])
			finalString = @"jpg";
		else
			finalString = @"";
	}
	return finalString;
}


+ (BOOL)color:(NSColor *)c1 isEqualToColor:(NSColor *)c2
{
	CGFloat r1, r2, g1, g2, b1, b2, a1, a2;
	DebugLog(@"%@", [c1 colorSpaceName]);
	DebugLog(@"%@", [c2 colorSpaceName]);
	[c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	r1 = roundf(255*r1);
	r2 = roundf(255*r2);
	g1 = roundf(255*g1);
	g2 = roundf(255*g2);
	b1 = roundf(255*b1);
	b2 = roundf(255*b2);
	a1 = roundf(255*a1);
	a2 = roundf(255*a2);
	return (r1==r2) && (g1==g2) && (b1==b2) && (a1==a2);
}


// Strips an image of all the pixels of a certain color
+ (void)stripImage:(NSBitmapImageRep *)imageRep ofColor:(NSColor *)color
{
	// This offset will climb through the entire image
	//int offset;
	NSInteger samplesPerPixel = [imageRep samplesPerPixel];
	unsigned char *bitmapData = [imageRep bitmapData];
	
	// Get the components of the given NSColor
	CGFloat colorRed, colorGreen, colorBlue, colorAlpha;
	NSColor * convertedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[convertedColor getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
	
	// Scale them up
	NSInteger r = roundf(colorRed * 255.0);
	NSInteger g = roundf(colorGreen * 255.0);
	NSInteger b = roundf(colorBlue * 255.0);
	NSInteger a = roundf(colorAlpha * 255.0);
	
	// We can't go linearly, as 10.4+ don't always pack bytes -- it may not be contiguous!
	// Instead, we must go row by row
	int row, col;
    for (row = 0; row < [imageRep pixelsHigh]; row++, bitmapData += [imageRep bytesPerRow]) 
	{
        unsigned char* p = bitmapData;
        for (col = 0; col < [imageRep pixelsWide]; col++)
		{
			// Next get the components at that offset
			NSInteger red = *p;
			NSInteger green = *(p + 1);
			NSInteger blue = *(p + 2);
			NSInteger alpha = *(p + 3);			
			if ((alpha == 0 && colorAlpha == 0) ||
				(red == r && green == g && blue == b && alpha == a))
			{
				*p = 0;
				*(p + 1) = 0;
				*(p + 2) = 0;
				*(p + 3) = 0;
			}
			
			// Increment p
			p += samplesPerPixel;
        }
    }
}


// Used by Paste to retrieve an image from the pasteboard
+ (NSData *)readImageFromPasteboard:(NSPasteboard *)pb
{
	NSData *data = nil;
	
	if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSTIFFPboardType]])
		data = [pb dataForType:NSTIFFPboardType];
	else if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSPICTPboardType]])
		data = [pb dataForType:NSPICTPboardType];

	return data;
}


// Simple cropping
+ (NSBitmapImageRep *)cropImage:(NSBitmapImageRep *)image toRect:(NSRect)rect
{
	// Sanity check
	NSAssert(rect.origin.x >= 0 && rect.origin.y >= 0, @"We can't crop to a less-than-zero origin!");
	NSAssert(rect.size.width > 0 && rect.size.height > 0, @"We can't crop to a non-positive width or height!");
	
	// First create the image
	NSBitmapImageRep *croppedImage;
	[SWImageTools initImageRep:&croppedImage withSize:rect.size];	
	[SWImageTools clearImage:croppedImage];
	
	// Now, draw the source image to our new image
	// Don't forget to offset by the NEGATIVE of the rect origin!
	[SWImageTools drawToImage:croppedImage
					fromImage:image
					  atPoint:NSMakePoint(-rect.origin.x, -rect.origin.y) 
			  withComposition:NO];
	
	return croppedImage;
}

void SWLockFocus(NSBitmapImageRep *image)
{
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:image]];
}


void SWUnlockFocus(NSBitmapImageRep *image)
{
#pragma unused (image)
	[NSGraphicsContext restoreGraphicsState];
}


@end
