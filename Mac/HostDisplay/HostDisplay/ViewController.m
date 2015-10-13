//
//  ViewController.m
//  HostDisplay
//
//  Created by Josh Jacob on 8/4/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "UploadEntry.h"

@interface ViewController ()

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet IKImageView *imageView;
@property (strong) IBOutlet NSButton *deleteButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // show the delete button but disable until we have a selection
    [self.deleteButton setEnabled:NO];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    // ask the app delegate how many images we have
    AppDelegate *app = (AppDelegate *) [NSApp delegate];
    return [app uploadCount];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    // ask the app delegate for an image/UploadEntry and give the name to display in table
    AppDelegate *app = (AppDelegate *) [NSApp delegate];
    UploadEntry *entry = [app uploadAtIndex:rowIndex];
    return entry.uploaderName;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // grab table view and test to make sure we have a selection (user may
    // have just unselected an item)
    NSTableView *tableView = (NSTableView *) aNotification.object;
    if (tableView.selectedRow == -1) {
        [self.imageView setHidden:YES];
        [self.deleteButton setEnabled:NO];
        return;
    }
    
    // get associated entry
    AppDelegate *app = (AppDelegate *) [NSApp delegate];
    UploadEntry *entry = [app uploadAtIndex:tableView.selectedRow];
    
    // set image and show if hidden
    [self.imageView setImageWithURL:[[NSURL alloc] initFileURLWithPath:entry.filePath]];
    if ([self.imageView isHidden]) {
        [self.imageView setHidden:NO];
        [self.deleteButton setEnabled:YES];
    }
}

#pragma mark - 

-(void) reloadTable
{
    [self.tableView reloadData];
}

- (IBAction)deleteAction:(id)sender
{
    AppDelegate *app = (AppDelegate *) [NSApp delegate];
    UploadEntry *entry = [app uploadAtIndex:self.tableView.selectedRow];
    [app deleteImage:entry];
}

@end
