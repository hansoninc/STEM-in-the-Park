//
//  ViewController.h
//  TouchBlob
//
//  Created by David Williams on 9/9/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKVerticalColorPicker.h"

@interface ViewController : UIViewController {
        NSMutableArray *activePositions;
        NSArray *touchEmitters;
}
@property (weak, nonatomic)     IBOutlet UIImageView *mainImage;
@property (weak, nonatomic)     IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic)     IBOutlet DKVerticalColorPicker *colorPicker;
@property (weak, nonatomic)     IBOutlet UISwitch *trailsSwitch;
@property (weak, nonatomic)     IBOutlet UIButton *resetButton;
@property (weak, nonatomic)     IBOutlet UIView *particleView;
@property (weak, nonatomic)     IBOutlet UIButton *buttonSend;
@property (strong, nonatomic)   UIColor *currentColor;
@property (nonatomic, assign)   BOOL isTrails;
@property (nonatomic, assign)   BOOL needsStamp;
@property (weak,nonatomic)      NSTimer *drawLoopTimer;
@property (weak,nonatomic)      NSTimer *fingerLiftedTimer;
@property NSSet *mostRecentTouches;
@property NSSet *fingerLiftedTouches;
@property int fingerLiftedTouchCount;


@end

