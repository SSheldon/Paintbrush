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
