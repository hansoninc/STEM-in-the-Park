//
//  UploadEntry.h
//  HostDisplay
//
//  Created by Josh Jacob on 9/1/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 This simple object contains everything about an uploaded image: the file
 path that it was saved to, the user's name who uploaded it and the name of
 the app that uploaded it.
 
 */
@interface UploadEntry : NSObject <NSCoding>

@property (retain, atomic) NSString* filePath;
@property (retain, atomic) NSString* uploaderName;
@property (retain, atomic) NSString* appName;

@end
