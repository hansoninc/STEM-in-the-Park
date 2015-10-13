//
//  AppDelegate.m
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "MyHTTPConnection.h"
#import "DisplayWindow.h"
#import "UploadEntry.h"

#import "HTTPServer.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate ()
{
    
}

@property (retain) ViewController *viewController;

@property (retain) DisplayWindow *displayWindow;

@property (retain) NSMutableArray *uploadEntryArray;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //
    // load saved data
    //
    
    [self loadUploadData];
    
    //
    // CocoaHTTPServer config pulled from their sample code
    //
    
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Initalize our http server
    httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:8080];
    
    // We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
    // This allows us to do all kinds of customizations.
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    
    // Serve files from our embedded Web folder
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    DDLogInfo(@"Setting document root: %@", webPath);
    
    [httpServer setDocumentRoot:webPath];
    
    NSError *error = nil;
    if(![httpServer start:&error])
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
    
    //
    // Full screen config if an extra display is present
    //
    
    // create new display window
    self.displayWindow = [[DisplayWindow alloc] initWithWindowNibName:@"DisplayWindow"];
    [self.displayWindow showWindow:self];
    
    // if we have more than one screen...
    NSArray *screens = [NSScreen screens];
    if (screens.count > 1) {
        
        // ...set display window to full screen with no border/title
        NSScreen *screen = [screens objectAtIndex:1];
        NSRect mainDisplayRect = [screen frame];
        [self.displayWindow.window setLevel: NSNormalWindowLevel];
        [self.displayWindow.window orderOut:self];
        [self.displayWindow.window setFrame: mainDisplayRect display:YES animate:YES];
        [self.displayWindow.window setLevel: CGShieldingWindowLevel()];
        [self.displayWindow.window makeKeyAndOrderFront:screen];
    } else {
        
        // ...or just set as a resizable window
        [self.displayWindow.window setStyleMask:NSTitledWindowMask | NSResizableWindowMask];
    }
    
    //
    // The rest of the app config
    //
    
    [self.displayWindow updateImages:self.uploadEntryArray];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    
    // once app becomes active, grab admin window content view
    if (_viewController==nil) {
        _viewController = (ViewController *)[[NSApplication sharedApplication] mainWindow].contentViewController;
    }
    
    // reload the table
    [self.viewController reloadTable];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // save the current image before closing
    [self saveUploadConfigs];
}

#pragma mark -

- (NSUInteger) uploadCount
{
    return self.uploadEntryArray.count;
}

- (UploadEntry *) uploadAtIndex:(NSUInteger)index
{
    return [self.uploadEntryArray objectAtIndex:index];
}

- (void) deleteImage:(UploadEntry *)uploadEntry;
{
    // move image to trash so it doesn't appear in rotator anymore
    [[NSWorkspace sharedWorkspace] recycleURLs:@[[[NSURL alloc] initFileURLWithPath:uploadEntry.filePath isDirectory:NO]]
                             completionHandler:^(NSDictionary *newURLs, NSError *error) {
        if (error != nil)
        {
            NSLog(@"Error putting image in trash: %@", error);
        }
    }];
    [self.uploadEntryArray removeObject:uploadEntry];
    
    [self.displayWindow updateImages:self.uploadEntryArray];
    [self.viewController reloadTable];
}

- (void)addImage:(NSString *)filePath withName:(NSString *)uploaderName appName:(NSString *)appName
{
    UploadEntry *entry = [[UploadEntry alloc] init];
    entry.filePath = filePath;
    entry.uploaderName = uploaderName;
    entry.appName = appName;
    
    [self.uploadEntryArray insertObject:entry atIndex:0];
    
    [self.displayWindow updateImages:self.uploadEntryArray];
    
    [self.viewController reloadTable];
}

#pragma mark - Convience methods for paths

- (NSString *)getDirectoryBase
{
    NSError *error;
    
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    appSupportDir = [appSupportDir URLByAppendingPathComponent:@"BGSU-StemInThePark"];
    
    NSString* baseDirPath = [appSupportDir path];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:baseDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:baseDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return baseDirPath;
}

- (NSString *)getDirectoryUploads
{
    NSError *error;

    NSString* uploadDirPath = [[self getDirectoryBase] stringByAppendingPathComponent:@"upload"];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return uploadDirPath;
}

/**
 
 We only use the .plist file path in this class, so it's not defined in the interface
 
 */
- (NSString *)getPlistFile
{
    return [[self getDirectoryBase] stringByAppendingPathComponent:@"data.plist"];
}

#pragma mark - Load/Save Upload Data

/**
 
 Load the .plist file of previously uploaded images.
 
 */
- (void)loadUploadData
{
    // get path to .plist file
    NSString *plistFile = [self getPlistFile];
    
    // if there is a file where the .plist file is supposed to be...
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager]fileExistsAtPath:plistFile isDirectory:&isDir ]) {
        
        // ...load the file
        self.uploadEntryArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPlistFile]];
    } else {
        
        // ... if not, create an empty list
        self.uploadEntryArray = [[NSMutableArray alloc] init];
    }
}

/**
 
 Save the uploaded images to a .plist file.
 
 */
- (void)saveUploadConfigs
{
    // save list to .plist file
    [NSKeyedArchiver archiveRootObject:self.uploadEntryArray toFile:[self getPlistFile]];
}

@end
