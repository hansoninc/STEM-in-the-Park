//
//  GyroSpiroView.h
//  GyroSpiro
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GyroSpiroView : UIView

@property UIColor *currentDrawColor;

@property (readwrite, nonatomic) NSInteger shape;

@property (readwrite, nonatomic) BOOL updating;

-(void)setPitch:(double)pitch Roll:(double)roll Yaw:(double)yaw;

-(void)updateGyroSpiro;

-(void)clear;

-(UIImage *)getImage: (UIColor*) color;

@end
