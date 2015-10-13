//
//  ViewController.m
//  TouchBlob
//
//  Created by David Williams on 9/9/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "ViewController.h"
#import "SendViewController.h"
#import "IntroViewController.h"

@interface ViewController ()

@property (retain, atomic) SendViewController *sendModal;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up main draw loop
    self.drawLoopTimer = [NSTimer scheduledTimerWithTimeInterval:0.015 target:self selector:@selector(drawCanvas) userInfo:nil repeats:YES];
    
    self.currentColor = [UIColor redColor];
    self.isTrails = true;
    self.needsStamp = false;
    
    self.fingerLiftedTouchCount = 0;
    
    self.sendModal = [[SendViewController alloc] initWithNibName:@"SendViewController" bundle:nil];

#if APPSTORE
    [self.buttonSend setTitle:@"Save" forState:UIControlStateNormal];
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showTutorialModal];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)getColorPulse:(UIColor*)baseColor {
    double currentTime = CACurrentMediaTime();
    
    CGFloat red, green, blue, alpha;
    CGFloat diff = sin(currentTime*16)*.1 - .1;
    
    [baseColor getRed: &red green:&green blue:&blue alpha:&alpha];
    
    red +=diff;
    green +=diff;
    blue+=diff;
    
    if (self.isTrails) {
        alpha = 0.5f;
    } else {
        alpha = 0.75f;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

-(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}

# pragma mark - DKVerticalColorPickerDelegate

-(void)colorPicked:(UIColor *)color
{
    self.currentColor = color;
}

- (IBAction)trailsToggled:(id)sender {
    self.isTrails = self.trailsSwitch.on;
}
- (IBAction)resetPressed:(id)sender {
    self.tempDrawImage.image = nil;
    self.mainImage.image = nil;
    [self showTutorialModal];
}

- (IBAction)send:(id)sender {
    self.sendModal.contentImage = self.mainImage.image;
    
#if APPSTORE
    
    UIImageWriteToSavedPhotosAlbum(self.sendModal.contentImage, nil, nil, nil);
    
#else
    
    [self.sendModal setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:self.sendModal animated:YES completion:^{
        // done
    }];
    
#endif
}

// Sort a list of touches to avoid intersections
- (NSArray*)getTouchesSorted:(NSSet*)touches {
    
    // get a center point
    CGPoint centerPoint = [self getAveragePoint:touches];
    
    // array for sorting
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (UITouch* touch in touches) {
        [points addObject:touch];
    }
    
    // sort points by their angle from the center (distance if angles are equal)
    NSArray* sortedPoints = [points sortedArrayUsingComparator: ^NSComparisonResult(id a, id b) {
        CGPoint pointA = [(UITouch*)a locationInView:self.tempDrawImage];
        CGPoint pointB = [(UITouch*)b locationInView:self.tempDrawImage];
        
        CGFloat dXA = pointA.x - centerPoint.x;
        CGFloat dYA = pointA.y - centerPoint.y;
        CGFloat dXB = pointB.x - centerPoint.x;
        CGFloat dYB = pointB.y - centerPoint.y;
        
        CGFloat angleA = [self getBearingDegrees:pointA and:centerPoint];
        CGFloat angleB = [self getBearingDegrees:pointB and:centerPoint];
        
        if (angleA == angleB) {
            CGFloat distA = dXA*dXA + dYA*dYA;
            CGFloat distB = dXB*dXB + dYB*dYB;
            
            return distA - distB;
        }
        
        return angleA-angleB;
    }];
    
    return sortedPoints;
}

// http://stackoverflow.com/questions/1311049/how-to-map-atan2-to-degrees-0-360
-(float)getBearingDegrees:(CGPoint) startingPoint and:(CGPoint) endingPoint {
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

-(CGPoint)getAveragePoint:(NSSet*)touches {
    CGFloat totalX = 0.f;
    CGFloat totalY = 0.f;
    
    if (touches != nil && touches.count > 0) {
        for (UITouch* touch in touches) {
            if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
                CGPoint touchPoint = [touch locationInView:self.tempDrawImage];
                totalX += touchPoint.x;
                totalY += touchPoint.y;
            }
        }
        return CGPointMake(totalX/[self getValidTouchesCount:touches],totalY/[self getValidTouchesCount:touches]);
    }
    
    return CGPointMake(0.f,0.f);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.mostRecentTouches = [event allTouches];
    
    //[self clearEmitters:1];
    //[self addParticlesWithPoint :[[touches anyObject] locationInView:self.particleView] :[touchEmitters objectAtIndex:0]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.mostRecentTouches = [event allTouches];
    
    //[self updateParticles :touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.mostRecentTouches = [event allTouches];
    
    // Give the user some wiggle-room to lift a series of fingers before committing shape.
    if (self.fingerLiftedTimer == nil) {
        self.fingerLiftedTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(fingerLiftedTimerFinished) userInfo:nil repeats:NO];
        self.fingerLiftedTouchCount = (int)[event allTouches].count;
    }
    
    //[self updateParticles :[NSSet setWithObjects:nil]];
}
 

-(void)fingerLiftedTimerFinished{
    if ([self getValidTouchesCount:self.mostRecentTouches] < 2 && self.fingerLiftedTouchCount >= 2) {
        self.needsStamp = true;
        self.fingerLiftedTimer = nil;
    }
}

-(void)drawCanvas {
    UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
    
    // set white background
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect){ {0,0}, self.tempDrawImage.frame.size});
    
    // draw lower canvas into upper canvas
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
    
    // set draw color
    UIColor *pulseColor = [self getColorPulse:self.currentColor];
    [pulseColor set];
    
    // make path, plot points
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    int pointCount = 0;
    for (UITouch *touch in [self getTouchesSorted:self.mostRecentTouches]) {
        CGPoint touchPoint = [touch locationInView:self.tempDrawImage];
        if (pointCount == 0) {
            [aPath moveToPoint:touchPoint];
        } else {
            [aPath addLineToPoint:touchPoint];
        }
        pointCount++;
    }

    // set line width only if we have two points
    if (pointCount == 2)
    {
        aPath.lineWidth = 8;
        [aPath stroke];
    }
    
    // fill shape
    if (pointCount > 0) {
        [aPath fill];
    }
    
    // only update the image if we're valid and the timer isn't on
    if (self.fingerLiftedTimer == nil && [self getValidTouchesCount:self.mostRecentTouches] >= 2) {
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    }

    // stamp if needed
    if (self.isTrails || self.needsStamp) {
        self.mainImage.image = self.tempDrawImage.image;
        self.needsStamp = false;
    }
    
    UIGraphicsEndImageContext();
}

