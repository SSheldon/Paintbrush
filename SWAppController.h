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
#import <Sparkle/Sparkle.h>

@class SWPreferenceController;
@class SWToolboxController;

extern NSString * const kSWUndoKey;

@interface SWAppController : NSObject
{
	SWPreferenceController *preferenceController;
}
- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showToolboxPanel:(id)sender;
//- (IBAction)showGridPanel:(id)sender;

// A few methods to open a web page in the user's browser of choice
- (IBAction)donate:(id)sender;
- (IBAction)forums:(id)sender;
- (IBAction)contact:(id)sender;

// Overrides "Quit" to remove a sheet, if present
- (IBAction)quit:(id)sender;
- (IBAction)newFromClipboard:(id)sender;


@end
