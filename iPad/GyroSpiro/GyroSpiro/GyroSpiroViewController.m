//
//  ViewController.m
//  GyroSpiro
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "GyroSpiroViewController.h"

#import "AppDelegate.h"
#import "SendViewController.h"
#import "IntroViewController.h"
#import "ShapeTableViewController.h"

// static const NSTimeInterval deviceMotionMin = 0.05;
static const NSTimeInterval deviceMotionMin = 0.1;

@interface GyroSpiroViewController ()

@property (retain, atomic) SendViewController *sendModal;

@property (readwrite) CGFloat lineThickness;

@property (retain, atomic) ShapeTableViewController *tableView;

@end

@implementation GyroSpiroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
#if APPSTORE
    [self.buttonSend setTitle:@"Save" forState:UIControlStateNormal];
#endif
    
    self.currentColor = [UIColor redColor];
    self.contentView.currentDrawColor = [UIColor redColor];
    self.colorPicker.selectedColor = [UIColor redColor];
    
    self.sendModal = [[SendViewController alloc] initWithNibName:@"SendViewController" bundle:nil];
    
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionAvailable] == YES) {
        [mManager setDeviceMotionUpdateInterval:deviceMotionMin];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            
            // NSLog(@"Motion: roll = %f pitch = %f yaw = %f", deviceMotion.attitude.roll,
            //      deviceMotion.attitude.pitch,
            //      deviceMotion.attitude.yaw);
            
            [self.contentView setPitch:deviceMotion.attitude.pitch Roll:deviceMotion.attitude.roll Yaw:self.lineThickness];
        }];
    } else {
        NSLog(@"WARNING - NO CORE MOTION AVAILABLE");
    }
    
    [self.buttonBlack setTitle:@"" forState:UIControlStateNormal];
    self.buttonBlack.backgroundColor = [UIColor blackColor];
    [self.buttonWhite setTitle:@"" forState:UIControlStateNormal];
    self.buttonWhite.backgroundColor = [UIColor whiteColor];
    
    //
    // set up gestures for setting line thickness
    //
    
    [self.viewSmallLine addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLineWidthTap:)]];
    [self.viewMediumLine addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLineWidthTap:)]];
    [self.viewLargeLine addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLineWidthTap:)]];
    
    //
    // default line thickness
    //
    
    self.lineThickness = 2.0;
    self.viewLargeLine.backgroundColor = [UIColor clearColor];
    self.viewMediumLine.backgroundColor = [UIColor clearColor];
    self.viewSmallLine.backgroundColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"table" isEqualToString:segue.identifier]) {
        self.tableView = segue.destinationViewController;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTutorialModal];
}

#pragma mark - IBActions

- (IBAction)setBackgroundWhite:(id)sender {
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)setBackgroundBlack:(id)sender {
    [self.contentView setBackgroundColor:[UIColor blackColor]];
}

- (IBAction)reset:(id)sender {
    [self.contentView clear];
    
    [self showTutorialModal];
}

- (IBAction)send:(id)sender {
    
    self.sendModal.contentImage = [self.contentView getImage: [self.contentView backgroundColor]];
    
#if APPSTORE
    
    UIImageWriteToSavedPhotosAlbum(self.sendModal.contentImage, nil, nil, nil);
    
#else
    
    [self.sendModal setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:self.sendModal animated:YES completion:^{
        // done
    }];
    
#endif
    
}

# pragma mark - DKVerticalColorPickerDelegate

-(void)colorPicked:(UIColor *)color
{
    self.currentColor = color;
    self.contentView.currentDrawColor = color;
    // NSLog(@"New color = %@", color);
    
    // [self.contentView updateGyroSpiro];
}

#pragma mark -

- (void)showTutorialModal
{
    IntroViewController *introVC = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    introVC.view.bounds = CGRectMake(0, 0, self.view.frame.size.width - 100, self.view.frame.size.height - 100);
    introVC.modalPresentationStyle = UIModalPresentationFormSheet;
    CGRect insetRect = CGRectInset(self.view.frame, 50, 50);
    introVC.preferredContentSize = insetRect.size;
    [self presentViewController:introVC animated:YES completion:^{
        //
    }];
}

- (void)handleLineWidthTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view == self.viewLargeLine) {
        NSLog(@"Large line");
        self.lineThickness = 10.0;
        self.viewLargeLine.backgroundColor = [UIColor grayColor];
        self.viewMediumLine.backgroundColor = [UIColor clearColor];
        self.viewSmallLine.backgroundColor = [UIColor clearColor];
        
    } else if (gestureRecognizer.view == self.viewMediumLine) {
        NSLog(@"Medium line");
        self.lineThickness = 5.0;
        self.viewLargeLine.backgroundColor = [UIColor clearColor];
        self.viewMediumLine.backgroundColor = [UIColor grayColor];
        self.viewSmallLine.backgroundColor = [UIColor clearColor];
        
    } else {
        NSLog(@"Small line");
        self.lineThickness = 2.0;
        self.viewLargeLine.backgroundColor = [UIColor clearColor];
        self.viewMediumLine.backgroundColor = [UIColor clearColor];
        self.viewSmallLine.backgroundColor = [UIColor grayColor];
    }
}

@end
