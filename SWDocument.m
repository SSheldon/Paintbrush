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


#import "SWDocument.h"
#import "SWImageManipulator.h"
#import "SWPaintView.h"
#import "SWScalingScrollView.h"
#import "SWCenteringClipView.h"
#import "SWToolboxController.h"
#import "SWTextToolWindowController.h"
#import "SWSizeWindowController.h"
#import "SWToolList.h"

@implementation SWDocument

- (id)init
{
    if (self = [super init]) {
		
		// Observers for the toolbox
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(showTextSheet:)
				   name:@"SWText"
				 object:nil];
	}
    return self;
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

	if (!sizeController) {
		sizeController = [[SWSizeWindowController alloc] init];
	}
	toolboxController = [SWToolboxController sharedToolboxPanelController];
	
	clipView = [[SWCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	//[clipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[clipView setBackgroundColor:[NSColor gridColor]];
	
	// The Scroll View contains the clip view, which is the superclass of the paint view (whew!)
	[scrollView setContentView:(NSClipView *)clipView];
	[clipView setDocumentView:paintView];
	[scrollView setScaleFactor:1.0 adjustPopup:YES];
		
	// If the user opened an image
	if (openedImage) {
		openingRect.origin = NSZeroPoint;
		openingRect.size = [openedImage size];
		[paintView initWithFrame:openingRect];
		// Use external method to determine the window bounds
		NSRect tempRect = [paintView calculateWindowBounds:openingRect];
		
		// Apply the changes to the new document
		[[paintView window] setFrame:tempRect display:YES];
		
		[paintView setImage:openedImage scale:NO];
	} else {
		[super showWindows];
		[self raiseSizeSheet:aController];
	}
}


#pragma mark Sheets - Size and Text

////////////////////////////////////////////////////////////////////////////////
//////////		Sheets - Size and Text
////////////////////////////////////////////////////////////////////////////////


// Called when a new document is made, and when the user resizes the canvas/image
- (IBAction)raiseSizeSheet:(id)sender
{
	// Sender tag: 1 == image, 0 == canvas
	if ([[sender class] isEqualTo: [NSMenuItem class]]) {
		[sizeController setScales:[sender tag]];
	}
    [NSApp beginSheet:[sizeController window]
	   modalForWindow:[super windowForSheet]
		modalDelegate:self
	   didEndSelector:@selector(sizeSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


// After the sheet ends, this takes over. If the user clicked "OK", a new
// PaintView is initialized. Otherwise, the window closes.
- (void)sizeSheetDidEnd:(NSWindow *)sheet
		 returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		openingRect.origin = NSZeroPoint;
		openingRect.size.width = [sizeController width];
		openingRect.size.height = [sizeController height];
		if ([paintView hasRun]) {
			NSLog(@"Resizing");
			// Trying to resize the image!
			NSImage *backupImage = contextInfo ? (NSImage *)contextInfo : [paintView mainImage];

			// Nothing to do if the size isn't changing!
			if ([[paintView mainImage] size].width != openingRect.size.width || 
				[[paintView mainImage] size].height != openingRect.size.height) {
				NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithDouble:[backupImage size].width], @"Width", 
								   [NSNumber numberWithDouble:[backupImage size].height], @"Height", nil];
				[paintView prepUndo:d];
				paintView = [paintView initWithFrame:openingRect];
				
				// Use external method to determine the window bounds
				NSRect tempRect = [paintView calculateWindowBounds:openingRect];
				[[[paintView window] animator] setFrame:tempRect display:YES];
				[paintView setImage:backupImage scale:[sizeController scales]];
			}
		} else {
			// Initial creation
			paintView = [paintView initWithFrame:openingRect];
			
			// Use external method to determine the window bounds
			NSRect tempRect = [paintView calculateWindowBounds:openingRect];
			[[[paintView window] animator] setFrame:tempRect display:YES];
		}
	} else if (returnCode == NSCancelButton) {
		// Close the document - they obviously don't want to play
		if (![paintView hasRun]) {
			[[super windowForSheet] close];
		}
	}
}

- (IBAction)showTextSheet:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		if (!textController) {
			textController = [[SWTextToolWindowController alloc] init];
		}
		
		// Orders the font manager to the front
		[NSApp beginSheet:[textController window]
		   modalForWindow:[super windowForSheet]
			modalDelegate:self
		   didEndSelector:@selector(textSheetDidEnd:string:)
			  contextInfo:NULL];
		
		[[NSFontManager sharedFontManager] orderFrontFontPanel:self];
		
		// Assigns the current front color (according to the sharedColorPanel) 
		// to the frontColor reference
		[[NSColorPanel sharedColorPanel] setColor:[sender object]];
		
	}
}

- (void)textSheetDidEnd:(NSWindow *)sheet
				 string:(NSString *)string
{
	// Orders the font manager to exit
	[[[NSFontManager sharedFontManager] fontPanel:NO] orderOut:self];
}

