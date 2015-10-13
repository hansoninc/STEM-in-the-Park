//
//  SendViewController.m
//  CameraKaleido
//
//  Created by Josh Jacob on 8/19/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "SendViewController.h"

#import "AppDelegate.h"

@interface SendViewController ()

@end

@implementation SendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sendButton.enabled = NO;
    self.activityIndicator.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.nameTextField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.contentImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate and notifications

- (void)textFieldDidChange :(NSNotification *)notification
{
    if (self.nameTextField.text.length > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)sendButtonAction:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.uploadUrl == nil) {
        return;
    }
    
    self.nameTextField.enabled = NO;
    self.sendButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSLog(@"Start prep.");
    
    // UIImage *image = [self.contentView getImage: [self.contentView backgroundColor]];
    NSString *name = self.nameTextField.text;
    NSString *app = @"CameraKaleido";
    
    // Build the request body
    NSString *boundary = @"----------BGSU_STEM_IN_THE_PARK";
    NSMutableData *body = [NSMutableData data];
    
    // Body part for "deviceId" parameter. This is a string.
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Body part for "textContent" parameter. This is a string.
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"app"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", app] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Body part for the attachament. This is an image.
    NSData *imageData = UIImagePNGRepresentation(self.contentImage);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", @"image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Accept"        : @"application/json",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
    // Create the session
    // We can use the delegate to track upload progress
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:appDelegate.uploadUrl]];
    request.HTTPBody = body;
    request.HTTPMethod = @"POST";
    
    NSLog(@"Start send.");
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"End send.");
        
        if (error != nil) {
            NSLog(@"Error - %@", error);
        }
        
        [self performSelectorOnMainThread:@selector(cancelButtonAction:) withObject:self waitUntilDone:NO];
        
    }];
    [postDataTask resume];
}

- (IBAction)cancelButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        // reset view for next time
        self.contentImage = nil;
        self.nameTextField.text = @"";
        self.nameTextField.enabled = YES;
        self.sendButton.enabled = NO;
        self.cancelButton.enabled = YES;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        
    }];
}

@end
