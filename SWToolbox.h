//
//  SWToolbox.h
//  Paintbrush2
//
//  Created by Mike Schreiber on 1/28/09.
//  Copyright 2009 University of Arizona. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SWToolboxController;


@interface SWToolbox : NSObject {
	NSMutableDictionary *toolList;
	SWToolboxController *sharedController;
}

+ (NSArray *)toolClassList;

@end
