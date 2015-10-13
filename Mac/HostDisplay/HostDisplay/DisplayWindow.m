//
//  DisplayWindow.m
//  HostDisplay
//
//  Created by Josh Jacob on 8/12/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "DisplayWindow.h"

#import "AppDelegate.h"
#import "UploadEntry.h"

#import <Quartz/Quartz.h>

@interface DisplayWindow ()

@property (retain) QCView *mVisualizer;

@end

@implementation DisplayWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // grab current content view and frame
    NSView *superview = [self.window contentView];
    NSRect frame = [self.window frame];
    
    // create a new composition view, add it to the default view
    self.mVisualizer = [[QCView alloc] initWithFrame:frame];
    [superview addSubview:self.mVisualizer];
    
    // get path to composition (in the app bundle) and load it
    NSString *qtzPath = [[NSBundle mainBundle] pathForResource:@"QuartzDisplay" ofType:@"qtz"];
    BOOL sucess = [self.mVisualizer loadCompositionFromFile:qtzPath];
    if (sucess) {
        
        // set parameters for composition
        [self.mVisualizer setAutostartsRendering:YES];
        [self.mVisualizer setMaxRenderingFrameRate: 30.0];
        
        // get keys to validate we are updating valid inputs
        QCComposition *comp = [self.mVisualizer loadedComposition];
        NSArray *inputKeys = [comp inputKeys];
        
        // get path to a blank/alpha image and empty out the name fields
        NSString *blankPng = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"blank.png"];
        if ([inputKeys containsObject:@"Main"])
            [self.mVisualizer setValue:blankPng forInputKey:@"Main"];
        if ([inputKeys containsObject:@"Main_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"Main_Name"];
        if ([inputKeys containsObject:@"41"])
            [self.mVisualizer setValue:blankPng forInputKey:@"41"];
        if ([inputKeys containsObject:@"41_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"41_Name"];
        if ([inputKeys containsObject:@"42"])
            [self.mVisualizer setValue:blankPng forInputKey:@"42"];
        if ([inputKeys containsObject:@"42_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"42_Name"];
        if ([inputKeys containsObject:@"43"])
            [self.mVisualizer setValue:blankPng forInputKey:@"43"];
        if ([inputKeys containsObject:@"43_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"43_Name"];
        if ([inputKeys containsObject:@"44"])
            [self.mVisualizer setValue:blankPng forInputKey:@"44"];
        if ([inputKeys containsObject:@"44_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"44_Name"];
        
        // get path to all images and set for bottom scroller of images
        AppDelegate *app = (AppDelegate *) [NSApp delegate];
        NSString* uploadDirPath = [app getDirectoryUploads];
        [self.mVisualizer setValue:uploadDirPath forInputKey:@"DirectoryLocation"];
        
        // tell the composition to start
        [self.mVisualizer startRendering];
    }
    
    // use constraints to make sure composition covers entire window
    [self.mVisualizer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.window contentView] addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-0-[_mVisualizer]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_mVisualizer)]];
    [[self.window contentView] addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-0-[_mVisualizer]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_mVisualizer)]];
}

-(void) updateImages:(NSArray *)uploadEntryArray
{
    // access the currently running composition and get list of input keys
    QCComposition *comp = [self.mVisualizer loadedComposition];
    NSArray *inputKeys = [comp inputKeys];
    NSString *blankPng = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"blank.png"];
    
    // for the 5 image locations in the composition..
    //
    //  test if we have enough elements in uploadEntryArray
    //      get element of uploadEntryArray as our custom object
    //      test if there is a key with the name we expect (safeguard in case something changed in composition)
    //          set the value (the image file path and the user's name)
    //
    //  if we don't have enough elements we empty out that space in the composition -- there's a special
    //   use case where the admin can delete an image and it needs to redraw but there aren't enough images
    if (uploadEntryArray.count > 0) {
        UploadEntry *entry = [uploadEntryArray objectAtIndex:0];
        if ([inputKeys containsObject:@"Main"])
            [self.mVisualizer setValue:entry.filePath forInputKey:@"Main"];
        if ([inputKeys containsObject:@"Main_Name"])
            [self.mVisualizer setValue:entry.uploaderName forInputKey:@"Main_Name"];
    } else {
        if ([inputKeys containsObject:@"Main"])
            [self.mVisualizer setValue:blankPng forInputKey:@"Main"];
        if ([inputKeys containsObject:@"Main_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"Main_Name"];
    }
    if (uploadEntryArray.count > 1) {
        UploadEntry *entry = [uploadEntryArray objectAtIndex:1];
        if ([inputKeys containsObject:@"41"])
            [self.mVisualizer setValue:entry.filePath forInputKey:@"41"];
        if ([inputKeys containsObject:@"41_Name"])
            [self.mVisualizer setValue:entry.uploaderName forInputKey:@"41_Name"];
    } else {
        if ([inputKeys containsObject:@"41"])
            [self.mVisualizer setValue:blankPng forInputKey:@"41"];
        if ([inputKeys containsObject:@"41_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"41_Name"];
    }
    if (uploadEntryArray.count > 2) {
        UploadEntry *entry = [uploadEntryArray objectAtIndex:2];
        if ([inputKeys containsObject:@"42"])
            [self.mVisualizer setValue:entry.filePath forInputKey:@"42"];
        if ([inputKeys containsObject:@"42_Name"])
            [self.mVisualizer setValue:entry.uploaderName forInputKey:@"42_Name"];
    } else {
        if ([inputKeys containsObject:@"42"])
            [self.mVisualizer setValue:blankPng forInputKey:@"42"];
        if ([inputKeys containsObject:@"42_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"42_Name"];
    }
    if (uploadEntryArray.count > 3) {
        UploadEntry *entry = [uploadEntryArray objectAtIndex:3];
        if ([inputKeys containsObject:@"43"])
            [self.mVisualizer setValue:entry.filePath forInputKey:@"43"];
        if ([inputKeys containsObject:@"43_Name"])
            [self.mVisualizer setValue:entry.uploaderName forInputKey:@"43_Name"];
    } else {
        if ([inputKeys containsObject:@"43"])
            [self.mVisualizer setValue:blankPng forInputKey:@"43"];
        if ([inputKeys containsObject:@"43_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"43_Name"];
    }
    if (uploadEntryArray.count > 4) {
        UploadEntry *entry = [uploadEntryArray objectAtIndex:4];
        if ([inputKeys containsObject:@"44"])
            [self.mVisualizer setValue:entry.filePath forInputKey:@"44"];
        if ([inputKeys containsObject:@"44_Name"])
            [self.mVisualizer setValue:entry.uploaderName forInputKey:@"44_Name"];
    } else {
        if ([inputKeys containsObject:@"44"])
            [self.mVisualizer setValue:blankPng forInputKey:@"44"];
        if ([inputKeys containsObject:@"44_Name"])
            [self.mVisualizer setValue:@" " forInputKey:@"44_Name"];
    }
}

@end
