//
//  main.m
//  Disk Accountant
//
//  Created by Tjark Derlien on Sun Oct 26 2003.
//
//  Copyright (C) 2003 Tjark Derlien.
//  
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

//

#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[])
{
    @autoreleasepool
    {
        //default values of the user defaults are declared in Info.plist
        NSDictionary *defaults = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"DIXDefaults"];
        if ( defaults != nil )
            [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
    }
    
    return NSApplicationMain(argc, argv);
}
