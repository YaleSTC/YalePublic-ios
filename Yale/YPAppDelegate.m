//
//  AppDelegate.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPAppDelegate.h"
#import "YPTheme.h"
#import <FLEX/FLEXManager.h>
#import <GAI.h>

@interface YPAppDelegate ()

@end

@implementation YPAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window makeKeyAndVisible];
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPMainViewController"
                                                       bundle:[NSBundle mainBundle]];
  UINavigationController *rootVC = [storyboard instantiateViewControllerWithIdentifier:@"MainVC Root"];
    
  self.window.rootViewController = rootVC;

  /*
  testing only
    
  UIStoryboard *photoStoryboard = [UIStoryboard storyboardWithName:@"YPPhotoViewController"
                                                              bundle:[NSBundle mainBundle]];
  UINavigationController *photoVC = [photoStoryboard instantiateViewControllerWithIdentifier:@"PhotoVC Root"];
    
  [rootVC pushViewController:photoVC animated:NO];
    
  end testing only
  */
    
  [[UINavigationBar appearance] setBarTintColor:[YPTheme navigationBarColor]];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  
#ifdef DEBUG
  [[FLEXManager sharedManager] showExplorer];
#endif
  
  //Google Analytics
  
  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  
  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;
  
  // Optional: set Logger to VERBOSE for debug information.
  [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
  
  // Initialize tracker. Replace with your tracking ID.
  [[GAI sharedInstance] trackerWithTrackingId:@"UA-55867542-1"];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
