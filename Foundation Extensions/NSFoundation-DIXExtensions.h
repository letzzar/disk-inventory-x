//
//  NSFoundation-DIXExtensions.h
//  Disk Inventory X
//
//  Replacements for the few OmniFoundation/OmniBase helpers Disk Inventory X used,
//  so the application no longer depends on the Omni frameworks.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <Foundation/Foundation.h>

//assertion for preconditions (was OmniBase's OBPRECONDITION); compiled out like NSAssert
#define OBPRECONDITION(condition) NSCAssert((condition), @"precondition failed: %s", #condition)

@interface NSString(DIXExtensions)

//YES for nil, non-string objects and empty strings
+ (BOOL) isEmptyString: (id) string;

@end

@interface NSDictionary(DIXExtensions)

- (BOOL) boolForKey: (NSString*) key;

@end

@interface NSMutableDictionary(DIXExtensions)

- (void) setBoolValue: (BOOL) value forKey: (NSString*) key;

@end

@interface NSMutableArray(DIXExtensions)

//inserts "object" in an array sorted by "selector" (a compare method returning NSComparisonResult)
- (void) insertObject: (id) object inArraySortedUsingSelector: (SEL) selector;

@end
