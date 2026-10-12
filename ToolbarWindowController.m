//
//  ToolbarWindowController.m
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

#import "ToolbarWindowController.h"

// Toolbar item which lets the toolbar's delegate validate it, whatever its target is
@interface DIXToolbarItem : NSToolbarItem
@end

@implementation DIXToolbarItem

- (void) validate
{
	id<NSToolbarItemValidation> delegate = (id<NSToolbarItemValidation>) [[self toolbar] delegate];

	if ( [delegate respondsToSelector: @selector(validateToolbarItem:)] )
		[self setEnabled: [delegate validateToolbarItem: self]];
	else
		[super validate];
}

@end

@implementation NSToolbarItemValidationAdapter

- (void) setToolbarItem: (NSToolbarItem*) toolbarItem
{
	[toolbarItem retain];
	[_toolbarItem release];
	_toolbarItem = toolbarItem;
}

- (void) forwardInvocation: (NSInvocation*) anInvocation
{
	if ( [_toolbarItem respondsToSelector: [anInvocation selector]] )
	{
		[anInvocation setTarget: _toolbarItem];
		[anInvocation invoke];
	}
	else
		[super forwardInvocation: anInvocation];
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
	if ( [_toolbarItem respondsToSelector: aSelector] )
		return [_toolbarItem methodSignatureForSelector: aSelector];
	else
		return [super methodSignatureForSelector: aSelector];
}

// menu validation code sets the menu title; toolbar labels are fixed when the item is created
// (NSToolbarItem's own "title" would turn the item into a text button)
- (void) setTitle: (NSString*) title
{
}

- (void)setState:(NSControlStateValue)itemState
{
	ToolbarWindowController *controller = (ToolbarWindowController *)[[_toolbarItem toolbar] delegate];

    if ( [controller respondsToSelector:@selector(toolbar:imageForToolbarItem:forState:)] )
    {
        NSImage *image = [controller toolbar: [_toolbarItem toolbar]
                         imageForToolbarItem: _toolbarItem
                                    forState: itemState];

        if ( image != nil && image != [_toolbarItem image] )
            [_toolbarItem setImage: image];
    }
}

@end


@interface NSMenu(FindExtensions)

- (NSMenuItem*) menuItemWithAction: (SEL) action;

@end

static NSToolbarItemValidationAdapter *g_toolbarItemValidationAdapter = nil;
static NSMutableDictionary *g_toolbatStateImages = nil;

@implementation ToolbarWindowController

#pragma mark -----------------Toolbar support---------------------

+ (void) initialize
{
	if ( self != [ToolbarWindowController class] )
		return;

	g_toolbarItemValidationAdapter = [[NSToolbarItemValidationAdapter alloc] init];
	g_toolbatStateImages = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
	[_toolbarInfo release];

	[super dealloc];
}

- (NSString *) toolbarConfigurationName
{
	NSAssert( NO, @"subclasses of ToolbarWindowController must override toolbarConfigurationName" );
	return nil;
}

- (NSDictionary *) toolbarInfo
{
	if ( _toolbarInfo == nil )
	{
		NSURL *url = [[NSBundle mainBundle] URLForResource: [self toolbarConfigurationName] withExtension: @"toolbar"];
		_toolbarInfo = [[NSDictionary alloc] initWithContentsOfURL: url];
		NSAssert1( _toolbarInfo != nil, @"couldn't load toolbar configuration '%@'", [self toolbarConfigurationName] );
	}
	return _toolbarInfo;
}

- (void) windowDidLoad
{
	[super windowDidLoad];

	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: [self toolbarConfigurationName]] autorelease];
	[toolbar setAllowsUserCustomization: YES];
	[toolbar setAutosavesConfiguration: YES];
	[toolbar setDelegate: self];

	[[self window] setToolbar: toolbar];
}

