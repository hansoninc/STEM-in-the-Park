//
//  GyroSpiroView.m
//  GyroSpiro
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "GyroSpiroView.h"

#define GYROSPIRO_ROTATE NO

@interface GyroSpiroView()

@property CGContextRef offScreen;
@property (readwrite, atomic) CGFloat widthOffset;

@property (readwrite, atomic) double pitch;
@property (readwrite, atomic) double roll;
@property (readwrite, atomic) double yaw;

@property (readwrite, atomic) double rotation;

@end

@implementation GyroSpiroView

- (id)initWithCoder:(NSCoder *)decoder {
//    NSLog(@"GyroSpiroView - initWithCoder");
    self = [super initWithCoder:decoder];
    if (self) {
        
        self.shape = 0;
        
        self.offScreen = nil;
        
        self.pitch = 0.1;
        self.roll = 0.1;
        self.yaw = 0.1;
        
        self.rotation = 0;
        
        self.updating = YES;
    }
    return self;
    
}

- (void)drawRect:(CGRect)rect {
    
    if (self.offScreen == nil)
        [self offScreenSetup];
    
    // NSLog(@"GyroSpiroView - rect = %@", CGRectCreateDictionaryRepresentation(rect));
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGImageRef cgImage = CGBitmapContextCreateImage(self.offScreen);
    
    CGContextDrawImage(ctx, self.frame, cgImage);
    
    CGImageRelease(cgImage);
    
}

#pragma mark -

-(void)offScreenSetup
{
//    NSLog(@"GyroSpiroView - frame = %@", CGRectCreateDictionaryRepresentation(self.frame));
    
    // calc pixel dimensions we need
    CGFloat deviceScale = [[UIScreen mainScreen] scale];
    CGFloat width = self.frame.size.width * deviceScale;
    CGFloat height = self.frame.size.height * deviceScale;
    CGRect imageRect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    self.offScreen = CGBitmapContextCreate(nil,
                                           imageRect.size.width,
                                           imageRect.size.height,
                                           8,
                                           imageRect.size.width * 4,
                                           colorSpace,
                                           (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
}

-(void)updateGyroSpiro
{
    // NSLog(@"Motion: roll = %f pitch = %f yaw = %f", self.roll, self.pitch, self.yaw);
    
    if (self.updating == NO)
        return;
    
    if (GYROSPIRO_ROTATE == YES)
    {
        // increase rotation
        self.rotation += 0.1f;
        if (self.rotation > 6.28318531)
            self.rotation -= 6.28318531;
    }
    
    // compute ellipse rect
    CGFloat deviceScale = [[UIScreen mainScreen] scale];
    CGFloat width = self.frame.size.width * deviceScale;
    CGFloat height = self.frame.size.height * deviceScale;
    CGRect ellipseRect = CGRectNull;
    if (GYROSPIRO_ROTATE == YES) {
        CGFloat rectWidth = width * fabs(self.pitch);
        CGFloat rectHeight = height * fabs(self.roll);
        ellipseRect = CGRectMake(-1 * (rectWidth/2),
                                        -1 * (rectHeight/2),
                                        rectWidth,
                                 rectHeight);
        
        
        NSLog(@"CGRectGetMidX = %f; CGRectGetMidY = %f", CGRectGetMidX(ellipseRect), CGRectGetMidY(ellipseRect));
        // CGContextTranslateCTM(self.offScreen, CGRectGetMidX(ellipseRect), CGRectGetMidY(ellipseRect));
        CGContextTranslateCTM(self.offScreen, (width/2), (height/2));
        CGContextRotateCTM(self.offScreen, self.rotation);
    } else {
        ellipseRect = CGRectMake((width / 2) - ((width * fabs(self.pitch)) / 2),
                                        (height / 2) - ((height * fabs(self.roll)) / 2),
                                        width * fabs(self.pitch),
                                        height * fabs(self.roll));
    }
    
    CGContextSetLineWidth(self.offScreen, self.yaw);
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [self.currentDrawColor getRed:&red green:&green blue:&blue alpha:&alpha];
    UIColor *currentDrawColorWithAlpha = [UIColor colorWithRed:red
                                                         green:green
                                                          blue:blue
                                                         alpha:0.7f];
    CGContextSetStrokeColorWithColor(self.offScreen, [currentDrawColorWithAlpha CGColor]);
    
    if (self.shape == 0) {
        CGContextStrokeRect(self.offScreen, ellipseRect);
    } else if (self.shape == 1) {
        CGContextStrokeEllipseInRect(self.offScreen, ellipseRect);
    } else {
        CGContextBeginPath(self.offScreen);
        CGContextMoveToPoint(self.offScreen, CGRectGetMinX(ellipseRect), CGRectGetMaxY(ellipseRect));
        CGContextAddLineToPoint(self.offScreen, CGRectGetMidX(ellipseRect), CGRectGetMinY(ellipseRect));
        CGContextAddLineToPoint(self.offScreen, CGRectGetMaxX(ellipseRect), CGRectGetMaxY(ellipseRect));
        CGContextAddLineToPoint(self.offScreen, CGRectGetMinX(ellipseRect), CGRectGetMaxY(ellipseRect));
        CGContextStrokePath(self.offScreen);
    }
    
    self.widthOffset++;
    
    if (GYROSPIRO_ROTATE == YES) {
        CGContextConcatCTM(self.offScreen, CGAffineTransformInvert(CGContextGetCTM(self.offScreen)));
    }
    
    [self setNeedsDisplay];
}

-(void)setPitch:(double)pitch Roll:(double)roll Yaw:(double)yaw
{
    self.pitch = pitch;
    self.roll = roll;
    self.yaw = yaw;
    
    [self updateGyroSpiro];
}

-(void)clear
{
    // calc pixel dimensions we need
    CGFloat deviceScale = [[UIScreen mainScreen] scale];
    CGFloat width = self.frame.size.width * deviceScale;
    CGFloat height = self.frame.size.height * deviceScale;
    CGRect imageRect = CGRectMake(0, 0, width, height);
    
    CGContextClearRect(self.offScreen, imageRect);
}

-(UIImage *)getImage: (UIColor*) color
{
    // calc pixel dimensions we need
    CGFloat deviceScale = [[UIScreen mainScreen] scale];
    CGFloat width = self.frame.size.width * deviceScale;
    CGFloat height = self.frame.size.height * deviceScale;
    CGRect imageRect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef tempContext = CGBitmapContextCreate(nil,
                                           imageRect.size.width,
                                           imageRect.size.height,
                                           8,
                                           imageRect.size.width * 4,
                                           colorSpace,
                                           (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
    
    CGContextSetFillColorWithColor(tempContext, [color CGColor]);
    CGContextFillRect(tempContext, imageRect);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(self.offScreen);

    // flip image since the CG world is from Mac OS X with a different coordinate system
    CGContextTranslateCTM(tempContext, 0, height);
    CGContextScaleCTM(tempContext, 1.0, -1.0);
    
    CGContextDrawImage(tempContext, imageRect, imgRef);
    CGImageRef tempImgRef = CGBitmapContextCreateImage(tempContext);
    UIImage* img = [UIImage imageWithCGImage:tempImgRef];
    
    CGImageRelease(imgRef);
    CGImageRelease(tempImgRef);
    CGContextRelease(tempContext);
    return img;
}

@end
