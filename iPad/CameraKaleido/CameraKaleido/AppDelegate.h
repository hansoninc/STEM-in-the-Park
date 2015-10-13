//
//  AppDelegate.h
//  CameraKaleido
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *uploadUrl;

@end

