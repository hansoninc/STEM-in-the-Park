//
//  UploadEntry.m
//  HostDisplay
//
//  Created by Josh Jacob on 9/1/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "UploadEntry.h"

@implementation UploadEntry

#pragma mark - NSCoding

/**
 
 To support writing out to a .plist we need to write out the elements we want to save.
 
 */
- (void) encodeWithCoder:(NSCoder*)encoder {

    // If parent class also adopts NSCoding, include a call to
    // [super encodeWithCoder:encoder] as the first statement.
    
    [encoder encodeObject:self.filePath forKey:@"filePath"];
    [encoder encodeObject:self.uploaderName forKey:@"uploaderName"];
    [encoder encodeObject:self.appName forKey:@"appName"];
}

/**
 
 The other half is loading the element from a .plist file.
 
 */
- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        
        // If parent class also adopts NSCoding, replace [super init]
        // with [super initWithCoder:decoder] to properly initialize.
        
        self.filePath = [decoder decodeObjectForKey:@"filePath"];
        self.uploaderName = [decoder decodeObjectForKey:@"uploaderName"];
        self.appName = [decoder decodeObjectForKey:@"appName"];
    }
    return self;
}

@end
