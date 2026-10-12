//
//  PrefsPanelController.m
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

#import "PrefsPanelController.h"

static NSString * const SelectedPageDefaultsKey = @"PrefsPanelSelectedPage";
static const CGFloat ButtonBarHeight = 48;

@interface PrefsPanelController(Private)
- (PrefsPageBase*) pageWithIdentifier: (NSString*) identifier;
- (void) selectPage: (PrefsPageBase*) page;
- (void) selectPageFromToolbar: (NSToolbarItem*) sender;
- (void) userDefaultsDidChange: (NSNotification*) notification;
@end

@implementation PrefsPanelController

+ (PrefsPanelController*) sharedPreferenceController
{
	static PrefsPanelController *sharedPreferenceController = nil;
	
	if (sharedPreferenceController == nil)
		sharedPreferenceController = [[self alloc] init];

	return sharedPreferenceController;
}

- (instancetype) init
{
	NSWindow *window = [[[NSWindow alloc] initWithContentRect: NSMakeRect( 0, 0, 500, 300 )
													styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
													  backing: NSBackingStoreBuffered
														defer: YES] autorelease];
	self = [super initWithWindow: window];
	if ( self == nil )
		return nil;
	
	[window setReleasedWhenClosed: NO];
	[window setDelegate: self];
	[window setToolbarStyle: NSWindowToolbarStylePreference];
	
	//create the pages declared in Info.plist (sorted by "ordering")
	NSDictionary *descriptions = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"DIXPreferencePages"];
	NSArray *sortedDescriptions = [[descriptions allValues] sortedArrayUsingComparator: ^NSComparisonResult( NSDictionary *d1, NSDictionary *d2 )
	{
		return [[d1 objectForKey: @"ordering"] compare: [d2 objectForKey: @"ordering"]];
	}];
	
	NSMutableArray *pages = [NSMutableArray array];
	for ( NSDictionary *description in sortedDescriptions )
	{
		if ( [[description objectForKey: @"hidden"] boolValue] )
			continue;
		
		Class pageClass = NSClassFromString( [description objectForKey: @"identifier"] );
		NSAssert1( [pageClass isSubclassOfClass: [PrefsPageBase class]], @"invalid preferences page class '%@'", [description objectForKey: @"identifier"] );
		
		PrefsPageBase *page = [[[pageClass alloc] initWithDescription: description] autorelease];
		if ( page != nil )
			[pages addObject: page];
	}
	_pages = [pages copy];
	
	//content: page container above a bar with the "Restore Defaults" button
	NSView *contentView = [window contentView];
	
	_pageContainer = [[NSView alloc] initWithFrame: NSMakeRect( 0, ButtonBarHeight, NSWidth([contentView bounds]), NSHeight([contentView bounds]) - ButtonBarHeight )];
	[_pageContainer setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
	[contentView addSubview: _pageContainer];
	
	_restoreDefaultsButton = [[NSButton buttonWithTitle: NSLocalizedString( @"Restore Defaults", @"" )
												 target: self
												 action: @selector(restoreDefaults:)] retain];
	[_restoreDefaultsButton sizeToFit];
	[_restoreDefaultsButton setFrameOrigin: NSMakePoint( 20, ( ButtonBarHeight - NSHeight([_restoreDefaultsButton frame]) ) / 2 )];
	[_restoreDefaultsButton setAutoresizingMask: NSViewMaxXMargin | NSViewMaxYMargin];
	[contentView addSubview: _restoreDefaultsButton];
	
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: @"PreferencesToolbar"] autorelease];
	[toolbar setDelegate: self];
	[toolbar setAllowsUserCustomization: NO];
	[toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[window setToolbar: toolbar];
	
	NSString *selectedIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey: SelectedPageDefaultsKey];
	PrefsPageBase *selectedPage = [self pageWithIdentifier: selectedIdentifier];
	[self selectPage: selectedPage != nil ? selectedPage : [_pages firstObject]];
	
	[window center];
	[window setFrameAutosaveName: @"PreferencesWindow"];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(userDefaultsDidChange:)
												 name: NSUserDefaultsDidChangeNotification
											   object: nil];
	
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[_pages release];
	[_pageContainer release];
	[_restoreDefaultsButton release];
	
	[super dealloc];
}

