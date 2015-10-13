//
//  IntroViewController.m
//  CameraKaleido
//
//  Created by Josh Jacob on 9/9/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if(!([[[UIDevice currentDevice] systemVersion] floatValue] >= 8))
    {
        self.view.superview.bounds = CGRectMake(0, 0, 924, 668);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

@end
