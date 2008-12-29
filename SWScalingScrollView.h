/**
 * Copyright 2007-2009 Soggy Waffles
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


#import <Cocoa/Cocoa.h>

@class NSPopUpButton;

@interface SWScalingScrollView : NSScrollView {
    NSPopUpButton *scalePopUpButton;
    CGFloat scaleFactor;
}

- (void)scalePopUpAction:(id)sender;
- (void)setScaleFactor:(CGFloat)factor adjustPopup:(BOOL)flag;
- (void)setScaleFactor:(CGFloat)factor atPoint:(NSPoint)point adjustPopup:(BOOL)flag;
- (CGFloat)scaleFactor;

@end
