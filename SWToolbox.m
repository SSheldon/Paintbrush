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
#import "SWPaintView.h"
#import "SWDocument.h"

@implementation SWToolbox

@synthesize currentTool;

- (id)initWithDocument:(SWDocument *)doc
{
	self = [super init];
	
	sharedController = [SWToolboxController sharedToolboxPanelController];
	
	// Create the dictionary
	toolList = [[NSMutableDictionary alloc] initWithCapacity:14];
	for (Class c in [SWToolbox toolClassList]) 
	{
		SWTool *tool = [[c alloc] initWithController:sharedController];
		[tool setDocument:doc];
		[toolList setObject:tool forKey:[tool description]];
	}
	
	[sharedController addObserver:self 
					   forKeyPath:@"currentTool" 
						  options:NSKeyValueObservingOptionNew 
						  context:NULL];
	
	// Set the initial tool info
	[sharedController updateInfo];
	
	return self;
}


// Don't forget to remove my registration to the toolbox controller!
- (void)dealloc
{
	[sharedController removeObserver:self forKeyPath:@"currentTool"];
	for (id key in toolList) {
		[[toolList objectForKey:key] release];
	}
	[toolList release];
	[currentTool release];
	[super dealloc];
}


// Here's the setter for the tool: make sure you wrap up loose ends for the previous tool!
- (void)setCurrentTool:(SWTool *)tool
{
	[currentTool tieUpLooseEnds];
	[tool retain];
	[currentTool release];
	currentTool = tool;
    
    
    SWToolboxController *controller = [SWToolboxController sharedToolboxPanelController];
    SWDocument *document = [controller activeDocument];
    SWPaintView *view = [document paintView];
    [view cursorUpdate:nil];
    
}


// Something happened!
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	id thing = [change objectForKey:NSKeyValueChangeNewKey];
	
	if ([keyPath isEqualToString:@"currentTool"]) {
		SWTool *tool = [self toolForLabel:thing];
		if (tool) {
			[self setCurrentTool:tool];
		}
	}
}


// Which tool comes from which label?
- (SWTool *)toolForLabel:(NSString *)label
{
	return [toolList objectForKey:[NSString stringWithString:label]];
}


+ (NSArray *)toolClassList
{
	return [NSArray arrayWithObjects:[SWBrushTool class], [SWEraserTool class], [SWSelectionTool class], 
			[SWAirbrushTool class], [SWFillTool class], [SWBombTool class], [SWLineTool class], 
			[SWCurveTool class], [SWRectangleTool class], [SWEllipseTool class], [SWRoundedRectangleTool class], 
			[SWTextTool class], [SWEyeDropperTool class], [SWZoomTool class], nil];
}


- (void)tieUpLooseEndsForCurrentTool
{
	[currentTool tieUpLooseEnds];
}


@end
