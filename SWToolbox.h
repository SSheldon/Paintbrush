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
@class SWDocument;

@interface SWToolbox : NSObject 
{
	NSMutableDictionary *toolList;
	SWToolboxController *sharedController;
	
	// The currently-selected tool
	SWTool *currentTool;
}

@property (retain) SWTool *currentTool;

- (id)initWithDocument:(SWDocument *)doc;
+ (NSArray *)toolClassList;
- (SWTool *)toolForLabel:(NSString *)label;
- (void)tieUpLooseEndsForCurrentTool;

@end
