//
//  PrefsPageBase.m
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

#import "PrefsPageBase.h"

@implementation PrefsPageBase

- (instancetype) initWithDescription: (NSDictionary*) description
{
	self = [super init];
	if ( self != nil )
	{
		_description = [description copy];
		
		NSArray *topLevelObjects = nil;
		if ( ![[NSBundle mainBundle] loadNibNamed: [_description objectForKey: @"nib"] owner: self topLevelObjects: &topLevelObjects] )
		{
			[self release];
			return nil;
		}
		_topLevelObjects = [topLevelObjects retain];
		
		NSAssert1( controlBox != nil, @"preferences page '%@' has no control box", [self identifier] );
	}
	return self;
}

- (void) dealloc
{
	[_description release];
	[_topLevelObjects release];
	
	[super dealloc];
}

- (NSString*) identifier
{
	return [_description objectForKey: @"identifier"];
}

- (NSString*) title
{
	return [[NSBundle mainBundle] localizedStringForKey: [_description objectForKey: @"title"] value: nil table: @"Preferences"];
}

- (NSImage*) icon
{
	return [NSImage imageNamed: [_description objectForKey: @"icon"]];
}

- (NSView*) controlBox
{
	return controlBox;
}

- (NSView*) initialFirstResponder
{
	return initialFirstResponder;
}

- (NSArray<NSString*>*) defaultsKeys
{
	NSArray *keys = [_description objectForKey: @"defaultsArray"];
	return keys == nil ? [NSArray array] : keys;
}

- (void) restoreDefaultsNoPrompt
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	for ( NSString *key in [self defaultsKeys] )
	{
		//make sure all observers of the key get notified
		[prefs willChangeValueForKey: key];
		[prefs removeObjectForKey: key];
		[prefs didChangeValueForKey: key];
	}
}

- (BOOL) haveAnyDefaultsChanged
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaultValues = [prefs volatileDomainForName: NSRegistrationDomain];
	
	for ( NSString *key in [self defaultsKeys] )
	{
		id defValue = [defaultValues objectForKey: key];
		id prefValue = [prefs objectForKey: key];
		
		if ( defValue != prefValue && ![defValue isEqual: prefValue] )
			return YES;
	}
	
	return NO;
}

@end
