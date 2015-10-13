//
//  AppDelegate.h
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HTTPServer;
@class UploadEntry;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    HTTPServer *httpServer;
}

/**
 
 We hide the image aray from the rest of the code and expose specific aspects
 of it. Here, we pass back the count of total entries.
 
 */
- (NSUInteger) uploadCount;

/**
 
 Get at a specific entry.
 
 @param index
        The index of the element in the array.
 
 */
- (UploadEntry *) uploadAtIndex:(NSUInteger)index;

/**
 
 Delete a specific entry.
 
 @param uploadEntry
        That entry object to remove from the array.
 
 */
- (void) deleteImage:(UploadEntry *)uploadEntry;

/**
 Add uploaded image to image array and update composition display and admin window.
 
 @param filePath
        The local system file path to the image.
 @param uploaderName
        The name entered by the user uploading the image.
 @param appName
        The name of the app that uploaded the image.
*/
- (void)addImage:(NSString *)filePath withName:(NSString *)uploaderName appName:(NSString *)appName;

/**

 The base data directory data for the app - ~/Library/Application Support/BGSU-StemInThePark/
 
 */
- (NSString *)getDirectoryBase;

/**
 
 The directory were uploaded images are placed, inside the data diretory.
 
 */
- (NSString *)getDirectoryUploads;

@end

