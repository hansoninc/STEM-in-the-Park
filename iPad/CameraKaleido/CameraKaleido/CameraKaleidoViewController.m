//
//  ViewController.m
//  CameraKaleido
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "CameraKaleidoViewController.h"

#import "SendViewController.h"
#import "IntroViewController.h"

@interface CameraKaleidoViewController ()

@property (retain, atomic) AVCaptureSession *session;
@property (retain, atomic) AVCaptureDevice *device;
@property (retain, atomic) AVCaptureDeviceInput *input;
@property (retain, atomic) AVCaptureVideoDataOutput *output;

@property (retain, atomic) UIImage *contentImage;

@property (readwrite, atomic) BOOL filterTriangles;
@property (readwrite, atomic) BOOL filterSquares;
@property (readwrite, atomic) BOOL filterSwirl;
@property (readwrite, atomic) BOOL filterColor1;
@property (readwrite, atomic) BOOL filterColor2;
@property (readwrite, atomic) BOOL filterColor3;

@property (retain, atomic) SendViewController *sendModal;

@end

@implementation CameraKaleidoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

#if APPSTORE
    [self.buttonSend setTitle:@"Save" forState:UIControlStateNormal];
#endif
    
    // default filters
    self.filterTriangles = NO;
    self.filterSquares = NO;
    self.filterSwirl = NO;
    self.filterColor1 = NO;
    self.filterColor2 = NO;
    self.filterColor3 = NO;
    
    self.sendModal = [[SendViewController alloc] initWithNibName:@"SendViewController" bundle:nil];

    //Capture Session
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    //Add device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
    if (!self.input)
    {
        NSLog(@"No Input");
        return;
    }
    
    [self.session addInput:self.input];
    
    //Output
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:self.output];
    self.output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

    dispatch_queue_t queue = dispatch_queue_create("aQueue", NULL);
    [self.output setSampleBufferDelegate:self queue:queue];
    
    //Start capture session
    [self.session startRunning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTutorialModal];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    
    CIImage *resultImage = [ciImage copy];
    
    //
    // HEXAGON
    //
    if (self.filterSwirl) {
        /* CIFilter *filter3 = [CIFilter filterWithName:@"CILightTunnel"
         withInputParameters: @{
         kCIInputImageKey   : resultImage,
         @"inputCenter"     : [CIVector vectorWithX:450.0 Y:450.0]
         }]; */
        CIFilter *filter3 = [CIFilter filterWithName:@"CISixfoldReflectedTile"
                                 withInputParameters: @{
                                                        kCIInputImageKey   : resultImage,
                                                        @"inputCenter"     : [CIVector vectorWithX:(1280/2) Y:(720/2)],
                                                        @"inputAngle"      : [NSNumber numberWithDouble:0.00],
                                                        @"inputWidth"      : [NSNumber numberWithDouble:300.0]
                                                        }];
        resultImage = [filter3 outputImage];
    }
    
    //
    // TRIANGLES
    //
    if (self.filterTriangles) {
        CIFilter *filter = [CIFilter filterWithName:@"CITriangleKaleidoscope"
                                withInputParameters: @{
                                                       kCIInputImageKey   : resultImage,
                                                       @"inputSize"       : @200.0,
                                                       @"inputPoint"      : [CIVector vectorWithX:(1280/2) Y:(720/2)]
                                                       }];
        resultImage = [filter outputImage];
    }
    
    //
    // SQUARES
    //
    if (self.filterSquares) {
        CIFilter *filter2 = [CIFilter filterWithName:@"CIEightfoldReflectedTile"
                                 withInputParameters: @{
                                                        kCIInputImageKey   : resultImage,
                                                        @"inputCenter"     : [CIVector vectorWithX:(1280/2) Y:(720/2)],
                                                        @"inputWidth"      : [NSNumber numberWithDouble:300.0]
                                                        }];
        resultImage = [filter2 outputImage];
    }
    
    //
    // COLORS 1
    //
    if (self.filterColor1) {
        UIImage *colorMapFile = [UIImage imageNamed:@"ColorMap1"];
        CIImage *colorMap = [[CIImage alloc] initWithImage:colorMapFile];
        
        CIFilter *filter2 = [CIFilter filterWithName:@"CIColorMap"
                                 withInputParameters: @{
                                                        kCIInputImageKey        : resultImage,
                                                        @"inputGradientImage"   : colorMap
                                                        }];
        
        resultImage = [filter2 outputImage];
    }
    
    //
    // COLORS 2
    //
    if (self.filterColor2) {
        //        CIFilter *filter4 = [CIFilter filterWithName:@"CIColorPosterize"
        //                                 withInputParameters: @{
        //                                                        kCIInputImageKey    : resultImage
        //                                                        }];
        //
        //        resultImage = [filter4 outputImage];
        
        UIImage *colorMapFile = [UIImage imageNamed:@"ColorMap2"];
        CIImage *colorMap = [[CIImage alloc] initWithImage:colorMapFile];
        
        CIFilter *filter2 = [CIFilter filterWithName:@"CIColorMap"
                                 withInputParameters: @{
                                                        kCIInputImageKey        : resultImage,
                                                        @"inputGradientImage"   : colorMap
                                                        }];
        
        resultImage = [filter2 outputImage];
    }
    
    //
    // COLORS 3
    //
    if (self.filterColor3) {
        
        UIImage *colorMapFile = [UIImage imageNamed:@"ColorMap3"];
        CIImage *colorMap = [[CIImage alloc] initWithImage:colorMapFile];
        
        CIFilter *filter2 = [CIFilter filterWithName:@"CIColorMap"
                                 withInputParameters: @{
                                                        kCIInputImageKey        : resultImage,
                                                        @"inputGradientImage"   : colorMap
                                                        }];
        
        resultImage = [filter2 outputImage];
    }
    
    dispatch_sync(dispatch_get_main_queue(),
                  ^{
                      
                      CIContext *context = [CIContext contextWithOptions:nil];
                      CGImageRef outputImageRef = [context createCGImage:resultImage fromRect:CGRectMake(0, 0, 1280, 720)];
                      
                      self.contentImage = [UIImage imageWithCGImage:outputImageRef];
                      
                      //UIImage *newImage = [UIImage imageWithCIImage:outputImage];
                      self.imageView.image = self.contentImage;
                      
                      CGImageRelease(outputImageRef);
                  });
    
}

