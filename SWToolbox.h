//
//  SWToolbox.h
//  Paintbrush2
//
//  Created by Mike Schreiber on 1/28/09.
//  Copyright 2009 University of Arizona. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SWToolboxController;
@class SWTool;

@interface SWToolbox : NSObject {
	NSMutableDictionary *toolList;
	SWToolboxController *sharedController;
	
	// The currently-selected tool
	SWTool *currentTool;
}

+ (NSArray *)toolClassList;
- (SWTool *)toolForLabel:(NSString *)label;

@property (retain) SWTool *currentTool;

@end
