//
//  AppDelegate.h
//  TouchBlob
//
//  Created by David Williams on 9/9/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *uploadUrl;

@end

