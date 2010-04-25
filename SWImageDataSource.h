//
//  SWImageDataSource.h
//  Paintbrush2
//
//  Created by Mike Schreiber on 3/30/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SWImageDataSource : NSObject 
{
	NSBitmapImageRep * mainImage;	// The main storage image
	NSBitmapImageRep * bufferImage;	// The buffer drawn to for temporary actions
	
	NSArray * imageArray;	// Array of images used for drawing (the images above)
	
	NSSize size;			// Cached size
}

// Initializers
- (id)initWithSize:(NSSize)size;
- (id)initWithURL:(NSURL *)url;
- (id)initWithPasteboard;

// Modifiers to the image
- (void)resizeToSize:(NSSize)size
		  scaleImage:(BOOL)shouldScale;

// For drawing
- (NSArray *)imageArray;

// Accessing information about the image source
@property (readonly) NSSize size;
@property (readonly) NSBitmapImageRep * mainImage;
@property (readonly) NSBitmapImageRep * bufferImage;

@end