//returns an image for a toolbar item with a specific state (NSOnState, NSOffState, NSMixedState like menu items)
- (NSImage*) toolbar: (NSToolbar*) theToolbar imageForToolbarItem: (NSToolbarItem*) item forState: (NSControlStateValue) state
{
	NSString *imageKey = nil;
	switch( state )
	{
		case NSControlStateValueOn:
			imageKey = @"imageName";
			break;
		case NSControlStateValueOff:
			imageKey = @"imageNameOffState";
			break;
		case NSControlStateValueMixed:
			imageKey = @"imageNameMixedState";
			break;
		default:
			NSAssert( NO, @"invalid item state for ToolbarItem" );
	}

	//get the image cache for our toolbar
	NSMutableDictionary *toolbarImageCache = [g_toolbatStateImages objectForKey: [self toolbarConfigurationName]];
	if ( toolbarImageCache == nil )
	{
		toolbarImageCache = [NSMutableDictionary dictionary];
		[g_toolbatStateImages setObject: toolbarImageCache forKey: [self toolbarConfigurationName]];
	}

	//get image cache for the toolbar item
	NSMutableDictionary *itemImageCache = [toolbarImageCache objectForKey: [item itemIdentifier]];
	if ( itemImageCache == nil )
	{
		itemImageCache = [NSMutableDictionary dictionary];
		[toolbarImageCache setObject: itemImageCache forKey: [item itemIdentifier]];
	}

	//get the state image from the toolbar item image cache
	NSImage *image = [itemImageCache objectForKey: imageKey];
	if ( image == nil )
	{
		NSDictionary *itemInfo = [[[self toolbarInfo] objectForKey: @"itemInfoByIdentifier"] objectForKey: [item itemIdentifier]];

		//get image name from info dictionary
		NSString *imageName = [itemInfo objectForKey: imageKey];
		if ( imageName == nil )
			imageName = [itemInfo objectForKey: @"imageName"];

		NSAssert1( imageName != nil, @"no image name for item '%@'", [item itemIdentifier] );

		image = [NSImage imageNamed: imageName];
		NSAssert1( image != nil, @"couldn't load image '%@'", imageName );

		[itemImageCache setObject: image forKey: imageKey];
	}

	return image;
}

- (NSDictionary *)toolbarInfoForItem:(NSString *)identifier
{
	NSMutableDictionary *itemInfo = [NSMutableDictionary dictionaryWithDictionary: [[[self toolbarInfo] objectForKey: @"itemInfoByIdentifier"] objectForKey: identifier]];

	//localize existing strings
#define LOCALIZE_PROPERTY( propname )									\
	if ( ![NSString isEmptyString: [itemInfo objectForKey: propname]] )	\
	{																	\
		NSString *localized = NSLocalizedString( [itemInfo objectForKey: propname], @"" ); \
		[itemInfo setObject: localized forKey: propname];				\
	}

	LOCALIZE_PROPERTY( @"label" );
	LOCALIZE_PROPERTY( @"paletteLabel" );
	LOCALIZE_PROPERTY( @"toolTip" );

#undef LOCALIZE_PROPERTY

	//We now try get the title and tooltip for the toolbar item from the menu.
	//This is done by searching for a menu item with the same action as the toolbar item.
	//Doing this, we don't need to type indentical strings in both the menu resource and the toolbar resource (.toolbar plist file).
	//And they only need to be localized in one place!

	NSString *actionString = [itemInfo objectForKey:@"action"];
	//did someone forgot the ':' at the end of the string? (actions always have the sender as a parameter)
	if ( ![NSString isEmptyString: actionString] && [actionString characterAtIndex: [actionString length] -1] != ':' )
	{
		actionString = [actionString stringByAppendingString: @":"];
		[itemInfo setObject: actionString forKey:@"action"];
	}

	SEL action = [NSString isEmptyString: actionString] ? NULL : NSSelectorFromString( actionString );

	if (  action != NULL
		  && ( [itemInfo objectForKey:@"label"] == nil || [itemInfo objectForKey:@"toolTip"] == nil ) )
	{
		NSMenuItem * menuItem = [[NSApp mainMenu] menuItemWithAction: action];
		if ( menuItem != nil )
		{
			//set label?
			if ( [itemInfo objectForKey:@"label"] == nil && ![NSString isEmptyString: [menuItem title]] )
			{
				//delete periods at end of title (e.g. "Preferences...")
				NSCharacterSet *trimSet = [NSCharacterSet characterSetWithCharactersInString: @".… \t"];
				NSString *title = [menuItem title];
				NSUInteger numOfRemainingChars = [title length];
				while ( numOfRemainingChars > 1 && [trimSet characterIsMember: [title characterAtIndex: numOfRemainingChars-1]] )
					numOfRemainingChars--;
				title = [title substringToIndex: numOfRemainingChars];

				[itemInfo setObject: title forKey: @"label"];
			}
			//set tooltip?
			if ( [itemInfo objectForKey:@"toolTip"] == nil && ![NSString isEmptyString: [menuItem toolTip]] )
				[itemInfo setObject: [menuItem toolTip] forKey: @"toolTip"];
		}
	}

	//if no string for "paletteLabel" is set, use the one for "label"
	//(the paletteLabel is used as the toolbar item's title in the customizable sheet)
	if ( [itemInfo objectForKey:@"paletteLabel"] == nil && [itemInfo objectForKey:@"label"] != nil )
		[itemInfo setObject: [itemInfo objectForKey:@"label"] forKey: @"paletteLabel"];

    return itemInfo;
}

