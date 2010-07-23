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
