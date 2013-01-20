//
//  SUUpdater.m
//  Paintbrush2
//
//  Created by Mike Schreiber on 1/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SUUpdater.h"


@implementation SUUpdater

- (void)checkForUpdates:(id)sender
{
	// Here we are!  We "respond"
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	// Hide them!  Hide them all!
	[menuItem setHidden:YES];
	return YES;
}

@end
