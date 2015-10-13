//
//  MyHTTPConnection.h
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface MyHTTPConnection : HTTPConnection
{
    MultipartFormDataParser*        parser;
    NSString *                      storeFilepath;
    NSFileHandle*					storeFile;
    
    NSString *                      uploaderName;
    NSString *                      appName;
    
    NSMutableArray*					uploadedFiles;
}

@end
