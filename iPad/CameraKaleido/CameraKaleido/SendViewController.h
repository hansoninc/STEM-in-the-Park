//
//  SendViewController.h
//  CameraKaleido
//
//  Created by Josh Jacob on 8/19/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendViewController : UIViewController <UITextFieldDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) UIImage *contentImage;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)sendButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
