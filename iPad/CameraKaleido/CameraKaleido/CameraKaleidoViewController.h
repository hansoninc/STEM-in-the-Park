//
//  ViewController.h
//  CameraKaleido
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface CameraKaleidoViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (retain, atomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIButton *buttonSend;

@property (strong, nonatomic) IBOutlet UISwitch *switchTriangles;
@property (strong, nonatomic) IBOutlet UISwitch *switchSquares;
@property (strong, nonatomic) IBOutlet UISwitch *switchSwirl;

@property (strong, nonatomic) IBOutlet UISwitch *switchColor1;
@property (strong, nonatomic) IBOutlet UISwitch *switchColor2;
@property (strong, nonatomic) IBOutlet UISwitch *switchColor3;

- (IBAction)touchSwitch:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)reset:(id)sender;

@end

