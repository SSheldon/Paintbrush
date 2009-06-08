//
//  SWToolbox.m
//  Paintbrush2
//
//  Created by Mike Schreiber on 1/28/09.
//  Copyright 2009 University of Arizona. All rights reserved.
//

#import "SWToolbox.h"
#import "SWToolList.h"
#import "SWToolboxController.h"

@implementation SWToolbox


- (id)init
{
	self = [super init];
	
	sharedController = [SWToolboxController sharedToolboxPanelController];
	
	// Create the dictionary
	toolList = [[NSMutableDictionary alloc] initWithCapacity:14];
	for (SWTool *tool in [sharedController toolListArray]) {
		[toolList setObject:tool forKey:[tool description]];
	}
	
	[sharedController addObserver:self 
					   forKeyPath:@"currentTool" 
						  options:NSKeyValueObservingOptionNew 
						  context:NULL];
	
	return self;
}


// Something happened!
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	id thing = [change objectForKey:NSKeyValueChangeNewKey];
	
	if ([keyPath isEqualToString:@"currentTool"]) {
		NSLog(@"New tool change - %@!", thing);
	}
}

+ (NSArray *)toolClassList
{
	return [NSArray arrayWithObjects:[SWBrushTool class], [SWEraserTool class], [SWSelectionTool class], 
			[SWAirbrushTool class], [SWFillTool class], [SWBombTool class], [SWLineTool class], 
			[SWCurveTool class], [SWRectangleTool class], [SWEllipseTool class], [SWRoundedRectangleTool class], 
			[SWTextTool class], [SWEyeDropperTool class], [SWZoomTool class], nil];
}


// Don't forget to remove my registration to the toolbox controller!
- (void)dealloc
{
	[sharedController removeObserver:self forKeyPath:@"currentTool"];
	[super dealloc];
}

@end
