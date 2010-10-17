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


#import "SWSelectionTool.h"
#import "SWToolboxController.h"
#import "SWDocument.h"

@implementation SWSelectionTool

@synthesize oldOrigin;

- (id)initWithController:(SWToolboxController *)controller;
{
	if (self = [super initWithController:controller]) {
		[controller addObserver:self
					 forKeyPath:@"selectionTransparency" 
						options:NSKeyValueObservingOptionNew 
						context:NULL];
		deltax = deltay = 0;
		dottedLineOffset = 0;
		isSelected = NO;
		dottedLineArray[0] = 5.0;
		dottedLineArray[1] = 3.0;
	}
	return self;
}

// The tools will observe several values set by the toolbox
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	id thing = [change objectForKey:NSKeyValueChangeNewKey];
	
	if ([keyPath isEqualToString:@"selectionTransparency"]) 
	{
		shouldOmitBackground = [thing boolValue];
		[self updateBackgroundOmission];
	}
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath bezierPath];
	[path setLineWidth:1.0];
	[path setLineDash:dottedLineArray count:2 phase:dottedLineOffset];
	[path setLineCapStyle:NSSquareLineCapStyle];	
	
	// The 0.5s help because the width is 1, and that does weird stuff
	[path appendBezierPathWithRect:
		NSMakeRect(clippingRect.origin.x+0.5, clippingRect.origin.y+0.5, clippingRect.size.width-1, clippingRect.size.height-1)];

	return path;	
}

- (NSBezierPath *)performDrawAtPoint:(NSPoint)point 
					   withMainImage:(NSBitmapImageRep *)mainImage 
						 bufferImage:(NSBitmapImageRep *)bufferImage 
						  mouseEvent:(SWMouseEvent)event
{	
	_bufferImage = bufferImage;
	_mainImage = mainImage;
	
	// Running the selection animator
	if (event == MOUSE_DOWN && animationTimer) 
	{
		[animationTimer invalidate];
		animationTimer = nil;
	}
	else if (event == MOUSE_UP && !NSEqualPoints(point, savedPoint)) 
	{
		// We are drawing the frame for the first time
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.075 // 75 ms, or 13.33 Hz
														  target:self
														selector:@selector(drawNewBorder:)
														userInfo:nil
														 repeats:YES];		
	} 
	
	// If the rectangle has already been drawn
	if (isSelected)
	{
		// We checked for the drag because it's possible that the cursor has been dragged outside the 
		// clipping rect in one single event
		if (event == MOUSE_DRAGGED || [[NSBezierPath bezierPathWithRect:clippingRect] containsPoint:point]) 
		{
			if (event == MOUSE_DOWN)
				previousPoint = point;

			deltax += point.x - previousPoint.x;
			deltay += point.y - previousPoint.y;
			
			previousPoint = point;
			
			// Do the moving thing
			[SWImageTools clearImage:bufferImage];
			clippingRect.origin.x = oldOrigin.x + deltax;
			clippingRect.origin.y = oldOrigin.y + deltay;
			
			// Check for the shift key
//			if (flags & NSShiftKeyMask) {				
//				NSUInteger dx = abs(point.x - previousPoint.x);
//				NSUInteger dy = abs(point.y - previousPoint.y);
//				
//				if (dx > dy) {
//					clippingRect.origin.x -= deltax;
//				} else {
//					clippingRect.origin.y -= deltay;
//				}		
//			}
			
			// The clipping rect is the new redraw rect
			[super addRectToRedrawRect:clippingRect];
			
			// Finally, move the image and stroke it
			[self drawNewBorder:nil];
		} 
		else
			[self tieUpLooseEnds];
	} 
	else
	{
		// Still drawing the dotted line
		deltax = deltay = 0;

		[SWImageTools clearImage:bufferImage];
		
		// Taking care of the outer bounds of the image
		if (point.x < 0)
			point.x = 0.0;
		if (point.y < 0)
			point.y = 0.0;
		if (point.x > [mainImage size].width)
			point.x = [mainImage size].width;
		if (point.y > [mainImage size].height)
			point.y = [mainImage size].height;
				
		// If this check fails, then they didn't draw a rectangle
		if (!NSEqualPoints(point, savedPoint)) 
		{
			// Set the redraw rectangle
			[super addRedrawRectFromPoint:savedPoint toPoint:point];
			
			// Create the clipping rect based on these two new points
			clippingRect = NSMakeRect(fmin(savedPoint.x, point.x), fmin(savedPoint.y, point.y), 
									  abs(point.x - savedPoint.x), abs(point.y - savedPoint.y));

			if (event == MOUSE_UP) 
			{
				// Copy the rectangle's contents to the second image
				originalImageCopy = [[NSBitmapImageRep alloc] initWithData:[mainImage TIFFRepresentation]];
				
				[SWImageTools clearImage:bufferImage];
				
				// Prepare the two image: one with transparency, and one without
				selImageSansTransparency = [SWImageTools cropImage:mainImage toRect:clippingRect];
				selImageWithTransparency = [SWImageTools cropImage:mainImage toRect:clippingRect];
				[SWImageTools stripImage:selImageWithTransparency ofColor:backColor];
				
				// Now if we should, remove the background of the image
				if (shouldOmitBackground) 
					selectedImage = [selImageWithTransparency retain];
				else
					selectedImage = [selImageSansTransparency retain];
				
				// Delete it from the main image
				SWLockFocus(mainImage);
				[backColor set];
				// Note: don't use a bezierpath! It'll fail with clear-ish colors
				NSRectFill(clippingRect);
				SWUnlockFocus(mainImage);
				
				isSelected = YES;
				
			}
			oldOrigin = clippingRect.origin;
			
			// Finally, draw the image and the selection
			[self drawNewBorder:nil];
		}
	}
	return nil;
}

