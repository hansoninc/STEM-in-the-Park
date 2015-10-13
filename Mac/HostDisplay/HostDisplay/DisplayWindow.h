//
//  DisplayWindow.h
//  HostDisplay
//
//  Created by Josh Jacob on 8/12/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 
 The DisplayWindow class is controls the window showing the Quartz Composer
 composition. On load, it handles loading and displaying the QC composition
 and then handles updating image paths and names in the composition.
 
 */
@interface DisplayWindow : NSWindowController

/**
 
 This method is called after a new image is uploaded to the application. The
 most recent 5 images will be used in the Quartz Composer composition.
 
 @param uploadEntryArray
        An array of UploadEntry objects.
 
 */
-(void) updateImages:(NSArray *)uploadEntryArray;

@end