- (SWPaintView *)paintView {
	return paintView;
}


#pragma mark Menu actions (Open, Save, Cut, Print, et cetera)

////////////////////////////////////////////////////////////////////////////////
//////////		Menu actions (Open, Save, Cut, Print, et cetera)
////////////////////////////////////////////////////////////////////////////////


// Override to ensure that the user's file type is set
- (IBAction)saveDocument:(id)sender
{
	[self setFileType:[[NSUserDefaults standardUserDefaults] valueForKey:@"FileType"]];
	[super saveDocument:sender];
}

// Saving data: returns the correctly-formatted image data
- (NSData *)dataOfType:(NSString *)aType error:(NSError *)anError
{
	NSData *data;
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithData:[[paintView mainImage] TIFFRepresentation]];
	if ([aType isEqualToString:@"BMP"]) {
		data = [bitmap representationUsingType: NSBMPFileType
									properties: nil];
	} else if ([aType isEqualToString:@"PNG"]) {
		data = [bitmap representationUsingType: NSPNGFileType
									properties: nil];
	} else if ([aType isEqualToString:@"JPEG"]) {
		data = [bitmap representationUsingType: NSJPEGFileType
									properties: nil];
	} else if ([aType isEqualToString:@"GIF"]) {
		data = [bitmap representationUsingType: NSGIFFileType
									properties: nil];
	} else if ([aType isEqualToString:@"TIFF"]) {
		data = [bitmap representationUsingType: NSTIFFFileType
									properties: nil];
	}
	return data;
}

// By overwriting this, we can ask files saved by Paintbrush to open with Paintbrush
// in the future when CGFloat-clicked
- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL
									  ofType:(NSString *)typeName
							forSaveOperation:(NSSaveOperationType)saveOperation
						 originalContentsURL:(NSURL *)absoluteOriginalContentsURL
									   error:(NSError **)outError
{
    NSMutableDictionary *fileAttributes = [[super fileAttributesToWriteToURL:absoluteURL
																	  ofType:typeName 
															forSaveOperation:saveOperation
														 originalContentsURL:absoluteOriginalContentsURL
																	   error:outError] mutableCopy];
	
	// 'Pbsh' has been registered with Apple as our personal four-letter integer
    [fileAttributes setObject:[NSNumber numberWithUnsignedInt:'Pbsh']
					   forKey:NSFileHFSCreatorCode];
    return [fileAttributes autorelease];
}

// Opening an image
- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)aType error:(NSError *)anError
{
	// A temporary image
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithContentsOfURL:URL];
	openedImage = [[NSImage alloc] initWithSize:NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh])];
	[openedImage addRepresentation:imageRep];
	
	return (openedImage != nil);
}

// Printing: Cocoa makes it easy!
- (void)printDocument:(id)sender
{
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:paintView
														  printInfo:[self printInfo]];
	
    [op runOperationModalForWindow:[super windowForSheet]
						  delegate:self
					didRunSelector:NULL
					   contextInfo:NULL];
}

// Called whenever Copy or Cut are called (copies the overlay image to the pasteboard)
- (void)writeImageToPasteboard:(NSPasteboard *)pb
{
	NSRect rect = [(SWSelectionTool *)currentTool clippingRect];
	NSImage *writeToMe = [[NSImage alloc] initWithSize:rect.size];
	[writeToMe lockFocus];
	[[(SWSelectionTool *)currentTool backedImage] drawInRect:NSMakeRect(0,0,rect.size.width, rect.size.height)
							   fromRect:rect
							  operation:NSCompositeSourceOver
							   fraction:1.0];
	[writeToMe unlockFocus];
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];

	[pb setData:[writeToMe TIFFRepresentation] forType:NSTIFFPboardType];
}

// Used by Paste to retrieve an image from the pasteboard
- (BOOL)readImageFromPasteboard:(NSPasteboard *)pb
{
	NSData *data;
	
	if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSTIFFPboardType]]) {
		data = [pb dataForType:NSTIFFPboardType];
		[paintView pasteData:data];
		return YES;
	} else if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSPICTPboardType]]) {
		data = [pb dataForType:NSPICTPboardType];
		[paintView pasteData:data];
		return YES;
	}
	return NO;
}

// Cut: same as copy, but clears the overlay
- (IBAction)cut:(id)sender
{
	[self copy:sender];
	[paintView clearOverlay];
}

// Copy
- (IBAction)copy:(id)sender
{
	[self writeImageToPasteboard:[NSPasteboard generalPasteboard]];
}

// Paste
- (IBAction)paste:(id)sender
{
	[self readImageFromPasteboard:[NSPasteboard generalPasteboard]];
}

