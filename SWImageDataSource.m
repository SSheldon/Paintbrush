//
//  SWImageDataSource.m
//  Paintbrush2
//
//  Created by Mike Schreiber on 3/30/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import "SWImageDataSource.h"


@implementation SWImageDataSource

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


// -----------------------------------------------------------------------------
//  Accessors
// -----------------------------------------------------------------------------

@synthesize size;

@end
