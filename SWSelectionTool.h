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


#import <Cocoa/Cocoa.h>
#import "SWTool.h"

@interface SWSelectionTool : SWTool {
	NSRect clippingRect;
	NSBitmapImageRep *backedImage/*, *outlinedImage*/;
	NSTimer *animationTimer;
	CGFloat dottedLineArray[2];
	NSInteger dottedLineOffset;
	NSBitmapImageRep *imageRep;
	NSPoint previousPoint;
	NSPoint oldOrigin;
	BOOL isSelected;
	BOOL isAlreadyShifting;
	NSInteger deltax, deltay;
	char direction;					// Either X or Y
	
	BOOL shouldOmitBackground;
}

- (BOOL)isSelected;
- (NSRect)clippingRect;
- (NSBitmapImageRep *)backedImage;
- (NSData *)imageData;
- (void)setClippingRect:(NSRect)rect forImage:(NSBitmapImageRep *)image;
- (void)drawNewBorder:(NSTimer *)timer;

@property (assign, readonly) NSPoint oldOrigin;

@end
