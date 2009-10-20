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


#import "SWSelectionTool.h"
#import "SWToolboxController.h"

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
	
	if ([keyPath isEqualToString:@"selectionTransparency"]) {
		shouldOmitBackground = [thing boolValue];
	}
}

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:1.0];
	[path setLineDash:dottedLineArray count:2 phase:dottedLineOffset];
	[path setLineCapStyle:NSSquareLineCapStyle];	

	//if (flags & NSShiftKeyMask) {
		// CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		// We need something here! It's trickier than it looks.
	//} else {
		clippingRect = NSMakeRect(fmin(begin.x, end.x), fmin(begin.y, end.y), abs(end.x - begin.x), abs(end.y - begin.y));
	//}
	
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
	if (event == MOUSE_DOWN && animationTimer) {
		[animationTimer invalidate];
		animationTimer = nil;
	} else if (event == MOUSE_UP && !NSEqualPoints(point, savedPoint)) {
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.075 // 75 ms, or 13.33 Hz
														  target:self
														selector:@selector(drawNewBorder:)
														userInfo:nil
														 repeats:YES];		
	} 
	
	// If the rectangle has already been drawn
	if (isSelected) {
		// We checked for the drag because it's possible that the cursor has been dragged outside the 
		// clipping rect in one single event
		if (event == MOUSE_DRAGGED || [[NSBezierPath bezierPathWithRect:clippingRect] containsPoint:point]) {
			if (event == MOUSE_DOWN) {
				previousPoint = point;
			}
			
			if (flags & NSShiftKeyMask) {				
				// Are we already moving horizontally/vertically?
				if (!isAlreadyShifting) {
					isAlreadyShifting = YES;
					NSUInteger dx = abs(point.x - previousPoint.x);
					NSUInteger dy = abs(point.y - previousPoint.y);
					
					if (dx > dy) {
						direction = 'X';
					} else {
						direction = 'Y';
					}
				} else {
					if (direction == 'X') {
						deltay = 0;
						deltax += point.x - previousPoint.x;
					} else if (direction == 'Y') {
						deltax = 0;
						deltay += point.y - previousPoint.y;
					} else {
						NSLog(@"Houston, we have a problem");
					}
				}			
			} else {
				isAlreadyShifting = NO;
				deltax += point.x - previousPoint.x;
				deltay += point.y - previousPoint.y;
			}
			
			previousPoint = point;
			
			// Do the moving thing
			[SWImageTools clearImage:bufferImage];
			
			clippingRect.origin.x = oldOrigin.x + deltax;
			clippingRect.origin.y = oldOrigin.y + deltay;
			
			// The clipping rect is the new redraw rect
			[super addRectToRedrawRect:clippingRect];
			
			// Finally, move the image and stroke it
			[self drawNewBorder:nil];
		} else {
			[self tieUpLooseEnds];
		}
		
	} else {
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
		if (!NSEqualPoints(point, savedPoint)) {
			
			// Set the redraw rectangle
			[super addRedrawRectFromPoint:savedPoint toPoint:point];
			
			// Draw the dotted line
			SWLockFocus(bufferImage); 
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor darkGrayColor] setStroke];
			[[self pathFromPoint:savedPoint toPoint:point] stroke];
			SWUnlockFocus(bufferImage);
				
			if (event == MOUSE_UP) {
				// Copy the rectangle's contents to the second image
				
				imageRep = [[NSBitmapImageRep alloc] initWithData:[mainImage TIFFRepresentation]];
				
				[SWImageTools clearImage:bufferImage];
				
//				backedImage = [[NSBitmapImageRep alloc] initWithSize:[mainImage size]];
				[SWImageTools initImageRep:&backedImage withSize:[mainImage size]];
				SWLockFocus(backedImage);

				[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

//				if (shouldOmitBackground) {
					// EXPERIMENTAL: Transparency
					// TODO: Faster, and possibly somewhere else?
					NSInteger x, y;
					NSBitmapImageRep *secondRep = [NSBitmapImageRep imageRepWithData:[bufferImage TIFFRepresentation]];
					for (x = clippingRect.origin.x; x < (clippingRect.origin.x + clippingRect.size.width); x++) {
						for (y = ([secondRep pixelsHigh] - clippingRect.origin.y - 1); 
							 y >= [secondRep pixelsHigh] - (clippingRect.origin.y + clippingRect.size.height); y--) {
							if (!shouldOmitBackground || !colorsAreEqual(backColor, [imageRep colorAtX:x y:y])) {
								[secondRep setColor:[imageRep colorAtX:x y:y] atX:x y:y];
							}
						}
					}
					[secondRep drawAtPoint:NSZeroPoint];
					
//				} else {
//					// This is without transparency, and is much faster
//					[mainImage drawInRect:clippingRect
//							   fromRect:clippingRect
//							  operation:NSCompositeSourceOver 
//							   fraction:1.0];				
//				}

				SWUnlockFocus(backedImage);
				
				[self drawNewBorder:nil];

				// Delete it from the main image
				SWLockFocus(mainImage);
				
				[backColor set];
				
				// Note: don't use a bezierpath! It'll fail with clear-ish colors
				NSRectFill(clippingRect);
				SWUnlockFocus(mainImage);
				
				oldOrigin = clippingRect.origin;
				
				isSelected = YES;
			}
		}
	}
