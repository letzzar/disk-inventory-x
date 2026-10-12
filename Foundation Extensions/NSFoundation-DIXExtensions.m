//
//  NSFoundation-DIXExtensions.m
//  Disk Inventory X
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import "NSFoundation-DIXExtensions.h"
#import <objc/message.h>

@implementation NSString(DIXExtensions)

+ (BOOL) isEmptyString: (id) string
{
	return ![string isKindOfClass: [NSString class]] || [string length] == 0;
}

@end

@implementation NSDictionary(DIXExtensions)

- (BOOL) boolForKey: (NSString*) key
{
	id value = [self objectForKey: key];
	return [value respondsToSelector: @selector(boolValue)] ? [value boolValue] : NO;
}

@end

@implementation NSMutableDictionary(DIXExtensions)

- (void) setBoolValue: (BOOL) value forKey: (NSString*) key
{
	[self setObject: [NSNumber numberWithBool: value] forKey: key];
}

@end

@implementation NSMutableArray(DIXExtensions)

- (void) insertObject: (id) object inArraySortedUsingSelector: (SEL) selector
{
	NSUInteger index = [self indexOfObject: object
							 inSortedRange: NSMakeRange( 0, [self count] )
								   options: NSBinarySearchingInsertionIndex | NSBinarySearchingLastEqual
						   usingComparator: ^NSComparisonResult( id obj1, id obj2 )
	{
		return ((NSComparisonResult (*)(id, SEL, id)) objc_msgSend)( obj1, selector, obj2 );
	}];
	
	[self insertObject: object atIndex: index];
}

@end
