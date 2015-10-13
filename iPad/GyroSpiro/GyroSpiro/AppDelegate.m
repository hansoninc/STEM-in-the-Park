//
//  AppDelegate.m
//  GyroSpiro
//
//  Created by Josh Jacob on 7/28/15.
//  Copyright (c) 2015 Hanson, Inc. All rights reserved.
//

#import "AppDelegate.h"

#import <arpa/inet.h>

@interface AppDelegate ()
{
    CMMotionManager *motionmanager;
}

@property (retain, atomic) NSNetServiceBrowser *browser;

@property (retain, atomic) NSMutableArray *serviceArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.uploadUrl = nil;
    
    self.serviceArray = [[NSMutableArray alloc] init];

#if !APPSTORE
    self.browser = [[NSNetServiceBrowser alloc] init];
    [self.browser setDelegate:self];
    [self.browser searchForServicesOfType:@"_http._tcp."
                                 inDomain:@""];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 

- (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}

#if !APPSTORE

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser
{
    // NSLog(@"Starting search");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // add object to array of services we are resolving
    [self.serviceArray addObject:netService];
    [netService setDelegate:self];
    [netService resolveWithTimeout:5];
    
    // NSLog(@"%@ - %d - %@", netService.name, netService.addresses.count, netService.type);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
             didNotSearch:(NSDictionary *)errorDict
{
    // NSLog(@"Error browsing services: %@", errorDict);
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    // NSLog(@"%@ - %d - %@", sender.name, sender.addresses.count, sender.type);
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in sender.addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6))
        {
            const char *addressStr = inet_ntop(
                                               socketAddress->sa.sa_family,
                                               (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
            
            if (addressStr && port)
            {
                // NSLog(@"Found service at %s:%d", addressStr, port);
                if (socketAddress->sa.sa_family == AF_INET)
                {
                    NSString *baseUrl = [NSString stringWithFormat:@"http://%s:%d/", addressStr, port];
                    NSString *testUrl = [NSString stringWithFormat:@"%@index.html", baseUrl];
                    
                    NSURLSession *session = [NSURLSession sharedSession];
                    [[session dataTaskWithURL:[NSURL URLWithString:testUrl]
                            completionHandler:^(NSData *data,
                                                NSURLResponse *response,
                                                NSError *error) {
                                if (error == nil)
                                {
                                    NSString *responseEncodingString = [response textEncodingName];
                                    NSStringEncoding responseEncoding = NSISOLatin1StringEncoding;
                                    if (responseEncodingString != nil) {
                                        responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)responseEncodingString));
                                    }
                                    NSString *content = [[NSString alloc] initWithData:data encoding:responseEncoding];
                                    // NSLog(@"Content: %@", content);
                                    if ([content rangeOfString:@"STEM Upload"].length > 0)
                                    {
                                        self.uploadUrl = [NSString stringWithFormat:@"%@upload.html", baseUrl];
                                        
                                        NSLog(@"Found upload host: %@", self.uploadUrl);
                                    }
                                    else
                                    {
                                        // remove for our service resolution array
                                        [self.serviceArray removeObject:sender];
                                    }
                                }
                                else
                                {
                                    // NSLog(@"Error testing URL: %@", error);
                                    
                                    // remove for our service resolution array
                                    [self.serviceArray removeObject:sender];
                                }
                                
                            }] resume];
                }
            }
        }
    }
}

- (void)netService:(NSNetService *)sender
     didNotResolve:(NSDictionary *)errorDict
{
    // NSLog(@"Error resolving service: %@", errorDict);
}

#endif

@end
