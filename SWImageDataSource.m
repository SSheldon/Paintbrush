//
//  SWImageDataSource.m
//  Paintbrush2
//
//  Created by Mike Schreiber on 3/30/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import "SWImageDataSource.h"
#import "SWToolboxController.h"


@implementation SWImageDataSource

// -----------------------------------------------------------------------------
//  Initializers
// -----------------------------------------------------------------------------


- (id)initWithSize:(NSSize)sizeIn
{
	self = [super init];
	if (self)
	{
		// Save the size
		size = sizeIn;
		
		// Create the two images we'll be using
		[SWImageTools initImageRep:&mainImage withSize:size];
		[SWImageTools initImageRep:&bufferImage withSize:size];
		
		// New Image: gotta paint the background color
		SWLockFocus(mainImage);
		
		NSColor *bgColor = [[SWToolboxController sharedToolboxPanelController] backgroundColor];
		[bgColor setFill];

		NSRect newRect = (NSRect) { NSZeroPoint, sizeIn };
		NSRectFill(newRect);
		
		SWUnlockFocus(mainImage);		
	}
	return self;
}


- (id)initWithURL:(NSURL *)url
{
	// Temporary image to get dimensions
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithContentsOfURL:url];
	
	assert(tempImage);
	if (!tempImage)	// failure case
		return nil;
	
	// Run baseline initializer
	[self initWithSize:NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh])];
	
	// Copy the image to the mainImage
	[SWImageTools drawToImage:mainImage fromImage:tempImage withComposition:NO];
	
	// Flip it, since our views are all flipped
	if (mainImage)
		[SWImageTools flipImageVertical:mainImage];		
	
	return self;
}


- (id)initWithPasteboard
{
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithPasteboard:[NSPasteboard generalPasteboard]];
	
	assert(tempImage);
	if (!tempImage)	// failure case
		return nil;
	
	// Run baseline initializer
	[self initWithSize:NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh])];
		
	// Flip it, since our views are all flipped
	if (mainImage)
		[SWImageTools flipImageVertical:mainImage];
}


- (void)dealloc
{
	// Clean up a bit after ourselves
	[imageArray release];
	[mainImage release];
	[bufferImage release];
}


// -----------------------------------------------------------------------------
//  Mutators
// -----------------------------------------------------------------------------

- (void)resizeToSize:(NSSize)newSize
		  scaleImage:(BOOL)shouldScale;
{
	// We'll be replacing the two images behind the scenes
	NSBitmapImageRep *newMainImage = nil;
	NSBitmapImageRep *newBufferImage = nil;
	[SWImageTools initImageRep:&newMainImage 
					  withSize:newSize];
	[SWImageTools initImageRep:&newBufferImage
					  withSize:newSize];
	
	NSRect newRect = (NSRect) { NSZeroPoint, newSize };
	SWLockFocus(newMainImage);
	if (shouldScale) 
	{
		// Stretch the image to the correct size
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		[mainImage drawInRect:newRect];
	}
	else 
	{
		NSColor *bgColor = [[SWToolboxController sharedToolboxPanelController] backgroundColor];
		[bgColor setFill];
		NSRectFill(newRect);
		[mainImage drawAtPoint:NSZeroPoint];
	}
	SWUnlockFocus(newMainImage);
	
	// Release and set (no need to retain: we already own the new images)
	[mainImage release];
	[bufferImage release];
	mainImage = newMainImage;
	bufferImage = newBufferImage;
	
	// Finally, update our cached size
	size = newSize;
}


// -----------------------------------------------------------------------------
//  Accessors
// -----------------------------------------------------------------------------

@synthesize size;
@synthesize mainImage;
@synthesize bufferImage;


// Creates an array if none exists, and returns it
- (NSArray *)imageArray
{
	if (!imageArray)
		imageArray = [[NSArray alloc] initWithObjects:mainImage, bufferImage, nil];
	
	return imageArray;
}

@end
