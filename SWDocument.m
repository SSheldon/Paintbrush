/**
 * Copyright 2007-2009 Soggy Waffles
 * 
 * This file is part of Paintbrush.
 * 
 * Paintbrush is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "SWDocument.h"
#import "SWPaintView.h"
#import "SWScalingScrollView.h"
#import "SWCenteringClipView.h"
#import "SWToolbox.h"
#import "SWToolboxController.h"
#import "SWTextToolWindowController.h"
#import "SWSizeWindowController.h"
#import "SWResizeWindowController.h"
#import "SWToolList.h"
#import "SWAppController.h"

@implementation SWDocument

// TODO: Nasty hack
static BOOL kSWDocumentWillShowSheet = YES;

- (id)init
{
    if (self = [super init]) {
		NSLog(@"New document");
				
		// Observers for the toolbox
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(showTextSheet:)
				   name:@"SWText"
				 object:nil];
		[nc addObserver:self 
			   selector:@selector(undoLevelChanged:) 
				   name:kSWUndoKey 
				 object:nil];
		
		// Set levels of undos based on user defaults
		NSNumber *undo = [[NSUserDefaults standardUserDefaults] objectForKey:kSWUndoKey];
		[[self undoManager] setLevelsOfUndo:[undo integerValue]];
		
		// Create my window's particular tools
		toolbox = [[SWToolbox alloc] init];
		
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

	// We can make the app more responsive by loading these guys at launch
	if (!sizeController) {
		sizeController = [[SWSizeWindowController alloc] initWithWindowNibName:@"SizeWindow"];
	}
	if (!resizeController) {
		resizeController = [[SWResizeWindowController alloc] initWithWindowNibName:@"ResizePanel"];
	}
	toolboxController = [SWToolboxController sharedToolboxPanelController];
	
	clipView = [[SWCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	//[clipView setBackgroundColor:[NSColor windowBackgroundColor]];
	
	// The Scroll View contains the clip view, which is the superclass of the paint view (whew!)
	[scrollView setContentView:(NSClipView *)clipView];
	[clipView setDocumentView:paintView];
	[scrollView setScaleFactor:1.0 adjustPopup:YES];
	
	// Get and set the background image of the clip view
	NSImage *bgImage = [NSImage imageNamed:@"bgImage.png"];
	if (bgImage)
		[clipView setBgImage:bgImage];
		
	// If the user opened an image
	if (openedImage) {
		openingRect.origin = NSZeroPoint;
		openingRect.size = [openedImage size];
		[self setUpPaintView];
	} else {
		// When we create a new document
		if (kSWDocumentWillShowSheet) {
			[[aController window] orderFront:self];
			[self raiseSizeSheet:aController];
		} else {
			[SWDocument setWillShowSheet:YES];
//			openedImage = [[NSBitmapImageRep alloc] initWithData:[SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]]];
			openedImage = [NSBitmapImageRep imageRepWithPasteboard:[NSPasteboard generalPasteboard]];
			openingRect.origin = NSZeroPoint;
			openingRect.size = [openedImage size];
			[self setUpPaintView];
		}
	}
	
	[paintView setBackgroundColor:[NSColor clearColor]];
}


- (void)setUpPaintView
{
	[paintView setFrame:openingRect];
	[paintView preparePaintView];
	[paintView setToolbox:toolbox];
	
	// Use external method to determine the window bounds
	NSRect tempRect = [paintView calculateWindowBounds:openingRect];
	
	// Apply the changes to the new document
	[[paintView window] setFrame:tempRect display:YES animate:YES];
	
	[paintView setImage:openedImage scale:NO];	
}


- (NSString *)pathForImageBackgrounds
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/Paintbrush/Background Images/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO)
	{
		[fileManager createDirectoryAtPath: folder attributes: nil];
	}
    
	NSString *fileName = @"bgImage.png";
	return [folder stringByAppendingPathComponent:fileName];   
}

#pragma mark Sheets - Size and Text

////////////////////////////////////////////////////////////////////////////////
//////////		Sheets - Size and Text
////////////////////////////////////////////////////////////////////////////////


// Called when a new document is made
- (IBAction)raiseSizeSheet:(id)sender
{
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
		// Initial creation
		[paintView setFrame:openingRect];
		[self setUpPaintView];
		
		// Use external method to determine the window bounds
		NSRect tempRect = [paintView calculateWindowBounds:openingRect];
		[window setFrame:tempRect display:YES animate:YES];
	} else if (returnCode == NSCancelButton) {
		// Close the document - they obviously don't want to play
		[[super windowForSheet] close];
	}
}


// Called when the user resizes the canvas/image
- (IBAction)raiseResizeSheet:(id)sender
{
	// Sender tag: 1 == image, 0 == canvas
	if ([[sender class] isEqualTo: [NSMenuItem class]]) {
		[resizeController setScales:[sender tag]];
	}
	
	// Get, and then set, the current document size
	NSSize currSize = openingRect.size;
	[resizeController setCurrentSize:currSize];
	
    [NSApp beginSheet:[resizeController window]
	   modalForWindow:[super windowForSheet]
		modalDelegate:self
	   didEndSelector:@selector(resizeSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}


// After the sheet ends, this takes over. If the user clicked "OK", a new
// PaintView is initialized. Otherwise, the window closes.
- (void)resizeSheetDidEnd:(NSWindow *)sheet
			   returnCode:(NSInteger)returnCode
			  contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {
		openingRect.origin = NSZeroPoint;
		openingRect.size.width = [resizeController width];
		openingRect.size.height = [resizeController height];
		NSBitmapImageRep *backupImage = contextInfo ? (NSBitmapImageRep *)contextInfo : [paintView mainImage];
		
		// Nothing to do if the size isn't changing!
		if ([[paintView mainImage] size].width != openingRect.size.width || 
			[[paintView mainImage] size].height != openingRect.size.height) {
			NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSValue valueWithRect:NSMakeRect(0,0,[backupImage size].width, [backupImage size].height)], 
							   @"Frame", [backupImage TIFFRepresentation], @"Image", nil];
			[paintView prepUndo:d];
			[paintView setFrame:openingRect];
			[paintView preparePaintView];
			[paintView setImage:backupImage scale:[resizeController scales]];
			
			// We should also redraw the clip view
			[[paintView superview] setNeedsDisplay:YES];
		}
	}
}


// Keep the current document's undo manager up to date
- (void)undoLevelChanged:(NSNotification *)n
{
	NSNumber *number = [n object];
	[[self undoManager] setLevelsOfUndo:[number integerValue]];
}


- (void)showTextSheet:(NSNotification *)n
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
		[[NSColorPanel sharedColorPanel] setColor:[n object]];
		
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
	[toolboxController tieUpLooseEnds];
	[super saveDocument:sender];
}


// Saving data: returns the correctly-formatted image data
- (NSData *)dataOfType:(NSString *)aType error:(NSError **)anError
{
//	NSData *data = [[paintView mainImage] TIFFRepresentation];
//	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithData:data] autorelease];
	NSBitmapImageRep *bitmap = [paintView mainImage];
	SWFlipImageVertical(bitmap);
	NSData *data = nil;
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
// in the future when double-clicked
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
- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)aType error:(NSError **)anError
{
	// Temporary image
	NSBitmapImageRep *tempImage = [NSBitmapImageRep imageRepWithContentsOfURL:URL];
	SWImageRepWithSize(&openedImage, NSMakeSize([tempImage pixelsWide], [tempImage pixelsHigh]));
	// Copy the image to the openedImage
	SWCopyImage(openedImage, tempImage);
	
	if (openedImage)
		SWFlipImageVertical(openedImage);
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
// TODO: Relieve some of this method's dependencies on the Selection tool
- (void)writeImageToPasteboard:(NSPasteboard *)pb
{
	NSRect rect = [(SWSelectionTool *)currentTool clippingRect];
	NSBitmapImageRep *writeToMe;
	SWImageRepWithSize(&writeToMe, rect.size);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:writeToMe]];
	//NSBitmapImageRep *backedImage = [(SWSelectionTool *)currentTool backedImage];
	//NSPoint oldOrigin = [(SWSelectionTool *)currentTool oldOrigin];
	// TODO: Make this work
	NSLog(@"Copying is not currently supported in this build");
//	[backedImage drawInRect:NSMakeRect(0,0,rect.size.width, rect.size.height)
//							   fromRect:NSMakeRect(oldOrigin.x,oldOrigin.y,rect.size.width, rect.size.height)
//							  operation:NSCompositeSourceOver
//							   fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	[pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];

	[pb setData:[writeToMe TIFFRepresentation] forType:NSTIFFPboardType];
	[writeToMe release];
}


// Used by Paste to retrieve an image from the pasteboard
+ (NSData *)readImageFromPasteboard:(NSPasteboard *)pb
{
	NSData *data = nil;
	
	if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSTIFFPboardType]]) {
		data = [pb dataForType:NSTIFFPboardType];
	} else if ([pb availableTypeFromArray:[NSArray arrayWithObject:NSPICTPboardType]]) {
		data = [pb dataForType:NSPICTPboardType];
	}
	return data;
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
	NSData *data = [SWDocument readImageFromPasteboard:[NSPasteboard generalPasteboard]];
	if (data) {
		[paintView pasteData:data];		
	}
}


// Select all
- (IBAction)selectAll:(id)sender
{
	[toolboxController switchToScissors:nil];
	currentTool = [toolbox currentTool];
	
	[currentTool setSavedPoint:NSZeroPoint];
	[currentTool performDrawAtPoint:NSMakePoint([paintView bounds].size.width, [paintView bounds].size.height)
					  withMainImage:[paintView mainImage] 
						bufferImage:[paintView bufferImage] 
						 mouseEvent:MOUSE_UP];
	
	[paintView setCurrentTool:[toolbox currentTool]];
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
//- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
	SEL action = [anItem action];
//	NSLog(@"%@", anItem);
	currentTool = [toolbox currentTool];
	if ((action == @selector(copy:)) || 
		(action == @selector(cut:)) || 
		(action == @selector(crop:))) {
		return ([[currentTool class] isEqualTo:[SWSelectionTool class]] && 
				[(SWSelectionTool *)currentTool isSelected]);
	} else if (action == @selector(paste:)) {
		NSArray *array = [[NSPasteboard generalPasteboard] types];
		BOOL paste = NO;
		id object;
		for (object in array) {
			if ([object isEqualToString:NSTIFFPboardType] || [object isEqualToString:NSPICTPboardType]) {
				paste = YES;
			}
		}
		return paste;
	} else if (action == @selector(zoomIn:)) {
		return [scrollView scaleFactor] < 16;
	} else if (action == @selector(zoomOut:)) {
		return [scrollView scaleFactor] > 0.25;
	} else if (action == @selector(showGrid:)) {
		return [scrollView scaleFactor] > 2.0;
	} else if (action == @selector(newFromClipboard:)) {
		return YES;
	} else {
		return YES;
	}
}


// TODO: Nasty nasty hack - fix it!
+ (void)setWillShowSheet:(BOOL)showSheet
{
	kSWDocumentWillShowSheet = showSheet;
}


#pragma mark Handling notifications from the toolbox, application controller

////////////////////////////////////////////////////////////////////////////////
//////////		Handling notifications from the toolbox, application controller
////////////////////////////////////////////////////////////////////////////////


- (IBAction)flipHorizontal:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSBitmapImageRep *image = [paintView mainImage];
		[paintView prepUndo:nil];
		SWFlipImageHorizontal(image);
		[paintView setNeedsDisplay:YES];
	}
}


- (IBAction)flipVertical:(id)sender
{
	if ([[super windowForSheet] isKeyWindow]) {
		NSBitmapImageRep *image = [paintView mainImage];
		[paintView prepUndo:nil];
		SWFlipImageVertical(image);
		[paintView setNeedsDisplay:YES];
	}
}


// Used to shrink the image background while also isolating a specific
// section of the image to save
- (IBAction)crop:(id)sender
{
	// TODO: Make this work again
	NSLog(@"Cropping doesn't work yet either");
	
	// First we need to make a temporary copy of what's selected by the selection tool
	NSRect rect = [(SWSelectionTool *)currentTool clippingRect];
	NSBitmapImageRep *writeToMe;
	SWImageRepWithSize(&writeToMe, rect.size);
//	[writeToMe lockFocus];
//	[[(SWSelectionTool *)currentTool backedImage] drawInRect:NSMakeRect(0,0,rect.size.width, rect.size.height)
//													fromRect:rect
//												   operation:NSCompositeSourceOver
//													fraction:1.0];
//	[writeToMe unlockFocus];
	[currentTool tieUpLooseEnds];
	
	// Tell the controller that they just changed the image size
	[sizeController setWidth:rect.size.width];
	[sizeController setHeight:rect.size.height];
	[self sizeSheetDidEnd:[sizeController window] returnCode:NSOKButton contextInfo:[paintView mainImage]];
	
	// Now we cheat and set the image
	[paintView setImage:writeToMe scale:NO];
	[writeToMe release];
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
	[sizeController release];
	[clipView release];
	//[openedImage release];
	[textController release];
	[toolbox release];
	[super dealloc];
}

@end
