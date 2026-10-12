//
//  PrefsPanelController.h
//  Disk Inventory X
//
//  Created by Tjark Derlien on 28.11.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//  
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.

//

#import <Cocoa/Cocoa.h>
#import "PrefsPageBase.h"

// Preferences window (replaces OmniAppKit's OAPreferenceController).
// The pages are declared in the "DIXPreferencePages" dictionary of Info.plist.
@interface PrefsPanelController : NSWindowController <NSToolbarDelegate, NSWindowDelegate>
{
	NSArray<PrefsPageBase*> *_pages;
	PrefsPageBase *_currentPage;
	NSView *_pageContainer;
	NSButton *_restoreDefaultsButton;
}

+ (PrefsPanelController*) sharedPreferenceController;

- (IBAction) showPreferencesPanel: (id) sender;
- (IBAction) restoreDefaults: (id) sender;

@end