// Tick the timer!
- (void)drawNewBorder:(NSTimer *)timer
{
	dottedLineOffset = (dottedLineOffset + 1) % 8;
	
	// Draw the backed image to the overlay
	if (_bufferImage) 
	{
		[SWImageTools clearImage:_bufferImage];
		SWLockFocus(_bufferImage);
		if (selectedImage)
			[selectedImage drawAtPoint:NSMakePoint(oldOrigin.x + deltax, oldOrigin.y + deltay)];
		
		// Next, stroke it
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		[[NSColor darkGrayColor] setStroke];
		[[self pathFromPoint:clippingRect.origin 
					 toPoint:NSMakePoint(clippingRect.origin.x + clippingRect.size.width, 
										 clippingRect.origin.y + clippingRect.size.height)] stroke];			
		SWUnlockFocus(_bufferImage);
	}
	
	// Get the view to perform a redraw to see the new border
	[NSApp sendAction:@selector(refreshImage:)
				   to:nil
				 from:self];
}

- (void)deleteKey
{
	[selectedImage release];
	[selImageWithTransparency release];
	[selImageSansTransparency release];
	selectedImage = nil;
	selImageWithTransparency = nil;
	selImageSansTransparency = nil;
}


- (void)updateBackgroundOmission
{
	// Switch the image that selectedImage points to, if it exists
	if (shouldOmitBackground)
	{
		[selImageWithTransparency retain];
		[selectedImage release];
		selectedImage = selImageWithTransparency;
	}
	else
	{
		[selImageSansTransparency retain];
		[selectedImage release];
		selectedImage = selImageSansTransparency;
	}
	
	// Update the UI with the new image
	[self drawNewBorder:nil];
}


- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	if (animationTimer) 
	{
		[animationTimer invalidate];
		animationTimer = nil;
	}
	
	// Before making an undo happen, copy _mainImage to mainImageCopy -- the undo-ing process will revert mainImage
	NSBitmapImageRep *mainImageCopy = nil;
	if (_mainImage)
	{
		[SWImageTools initImageRep:&mainImageCopy withSize:[_mainImage size]];
		[SWImageTools drawToImage:mainImageCopy fromImage:_mainImage withComposition:NO];
	}

	// Make an undo happen if there's an active selection
	if (isSelected)
	{
		isSelected = NO;
		if (originalImageCopy)
		{
			// Re-set the _mainImage to originalImageCopy for the undo to work properly
			[SWImageTools drawToImage:_mainImage fromImage:originalImageCopy withComposition:NO];
			[document handleUndoWithImageData:nil frame:NSZeroRect];
			
			// Clean up!
			[originalImageCopy release];
			originalImageCopy = nil;
		}
	}

	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_mainImage)
	{
		[SWImageTools drawToImage:mainImageCopy
						fromImage:selectedImage 
						  atPoint:NSMakePoint(oldOrigin.x + deltax, oldOrigin.y + deltay)
				  withComposition:YES];

		// Redraw the entire image
		[super addRectToRedrawRect:NSMakeRect(0,0,[mainImageCopy size].width,[mainImageCopy size].height)];
		
		// Finally, move all of mainImageCopy to _mainImage
		[SWImageTools drawToImage:_mainImage fromImage:mainImageCopy withComposition:NO];
	} 
	else
		[super resetRedrawRect];
	
	// Now nuke the buffer image
	if (_bufferImage)
	{
		[SWImageTools clearImage:_bufferImage];
		_bufferImage = nil;
	}
	
	// Get rid of references to the selected image
	[self deleteKey];
	
	// Clean up after ourselves
	[mainImageCopy release];
	_mainImage = nil;
}

- (NSRect)clippingRect
{
	return clippingRect;
}

// Called from the PaintView when an image is pasted
- (void)setClippingRect:(NSRect)rect forImage:(NSBitmapImageRep *)image withMainImage:(NSBitmapImageRep *)mainImage
{
	_mainImage = mainImage;
	_bufferImage = image;
	deltax = deltay = 0;
	clippingRect = rect;
	oldOrigin = rect.origin;
	isSelected = YES;
	
	// Create the image to paste
	[SWImageTools initImageRep:&selectedImage withSize:[_bufferImage size]];
	SWLockFocus(selectedImage);
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	// Create the point to paste at
	NSPoint point = NSMakePoint(clippingRect.origin.x, clippingRect.origin.y + (clippingRect.size.height - selectedImage.size.height));
	[image drawAtPoint:point];
	SWUnlockFocus(selectedImage);
	
	// Make the copies of the image for with/without transparency
	selImageSansTransparency = [selectedImage retain];
	[SWImageTools initImageRep:&selImageWithTransparency withSize:[_bufferImage size]];
	[SWImageTools drawToImage:selImageWithTransparency
					fromImage:selImageSansTransparency 
			  withComposition:NO];
	[SWImageTools stripImage:selImageWithTransparency ofColor:backColor];

	// Which one should we be using?  Let this method decide
	[self updateBackgroundOmission];
	
	// Draw the dotted line around the selected region
	[self drawNewBorder:nil];
	
	// Set the redraw rect!
	[super addRectToRedrawRect:clippingRect];
	
	// Manually create the timer
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.075 // 75 ms, or 13.33 Hz
													  target:self
													selector:@selector(drawNewBorder:)
													userInfo:nil
													 repeats:YES];	
}

- (NSData *)imageData
{
	return [originalImageCopy TIFFRepresentation];
}

- (NSBitmapImageRep *)selectedImage
{
	return selectedImage;
}

- (BOOL)isSelected
{
	return isSelected;
}

- (NSCursor *)cursor
{
	if (!customCursor) {
		customCursor = [[NSCursor crosshairCursor] retain];
	}
	return customCursor;
}

// We got better color accuracy in 2.1, so we flipped this back on
- (BOOL)shouldShowTransparencyOptions
{
	return YES;
}

// Overridden for right-click
- (BOOL)shouldShowContextualMenu
{
	return YES;
}

- (NSString *)description
{
	return @"Selection";
}

- (void)dealloc
{
	[toolboxController removeObserver:self forKeyPath:@"selectionTransparency"];
	[originalImageCopy release];
	[selectedImage release];
	[selImageWithTransparency release];
	[selImageSansTransparency release];
	[super dealloc];
}

@end