- (IBAction) showPreferencesPanel: (id) sender
{
	[self showWindow: sender];
}

- (IBAction) restoreDefaults: (id) sender
{
	PrefsPageBase *page = _currentPage;
	if ( page == nil )
		return;
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText: [NSString stringWithFormat: NSLocalizedString( @"Restore the default settings of \"%@\"?", @"" ), [page title]]];
	[alert setInformativeText: NSLocalizedString( @"The settings shown on this page will be set to their default values.", @"" )];
	[alert addButtonWithTitle: NSLocalizedString( @"Restore Defaults", @"" )];
	[alert addButtonWithTitle: NSLocalizedString( @"Cancel", @"" )];
	
	[alert beginSheetModalForWindow: [self window] completionHandler: ^( NSModalResponse returnCode )
	{
		if ( returnCode == NSAlertFirstButtonReturn )
			[page restoreDefaultsNoPrompt];
	}];
}

#pragma mark -----------------NSToolbarDelegate---------------------

- (NSArray<NSToolbarItemIdentifier> *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	return [_pages valueForKey: @"identifier"];
}

- (NSArray<NSToolbarItemIdentifier> *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (NSArray<NSToolbarItemIdentifier> *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
	return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSToolbarItemIdentifier) itemIdentifier willBeInsertedIntoToolbar: (BOOL) flag
{
	PrefsPageBase *page = [self pageWithIdentifier: itemIdentifier];
	if ( page == nil )
		return nil;
	
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
	[item setLabel: [page title]];
	[item setPaletteLabel: [page title]];
	[item setImage: [page icon]];
	[item setTarget: self];
	[item setAction: @selector(selectPageFromToolbar:)];
	
	return item;
}

#pragma mark -----------------NSWindowDelegate---------------------

- (void) windowWillClose: (NSNotification *) notification
{
	//commit pending edits
	[[self window] makeFirstResponder: nil];
}

@end

@implementation PrefsPanelController(Private)

- (PrefsPageBase*) pageWithIdentifier: (NSString*) identifier
{
	for ( PrefsPageBase *page in _pages )
	{
		if ( [[page identifier] isEqualToString: identifier] )
			return page;
	}
	return nil;
}

- (void) selectPageFromToolbar: (NSToolbarItem*) sender
{
	[self selectPage: [self pageWithIdentifier: [sender itemIdentifier]]];
}

- (void) selectPage: (PrefsPageBase*) page
{
	if ( page == nil || page == _currentPage )
		return;
	
	NSWindow *window = [self window];
	NSView *pageView = [page controlBox];
	
	[[_currentPage controlBox] removeFromSuperview];
	_currentPage = page;
	
	//resize the window to fit the page (keeping the top left corner in place)
	NSSize pageSize = [pageView frame].size;
	NSRect contentRect = [window contentRectForFrameRect: [window frame]];
	NSRect newContentRect = NSMakeRect( NSMinX(contentRect), NSMaxY(contentRect) - pageSize.height - ButtonBarHeight,
									    pageSize.width, pageSize.height + ButtonBarHeight );
	[window setFrame: [window frameRectForContentRect: newContentRect] display: YES animate: [window isVisible]];
	
	[pageView setFrame: [_pageContainer bounds]];
	[pageView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
	[_pageContainer addSubview: pageView];
	
	[window setTitle: [page title]];
	[[window toolbar] setSelectedItemIdentifier: [page identifier]];
	[window makeFirstResponder: [page initialFirstResponder]];
	
	[_restoreDefaultsButton setEnabled: [page haveAnyDefaultsChanged]];
	
	[[NSUserDefaults standardUserDefaults] setObject: [page identifier] forKey: SelectedPageDefaultsKey];
}

- (void) userDefaultsDidChange: (NSNotification*) notification
{
	[_restoreDefaultsButton setEnabled: [_currentPage haveAnyDefaultsChanged]];
}

@end
