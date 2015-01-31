//
//  AppDelegate.h
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JGProgressHUD/JGProgressHUD.h>

@interface YPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JGProgressHUD     *sharedNotificationView;


@end