// Select all
- (IBAction)selectAll:(id)sender
{
	[toolboxController switchToScissors:nil];
	currentTool = [toolboxController currentTool];
	
	[currentTool setSavedPoint:NSZeroPoint];
	[currentTool performDrawAtPoint:NSMakePoint([paintView bounds].size.width, [paintView bounds].size.height)
					  withMainImage:[paintView mainImage] 
						secondImage:[paintView secondImage] 
						 mouseEvent:MOUSE_UP];
	
	[paintView setCurrentTool:[toolboxController currentTool]];
	[paintView cursorUpdate:nil];
	[paintView setNeedsDisplay:YES];
}

- (IBAction)zoomIn:(id)sender
{
	[scrollView setScaleFactor:([scrollView scaleFactor] * 2) adjustPopup:YES];
}

- (IBAction)zoomOut:(id)sender
{
	[scrollView setScaleFactor:([scrollView scaleFactor] / 2) adjustPopup:YES];
}

- (IBAction)actualSize:(id)sender
{
	[scrollView setScaleFactor:1 adjustPopup:YES];
}

- (IBAction)showGrid:(id)sender
{
	[paintView setShowsGrid:![paintView showsGrid]];
	[sender setState:[paintView showsGrid]];
}

// Decides which menu items to enable, and which to disable (and when)
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	currentTool = [toolboxController currentTool];
	if (([menuItem action] == @selector(copy:)) || 
		([menuItem action] == @selector(cut:)) || 
		([menuItem action] == @selector(crop:))) {
		return ([[currentTool class] isEqualTo:[SWSelectionTool class]] && 
				[(SWSelectionTool *)currentTool isSelected]);
	} else if ([menuItem action] == @selector(paste:)) {
		NSArray *array = [[NSPasteboard generalPasteboard] types];
		BOOL paste = NO;
		id object;
		for (object in array) {
			if ([object isEqualToString:NSTIFFPboardType] || [object isEqualToString:NSPICTPboardType]) {
				paste = YES;
			}
		}
		return paste;
	} else if ([menuItem action] == @selector(zoomIn:)) {
		return [scrollView scaleFactor] < 16;
	} else if ([menuItem action] == @selector(zoomOut:)) {
		return [scrollView scaleFactor] > 0.25;
	} else if ([menuItem action] == @selector(showGrid:)) {
		return [scrollView scaleFactor] > 2.0;
	} else {
		return YES;
	}
}


#pragma mark Handling notifications from the toolbox, application controller

////////////////////////////////////////////////////////////////////////////////
//////////		Handling notifications from the toolbox, application controller
////////////////////////////////////////////////////////////////////////////////


- (IBAction)flipHorizontal:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSRect aRect = NSZeroRect;
		aRect.size = [[paintView mainImage] size];
		NSAffineTransform *transform = [NSAffineTransform transform];
		NSImage *tempImage = [[NSImage alloc] initWithSize:aRect.size];
		
		[transform scaleXBy:-1.0 yBy:1.0];
		[transform translateXBy:-aRect.size.width yBy:0];	
		
		[tempImage lockFocus];
		[transform concat];
		[[paintView mainImage] drawInRect:aRect
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0];
		[tempImage unlockFocus];
		[paintView prepUndo:nil];
		[paintView setImage:tempImage scale:NO];
	}
}

- (IBAction)flipVertical:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSRect aRect = NSZeroRect;
		aRect.size = [[paintView mainImage] size];
		NSAffineTransform *transform = [NSAffineTransform transform];
		NSImage *tempImage = [[NSImage alloc] initWithSize:aRect.size];
				
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform translateXBy:0 yBy:-aRect.size.height];		
		
		[tempImage lockFocus];
		[transform concat];
		[[paintView mainImage] drawInRect:aRect
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0];
		[tempImage unlockFocus];
		[paintView prepUndo:nil];
		[paintView setImage:tempImage scale:NO];
	}
}

// Used to shrink the image background while also isolating a specific
// section of the image to save
- (IBAction)crop:(id)sender
{
	NSLog(@"Cropping");
	NSRect rect = [(SWSelectionTool *)currentTool clippingRect];
	NSImage *writeToMe = [[NSImage alloc] initWithSize:rect.size];
	[writeToMe lockFocus];
	[[(SWSelectionTool *)currentTool backedImage] drawInRect:NSMakeRect(0,0,rect.size.width, rect.size.height)
													fromRect:rect
												   operation:NSCompositeSourceOver
													fraction:1.0];
	[writeToMe unlockFocus];
	
	// Pretend they just changed the image size
	[sizeController setWidth:rect.size.width];
	[sizeController setHeight:rect.size.height];
	[sizeController setScales:NO];
	[self sizeSheetDidEnd:[sizeController window] returnCode:NSOKButton contextInfo:writeToMe];
	[currentTool tieUpLooseEnds];
}

// We offload the heavy lifting to an external class
// TODO: Turn this back on once we have NSBitmapImageReps
//- (IBAction)invertColors:(id)sender
//{
//	[SWImageManipulator invertImage:[paintView mainImage]];
//	[paintView prepUndo:nil];
//	[paintView setNeedsDisplay:YES];
//}

- (void)dealloc
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
