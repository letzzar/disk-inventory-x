//
//  ToolbarWindowController.h
//  Disk Inventory X
//
//  Created by Tjark Derlien on 01.12.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.

//

#import <Cocoa/Cocoa.h>

@interface NSToolbarItemValidationAdapter : NSObject
{
	NSToolbarItem* _toolbarItem;
}

- (void) setToolbarItem: (NSToolbarItem*) toolbarItem;
- (void) forwardInvocation: (NSInvocation*) anInvocation;

@end

// Window controller with a toolbar described by a ".toolbar" property list in the main bundle
// (replaces OmniAppKit's OAToolbarWindowController).
// The plist contains "allowedItemIdentifiers", "defaultItemIdentifiers" and "itemInfoByIdentifier";
// each item info may contain "label", "paletteLabel", "toolTip", "imageName", "action" and "target".
@interface ToolbarWindowController : NSWindowController <NSToolbarDelegate, NSToolbarItemValidation>
{
	NSDictionary *_toolbarInfo;
}

// name of the .toolbar file (without extension); subclasses must override
- (NSString *) toolbarConfigurationName;

- (NSDictionary *) toolbarInfoForItem: (NSString *) identifier;

- (NSImage*) toolbar: (NSToolbar*) theToolbar imageForToolbarItem: (NSToolbarItem*) item forState: (NSControlStateValue) state;

// properties to resolve "target" value for tool items
@property (readonly) NSDocumentController *documentController;
@property (readonly) NSApplication *application;

@end
