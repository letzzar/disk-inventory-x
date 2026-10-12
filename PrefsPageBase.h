//
//  PrefsPageBase.h
//  Disk Inventory X
//
//  Created by Tjark Derlien on 29.11.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//  
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.

//

#import <Cocoa/Cocoa.h>

// One page of the preferences window (replaces OmniAppKit's OAPreferenceClient).
// The page is the owner of its nib; the nib connects the outlets below.
// The controls are bound to the shared NSUserDefaultsController.
@interface PrefsPageBase : NSObject
{
	IBOutlet NSView *controlBox;
	IBOutlet NSView *initialFirstResponder;
	IBOutlet NSView *lastKeyView;
	
	NSDictionary *_description;
	NSArray *_topLevelObjects;
}

// "description" is the page's entry in the "DIXPreferencePages" dictionary of Info.plist
- (instancetype) initWithDescription: (NSDictionary*) description;

- (NSString*) identifier;
- (NSString*) title; //localized
- (NSImage*) icon;

- (NSView*) controlBox;
- (NSView*) initialFirstResponder;

// user defaults keys shown by this page ("defaultsArray" in Info.plist)
- (NSArray<NSString*>*) defaultsKeys;

- (void) restoreDefaultsNoPrompt;
- (BOOL) haveAnyDefaultsChanged;

@end
