//
//  ViewController.h
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

/**
 
 This class manages the view in the admin window. The admin window allows
 the user to view the list of uploads, select an upload to view the image;
 and delete the image.
 
 */
@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

/**
 
 Method to let the app force a reload of the image table. Called
 when a new image has been uploaded.
 
 */
-(void) reloadTable;

- (IBAction)deleteAction:(id)sender;

@end

