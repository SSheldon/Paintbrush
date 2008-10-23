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
		isSelected = NO;
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
	[path setLineWidth:0.0];
	CGFloat array[2];
	array[0] = 5.0;
	array[1] = 3.0;
	[path setLineDash:array count:2 phase:5.0];
	[path setLineCapStyle:NSSquareLineCapStyle];	

	//if (flags & NSShiftKeyMask) {
		// CGFloat size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		// We need something here! It's trickier than it looks.
	//} else {
		clippingRect = NSMakeRect(fmin(begin.x, end.x), fmin(begin.y, end.y), abs(end.x - begin.x), abs(end.y - begin.y));
	//}
	
	[path appendBezierPathWithRect:
		NSMakeRect(clippingRect.origin.x, clippingRect.origin.y, clippingRect.size.width-1, clippingRect.size.height-1)];

	return path;	
}

- (void)performDrawAtPoint:(NSPoint)point 
			 withMainImage:(NSImage *)anImage 
			   secondImage:(NSImage *)secondImage 
				mouseEvent:(SWMouseEvent)event
{	
	_secondImage = secondImage;
	_anImage = anImage;
	
	// If the rectangle has already been drawn
	if (isSelected) {
		if (event == MOUSE_DRAGGED || [[NSBezierPath bezierPathWithRect:clippingRect] containsPoint:point]) {
			if (event == MOUSE_DOWN) {
				previousPoint = point;
			}
			
			if (flags & NSShiftKeyMask) {				
				// Are we already moving horizontally/vertically?
				if (isAlreadyShifting) {
					if (direction == 'X') {
						deltay = 0;
						deltax += point.x - previousPoint.x;
					} else if (direction == 'Y') {
						deltax = 0;
						deltay += point.y - previousPoint.y;
					} else {
						NSLog(@"Houston, we have a problem");
					}
				} else {
					isAlreadyShifting = YES;
					NSUInteger dx = abs(point.x - previousPoint.x);
					NSUInteger dy = abs(point.y - previousPoint.y);
					
					if (dx > dy) {
						direction = 'X';
					} else {
						direction = 'Y';
					}
				}			
			} else {
				isAlreadyShifting = NO;
				deltax += point.x - previousPoint.x;
				deltay += point.y - previousPoint.y;
			}
			
			previousPoint = point;
			
			// Do the moving thing
			
			// This loop removes all the representations in the overlay image, effectively clearing it
			for (NSImageRep *rep in [secondImage representations]) {
				[secondImage removeRepresentation:rep];
			}
			
			clippingRect.origin.x = oldOrigin.x + deltax;
			clippingRect.origin.y = oldOrigin.y + deltay;
			
			// The clipping rect is the new redraw rect
			[super addRectToRedrawRect:clippingRect];
			
			[secondImage lockFocus];
//			[outlinedImage drawAtPoint:NSMakePoint(deltax, deltay)
//						   fromRect:NSZeroRect
//						  operation:NSCompositeSourceOver
//						   fraction:1.0];
			NSPoint p1 = NSMakePoint(deltax, deltay);
			[backedImage drawAtPoint:p1
							fromRect:NSZeroRect
						   operation:NSCompositeSourceOver
							fraction:1.0];
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor darkGrayColor] setStroke];
			[[self pathFromPoint:clippingRect.origin 
						 toPoint:NSMakePoint(clippingRect.origin.x + clippingRect.size.width, 
											 clippingRect.origin.y + clippingRect.size.height)] stroke];			
			[secondImage unlockFocus];
			
		} else {
			[self tieUpLooseEnds];
		}
		
	} else {
		// Still drawing the dotted line
		deltax = deltay = 0;

		// This loop removes all the representations in the overlay image, effectively clearing it
		for (NSImageRep *rep in [secondImage representations]) {
			[secondImage removeRepresentation:rep];
		}
		
		// Taking care of the outer bounds of the image
		if (point.x < 0)
			point.x = 0.0;
		if (point.y < 0)
			point.y = 0.0;
		if (point.x > [anImage size].width)
			point.x = [anImage size].width;
		if (point.y > [anImage size].height)
			point.y = [anImage size].height;
		
		if ((point.x != savedPoint.x) && (point.y != savedPoint.y)) {
			// Set the redraw rectangle
			[super setRedrawRectFromPoint:savedPoint toPoint:point];
			
			// Draw the dotted line
			[secondImage lockFocus]; 
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor darkGrayColor] setStroke];
			[[self pathFromPoint:savedPoint toPoint:point] stroke];
			[secondImage unlockFocus];
		}
				
		if ((event == MOUSE_UP) && (point.x != savedPoint.x) && (point.y != savedPoint.y)) {
			// Copy the rectangle's contents to the second image
			
			imageRep = [[NSBitmapImageRep alloc] initWithData:[anImage TIFFRepresentation]];
			
			// This loop removes all the representations in the overlay image, effectively clearing it
			for (NSImageRep *rep in [secondImage representations]) {
				[secondImage removeRepresentation:rep];
			}
			
			[secondImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

			if (shouldOmitBackground) {
				// EXPERIMENTAL: Transparency
				// TODO: Faster, and possibly somewhere else?
				NSInteger x, y;
				NSBitmapImageRep *secondRep = [NSBitmapImageRep imageRepWithData:[secondImage TIFFRepresentation]];
				for (x = clippingRect.origin.x; x < (clippingRect.origin.x + clippingRect.size.width); x++) {
					for (y = ([secondRep pixelsHigh] - clippingRect.origin.y - 1); 
						 y >= [secondRep pixelsHigh] - (clippingRect.origin.y + clippingRect.size.height); y--) {
						if (!colorsAreEqual(backColor, [imageRep colorAtX:x y:y])) {
							[secondRep setColor:[imageRep colorAtX:x y:y] atX:x y:y];
						}
					}
				}
				[secondRep drawAtPoint:NSZeroPoint];
				
			} else {
				// This is without transparency, and is much faster
				[anImage drawInRect:clippingRect
						   fromRect:clippingRect
						  operation:NSCompositeSourceOver 
						   fraction:1.0];				
			}
			[secondImage unlockFocus];
			
			backedImage = [[NSImage alloc] initWithSize:[anImage size]];
			[backedImage lockFocus];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[secondImage drawInRect:clippingRect
						   fromRect:clippingRect
						  operation:NSCompositeSourceOver 
						   fraction:1.0];
			[backedImage unlockFocus];
			
			[secondImage lockFocus];
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor darkGrayColor] setStroke];
			[[self pathFromPoint:savedPoint toPoint:point] stroke];
			[secondImage unlockFocus];

