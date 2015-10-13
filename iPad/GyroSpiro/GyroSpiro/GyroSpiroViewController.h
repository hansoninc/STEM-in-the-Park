//
//  ViewController.h
//  GyroSpiro
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DKVerticalColorPicker.h"
#import "GyroSpiroView.h"

@interface GyroSpiroViewController : UIViewController <DKVerticalColorPickerDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) IBOutlet DKVerticalColorPicker *colorPicker;
@property (strong, nonatomic) IBOutlet UIButton *buttonWhite;
@property (strong, nonatomic) IBOutlet UIButton *buttonBlack;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;

@property (strong, nonatomic) IBOutlet UIView *viewSmallLine;
@property (strong, nonatomic) IBOutlet UIView *viewMediumLine;
@property (strong, nonatomic) IBOutlet UIView *viewLargeLine;

@property (strong, nonatomic) UIColor *currentColor;
@property (strong, nonatomic) IBOutlet GyroSpiroView *contentView;

- (IBAction)setBackgroundWhite:(id)sender;
- (IBAction)setBackgroundBlack:(id)sender;

- (IBAction)reset:(id)sender;
- (IBAction)send:(id)sender;

@end

