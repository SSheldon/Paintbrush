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


#import "SWPrintPanelAccessoryViewController.h"


@implementation SWPrintPanelAccessoryViewController

- (IBAction)changeScaling:(id)sender
{
    [self setScaling:[sender state] ? YES : NO];
}


- (void)setRepresentedObject:(id)printInfo 
{
    [super setRepresentedObject:printInfo];
	NSNumber * shouldScaleValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"ScaleImageToFitPage"];
	BOOL shouldScale = YES;
	if (shouldScaleValue != nil)
		shouldScale = [shouldScaleValue boolValue];
    [self setScaling:shouldScale];
}


- (void)setScaling:(BOOL)flag
{
	NSPrintInfo *printInfo = [self representedObject];
    [[printInfo dictionary] setObject:[NSNumber numberWithInteger:(flag ? NSFitPagination : NSAutoPagination)] 
							   forKey:NSPrintHorizontalPagination];
    [[printInfo dictionary] setObject:[NSNumber numberWithInteger:(flag ? NSFitPagination : NSAutoPagination)] 
							   forKey:NSPrintVerticalPagination];	
}


- (BOOL)scaling
{
	NSPrintInfo *printInfo = [self representedObject];
    return ( [[[printInfo dictionary] objectForKey:NSPrintVerticalPagination] integerValue] ) == NSFitPagination;
}


- (NSArray *)localizedSummaryItems
{
    return [NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
			 NSLocalizedString(@"Scaling", @"Print panel summary item title for whether the image should be scaled down to fit on a page"), NSPrintPanelAccessorySummaryItemNameKey,
			 [self scaling] ? NSLocalizedString(@"On", @"Print panel summary value when scaling is on") : NSLocalizedString(@"Off", @"Print panel summary value when scaling is off"), NSPrintPanelAccessorySummaryItemDescriptionKey,
			 nil]];	
}


- (NSSet *)keyPathsForValuesAffectingPreview
{
    return [NSSet setWithObject:@"scaling"];
}
@end