#pragma mark - IBActions

- (IBAction)touchSwitch:(id)sender {
    self.filterTriangles = self.switchTriangles.on;
    self.filterSquares = self.switchSquares.on;
    self.filterSwirl = self.switchSwirl.on;
    self.filterColor1 = self.switchColor1.on;
    self.filterColor2 = self.switchColor2.on;
    self.filterColor3 = self.switchColor3.on;
}

- (IBAction)send:(id)sender {
    
    // self.sendModal.contentImage = self.contentImage;

    // view rect is 924x768 so crop to that ration

    CGRect oldImageRect __attribute__((unused)) = CGRectMake(0, 0, self.contentImage.size.width, self.contentImage.size.height);
    CGFloat newImageWidth = floorf((924 * self.contentImage.size.height) / 768);
    CGRect newImageRect = CGRectMake(floorf((self.contentImage.size.width - newImageWidth) / 2),
                                     0,
                                     newImageWidth,
                                     self.contentImage.size.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.contentImage CGImage], newImageRect);
    self.sendModal.contentImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
#if APPSTORE
    
    UIImageWriteToSavedPhotosAlbum(self.sendModal.contentImage, nil, nil, nil);
    
#else
    
    // [self.session stopRunning];
    
    [self.sendModal setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:self.sendModal animated:YES completion:^{
        // done
        
        // [self.session startRunning];
        
    }];
    
#endif
        
}

- (IBAction)reset:(id)sender {
    
    // turn off filters
    self.filterTriangles = NO;
    self.filterSquares = NO;
    self.filterSwirl = NO;
    self.filterColor1 = NO;
    self.filterColor2 = NO;
    self.filterColor3 = NO;
    
    self.switchTriangles.on = NO;
    self.switchSquares.on = NO;
    self.switchSwirl.on = NO;
    self.switchColor1.on = NO;
    self.switchColor2.on = NO;
    self.switchColor3.on = NO;
    
    [self showTutorialModal];
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

@end