-(unsigned long)getValidTouchesCount:(NSSet*) touches {
    unsigned long validTouchesCount = 0;
    for (UITouch *touch in touches) {
        if (touch.phase != UITouchPhaseCancelled && touch.phase != UITouchPhaseEnded) {
            validTouchesCount++;
        }
    }
    return validTouchesCount;
}

-(void)logTouchEvent:(UIEvent*)event {
    unsigned long began = 0;
    unsigned long moved = 0;
    unsigned long stationary = 0;
    unsigned long cancelled =0;
    unsigned long ended = 0;
    
    for (UITouch *touch in [event allTouches]) {
        switch (touch.phase) {
            case UITouchPhaseBegan: began++; break;
            case UITouchPhaseMoved: moved++; break;
            case UITouchPhaseStationary: stationary++; break;
            case UITouchPhaseCancelled: cancelled++; break;
            case UITouchPhaseEnded: ended++; break;
        }
    }
    
    NSLog(@"Touch event: %1lu began, %2lu moved, %lu stationary, %4lu cancelled, %5lu ended", began, moved, stationary, cancelled, ended );
}


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

- (void)updateParticles:(NSSet*)touches
{
    NSMutableArray* allTouches = [[NSMutableArray alloc]init];
    for (UITouch* touch in touches) {
        [allTouches addObject:touch];
    }
    
    // Remove all points being tracked.
    [activePositions removeAllObjects];
    
    int totalTouches = (int)[allTouches count];
    
    // Clear other emitters that aren't used
    if (totalTouches < [touchEmitters count]) {
        [self clearEmitters:totalTouches];
    }
    
    // Update position of all emitters.
    for (int i = 0; i < totalTouches; i++) {
        CAEmitterLayer* layer = [touchEmitters objectAtIndex:i];
        UITouch *touch = [allTouches objectAtIndex:i];
        CGPoint location = [self getLegitimatePosition:[touch locationInView:touch.view]];
        
        // Add the position
        [activePositions addObject:[NSValue valueWithCGPoint:location]];
        
        [self addParticlesWithPoint :location :layer];
    }
}

- (CGPoint)getLegitimatePosition:(CGPoint)point
{
    CGPoint originalPoint = CGPointMake(CGRectGetMaxX(self.view.bounds) * 2,
                                        CGRectGetMaxY(self.view.bounds));
    
    CGPoint newOriginPoint = CGPointMake(originalPoint.x - originalPoint.x/2,
                                         originalPoint.y - originalPoint.y/2);
    
    return CGPointMake(newOriginPoint.x + point.x,
                       newOriginPoint.y + point.y);
}

- (void)addParticlesWithPoint:(CGPoint)point :(CAEmitterLayer*)layer
{
    UIImage *image = [UIImage imageNamed:@"tspark.png"];
    
    layer.emitterPosition = point;
    layer.renderMode = kCAEmitterLayerBackToFront;
    
    //Highlight
    CAEmitterCell *hightlight = [CAEmitterCell emitterCell];
    hightlight.contents = (id)image.CGImage;
    hightlight.emissionLatitude = 0;
    hightlight.birthRate = 200;
    hightlight.velocityRange = 100;
    hightlight.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor;
    //rocket.redRange = 0.5;
    //rocket.greenRange = 0.5;
    //rocket.blueRange = 0.5;
    hightlight.scale = 0.6;
    hightlight.velocity = 300;
    hightlight.lifetime = 0.3;
    hightlight.alphaSpeed = -0.2;
    hightlight.yAcceleration = -80;
    hightlight.emissionRange = 2 * M_PI;
    hightlight.scaleSpeed = -0.1;
    hightlight.spin = 6;
    
    //Name the cell so that it can be animated later using keypath
    [hightlight setName:@"hightlight"];
    
    layer.emitterCells = [NSArray arrayWithObjects:hightlight, nil];
    
    //Force the view to update
    [self.particleView setNeedsDisplay];
}

- (void)clearEmitters:(int)startIndex {
    // Clear other emitters that aren't used
    for (int i = startIndex; i < [touchEmitters count]; i++) {
        CAEmitterLayer* layer = [touchEmitters objectAtIndex:i];
        [layer setValue:@0 forKeyPath:@"emitterCells.hightlight.birthRate"];
    }
}

@end