#pragma mark -----------------NSToolbarDelegate---------------------

- (NSArray<NSToolbarItemIdentifier> *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	return [[self toolbarInfo] objectForKey: @"allowedItemIdentifiers"];
}

- (NSArray<NSToolbarItemIdentifier> *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return [[self toolbarInfo] objectForKey: @"defaultItemIdentifiers"];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willInsert
{
	NSDictionary *itemInfo = [self toolbarInfoForItem: itemIdentifier];
	if ( [itemInfo count] == 0 )
		return nil;

	DIXToolbarItem *toolbarItem = [[[DIXToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];

	NSString *value;
	if ( (value = [itemInfo objectForKey: @"label"]) != nil )
		[toolbarItem setLabel: value];
	if ( (value = [itemInfo objectForKey: @"paletteLabel"]) != nil )
		[toolbarItem setPaletteLabel: value];
	if ( (value = [itemInfo objectForKey: @"toolTip"]) != nil )
		[toolbarItem setToolTip: value];
	if ( (value = [itemInfo objectForKey: @"imageName"]) != nil )
		[toolbarItem setImage: [NSImage imageNamed: value]];
	if ( (value = [itemInfo objectForKey: @"action"]) != nil )
		[toolbarItem setAction: NSSelectorFromString( value )];

	//"target" not set: the window controller; "firstResponder": the responder chain;
	//anything else is resolved as key path of the window controller (see properties below)
	NSString *targetKeyPath = [itemInfo objectForKey: @"target"];
	if ( targetKeyPath == nil )
		[toolbarItem setTarget: self];
	else if ( ![targetKeyPath isEqualToString: @"firstResponder"] )
		[toolbarItem setTarget: [self valueForKeyPath: targetKeyPath]];

	return toolbarItem;
}

// if a toolbar item description contains a "target" property,
// the target is resolved by calling valueForKeyPath.
// So for every target besides the window controller ("target" not set) or
// the first responder ("target" property == "firstResponder"), the toolbar delegate
// has to declare a property.
// We declare two: "documentController" and "application"

- (NSDocumentController*) documentController
{
    return [NSDocumentController sharedDocumentController];
}

- (NSApplication*) application
{
    return NSApp;
}


// NSObject (NSToolbarItemValidation)

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    if ( ![[self window] isKeyWindow] )
		return NO;

	[g_toolbarItemValidationAdapter setToolbarItem: theItem];

	return [self validateMenuItem: (NSMenuItem*) g_toolbarItemValidationAdapter];
}

- (BOOL) validateMenuItem: (NSMenuItem*) menuItem
{
	return YES;
}

@end


@implementation NSMenu(FindExtensions)

//linear search through all menu items (including sub menus)
- (NSMenuItem*) menuItemWithAction: (SEL) action
{
	//we enumerate backwards as for the main menu bar the more application specific actions
	//are often in the menus after "File" and "Edit", so it is more likely to find the
	//item in question in the rear menus (this may not apply to sub menus, but we do a linar search anyway)
	NSInteger i = [self numberOfItems];
	while ( i-- )
	{
		NSMenuItem *menuItem = [self itemAtIndex: i];

		if ( [menuItem action] == action )
			return menuItem;

		if ( [menuItem hasSubmenu] )
		{
			menuItem = [[menuItem submenu] menuItemWithAction: action];
			if ( menuItem != nil )
				return menuItem;
		}
	}

	//not found
	return nil;
}

@end
