//
//  OASplitView.h
//  Disk Inventory X
//
//  NSSplitView which remembers its divider position.
//  The class name is kept from OmniAppKit as it is archived in the TreeMap nibs.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <Cocoa/Cocoa.h>

@interface OASplitView : NSSplitView

- (void) setPositionAutosaveName: (NSString*) name;

@end