//	return [self pathFromPoint:clippingRect.origin 
//					   toPoint:NSMakePoint(clippingRect.origin.x + clippingRect.size.width, 
//										   clippingRect.origin.y + clippingRect.size.height)];
	return nil;
}

// Tick the timer!
- (void)drawNewBorder:(NSTimer *)timer
{
	dottedLineOffset = (dottedLineOffset + 1) % 8;
	
	// Draw the backed image to the overlay
	if (_bufferImage) {
		[SWImageTools clearImage:_bufferImage];
		SWLockFocus(_bufferImage);
		if (backedImage) {
			[backedImage drawAtPoint:NSMakePoint(deltax, deltay)];			
		}
		
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
	[backedImage release];
	backedImage = nil;//[self tieUpLooseEnds];
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	if (animationTimer) {
		[animationTimer invalidate];
		animationTimer = nil;
	}
	isSelected = NO;
	if (imageRep /*&& !NSEqualPoints(oldOrigin, clippingRect.origin)*/ ) {
		//NSLog(@"%@", imageRep);
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:[NSDictionary dictionaryWithObject:[imageRep TIFFRepresentation] forKey:@"Image"]];
	}

	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_bufferImage && _mainImage) {
		[SWImageTools clearImage:_bufferImage];

//		SWLockFocus(_mainImage);
//		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
//		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceOver];
//		
////		NSRect selectedRect = {
////			oldOrigin,
////			clippingRect.size
////		};
//		//NSMakeRect(oldOrigin.x, oldOrigin.y, clippingRect.size.width, clippingRect.size.height);
//		
////		[backedImage drawInRect:clippingRect
////						fromRect:selectedRect
////					   operation:NSCompositeSourceOver
////						fraction:1.0];
//		[backedImage drawAtPoint:NSMakePoint(deltax, deltay)];
//		
//		[backedImage release];
//		backedImage = nil;
//		
//		SWUnlockFocus(_mainImage);
		[SWImageTools drawToImage:_mainImage
						fromImage:backedImage 
						  atPoint:NSMakePoint(deltax, deltay)
				  withComposition:YES];

		// Redraw the entire image
		[super addRectToRedrawRect:NSMakeRect(0,0,[_mainImage size].width,[_mainImage size].height)];
	} else {
		[super resetRedrawRect];
	}	
}

- (NSRect)clippingRect
{
	return clippingRect;
}

// Called from the PaintView when an image is pasted
- (void)setClippingRect:(NSRect)rect forImage:(NSBitmapImageRep *)image
{	
	_bufferImage = image;
	deltax = deltay = 0;
	clippingRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	oldOrigin = NSMakePoint(rect.origin.x, rect.origin.y);
	isSelected = YES;
	
	// Create the image to paste
//	backedImage = [[NSBitmapImageRep alloc] initWithSize:[image size]];
	[SWImageTools initImageRep:&backedImage withSize:[image size]];
	SWLockFocus(backedImage);
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
//	[image drawInRect:clippingRect
//			   fromRect:clippingRect
//			  operation:NSCompositeSourceOver 
//			   fraction:1.0];
	SWUnlockFocus(backedImage);
	
	// Draw the dotted line around the selected region
	SWLockFocus(image);
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[[NSColor darkGrayColor] setStroke];
	[[self pathFromPoint:rect.origin
				 toPoint:NSMakePoint(rect.size.width+rect.origin.x,rect.size.height+rect.origin.y)] stroke];
	SWUnlockFocus(image);
	
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
	return [imageRep TIFFRepresentation];
}

- (NSBitmapImageRep *)backedImage
{
	return backedImage;
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
	return NO;
}

- (NSString *)description
{
	return @"Selection";
}

- (void)dealloc
{
	[toolboxController removeObserver:self forKeyPath:@"selectionTransparency"];
	[imageRep release];
	[backedImage release];
	[super dealloc];
}

@end
