/**
 * Copyright 2007, 2008 Soggy Waffles
 *
 * This file is part of Paintbrush.
 *
 * Paintbrush is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */


#import "SWGridPanelController.h"
#import "SWDocument.h"

@implementation SWGridPanelController
+ (id)sharedGridPanelController {
    static SWGridPanelController *sharedGridPanelController = nil;

    if (!sharedGridPanelController) {
        sharedGridPanelController = [[SWGridPanelController allocWithZone:nil] init];
    }

    return sharedGridPanelController;
}

- (id)init {
    self = [self initWithWindowNibName:@"GridPanel"];
    if (self) {
        [self setWindowFrameAutosaveName:@"Grid"];
    }
    return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	// Floats and doesn't become key, because the PaintView does not accept click-through
	[(NSPanel *)[self window] setFloatingPanel:YES];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    [self setMainWindow:[NSApp mainWindow]];
	
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(mainWindowChanged:) 
												 name:NSWindowDidBecomeMainNotification 
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(mainWindowResigned:) 
												 name:NSWindowDidResignMainNotification 
											   object:nil];
}

// It notices when a different document is the main window
- (void)setMainWindow:(NSWindow *)mainWindow {
	NSDocumentController *controller = [NSDocumentController sharedDocumentController];
	id document = [controller documentForWindow: mainWindow];
	
	// If it's a Paintbrush document, get its PaintView
	if (document && [document isKindOfClass:[SWDocument class]]) {
		_inspectingPaintView = [document paintView];
	} else {
		_inspectingPaintView = nil;
	}

    [self updatePanel];
}

- (void)mainWindowChanged:(NSNotification *)notification {
    [self setMainWindow:[notification object]];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    [self setMainWindow:nil];
}

- (void)updatePanel {
    if ([self isWindowLoaded]) {
        BOOL hasGraphicView = ((_inspectingPaintView == nil) ? NO : YES);
        [showsGridCheckbox setState:([self showsGrid] ? NSOnState : NSOffState)];
        [gridSpacingSlider setFloatValue:[self gridSpacing]];
        [gridColorWell setColor:[self gridColor]];
        [showsGridCheckbox setEnabled:hasGraphicView];
        [gridSpacingSlider setEnabled:hasGraphicView];
        [gridColorWell setEnabled:hasGraphicView];
        [gridView setNeedsDisplay:YES];
    }
}

//////////////////////////////////////////////////////////////////////
- (BOOL)showsGrid {
    return (_inspectingPaintView ? [_inspectingPaintView showsGrid] : NO);
}

- (CGFloat)gridSpacing {
    return (_inspectingPaintView ? [_inspectingPaintView gridSpacing] : 8);
}

- (NSColor *)gridColor {
    return (_inspectingPaintView ? [_inspectingPaintView gridColor] : [NSColor gridColor]);
}

- (IBAction)showsGridCheckboxAction:(id)sender {
    if (_inspectingPaintView) {
        [_inspectingPaintView setShowsGrid:[sender state]];
	}
}

- (IBAction)gridSpacingSliderAction:(id)sender {
    if (_inspectingPaintView) {
        [_inspectingPaintView setGridSpacing:(CGFloat)[sender floatValue]];
    }
    [gridView setNeedsDisplay:YES];
}

- (IBAction)gridColorWellAction:(id)sender {
    if (_inspectingPaintView) {
        [_inspectingPaintView setGridColor:[sender color]];
    }
    [gridView setNeedsDisplay:YES];
}

- (IBAction)showWindow:(id)sender {
	//[[self window] makeKeyAndOrderFront: sender];
	
	// We don't want the GridPanel to ever become key window - EVER!!!
	[[self window] orderFront:sender];
    [self updatePanel];
}

- (IBAction)hideWindow:(id)sender {
	[[self window] orderOut:sender];
}

@end