//			outlinedImage = [[NSImage alloc] initWithSize:[anImage size]];
//			[outlinedImage lockFocus];
//			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
//			[secondImage drawAtPoint:NSZeroPoint
//							fromRect:NSZeroRect
//						   operation:NSCompositeSourceOver
//							fraction:1.0];
//			[outlinedImage unlockFocus];
						
			// Delete it from the main image
			[anImage lockFocus];
			
			// The best way I can come up with to clear the image
//			[[NSColor clearColor] setFill];
//			NSRectFill(NSMakeRect(0,0,[anImage size].width, [anImage size].height));
			
			[backColor set];
			[NSBezierPath fillRect:clippingRect];
			[anImage unlockFocus];
			
			oldOrigin = clippingRect.origin;
			
			isSelected = YES;
		}
	}
}

- (void)tieUpLooseEnds
{
	[super tieUpLooseEnds];
	
	isSelected = NO;
	if (imageRep /*&& !NSEqualPoints(oldOrigin, clippingRect.origin)*/ ) {
		//NSLog(@"%@", imageRep);
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:[NSDictionary dictionaryWithObject:[imageRep TIFFRepresentation] forKey:@"Image"]];
	}
	
	// Checking to see if references have been made; otherwise causes strange drawing bugs
	if (_secondImage && _anImage && [[_secondImage representations] count] > 0) {
		// This loop removes all the representations in the overlay image, effectively clearing it
		for (NSImageRep *rep in [_secondImage representations]) {
			[_secondImage removeRepresentation:rep];
		}
		[_anImage lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		
		NSRect selectedRect = NSMakeRect(oldOrigin.x, oldOrigin.y, clippingRect.size.width, clippingRect.size.height);
		
		[backedImage drawInRect:clippingRect
						fromRect:selectedRect
					   operation:NSCompositeSourceOver
						fraction:1.0];
		
		[_anImage unlockFocus];

		[super addRectToRedrawRect:NSMakeRect(0,0,[_anImage size].width,[_anImage size].height)];
	} else {
		[super resetRedrawRect];
	}	
}

- (NSRect)clippingRect
{
	return clippingRect;
}

// Called from the PaintView when an image is pasted
- (void)setClippingRect:(NSRect)rect forImage:(NSImage *)image
{	
	_secondImage = image;
	deltax = deltay = 0;
	clippingRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	oldOrigin = NSMakePoint(rect.origin.x, rect.origin.y);
	isSelected = YES;
	
	// Create the image to paste
	backedImage = [[NSImage alloc] initWithSize:[image size]];
	[backedImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	[image drawInRect:clippingRect
			   fromRect:clippingRect
			  operation:NSCompositeSourceOver 
			   fraction:1.0];
	[backedImage unlockFocus];
	
	// Draw the dotted line around the selected region
	[image lockFocus];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[[NSColor darkGrayColor] setStroke];
	[[self pathFromPoint:rect.origin
				 toPoint:NSMakePoint(rect.size.width+rect.origin.x,rect.size.height+rect.origin.y)] stroke];
	[image unlockFocus];
	
	// Copy that image somewhere else
//	outlinedImage = [[NSImage alloc] initWithSize:[image size]];
//	[outlinedImage lockFocus];
//	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
//	[image drawAtPoint:NSZeroPoint
//			  fromRect:NSZeroRect
//			 operation:NSCompositeSourceOver
//			  fraction:1.0];
//	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
//	[[NSColor darkGrayColor] setStroke];
//	[outlinedImage unlockFocus];
}

- (NSData *)imageData
{
	return [imageRep TIFFRepresentation];
}

- (NSImage *)backedImage
{
	return backedImage;
}

- (BOOL)isSelected
{
	return isSelected;
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

// Once we get better color accuracy (hopefully in 2.1), we'll flip this back on
- (BOOL)shouldShowTransparencyOptions
{
	//return YES;
	return NO;
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

@end
