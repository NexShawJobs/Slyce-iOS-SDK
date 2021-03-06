//
//  AppDelegate.m
//  SlyceSDKDemo
//
//  Created by Nathan Gurfinkel on 22//15.
//  Copyright (c) 2015 Slyce. All rights reserved.
//

#import "AppDelegate.h"
#import <SlyceSDK/SlyceSDK.h>

#define SLYCE_CLIENT_ID @"yourClientId"

@interface AppDelegate ()

@end

@implementation AppDelegate

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Premium users
    NSError *error = nil;
    
    SFSlyce *slyce = [SFSlyce sharedInstance];

    BOOL success = [slyce openWithClientID:SLYCE_CLIENT_ID error:&error];
    
    if (success)
    {
        //Success
        NSLog(@"Slyce SDK successfully opened");
    }
    else
    {
        //Error
        NSLog(@"Slyce SDK failed to open with error = %@", [error sf_message]);
    }
    

    /*
    // Public users
    
    BOOL success = [slyce openWithAppKey:@"Your AppKey" appSecret:@"Your appSecret" error:&error];
    if (!success)
    {
        //Success
        NSLog(@"Slyce SDK successfully opened");
    }
    else
    {
        //Error
        NSLog(@"Slyce SDK failed to open with error = %@", [error sf_message]);
    }
    */
    
    return YES;
}


@end
