//
//  YPGlobalHelper.h
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JGProgressHUD/JGProgressHUD.h>

@interface YPGlobalHelper : NSObject
+ (void)showNotificationInViewController:(UIViewController *)vc
                                 message:(NSString *)msg
                                   style:(JGProgressHUDStyle)style;

+ (void)hideNotificationView;

+ (NSMutableDictionary *)getInformationForPerson:(NSString *)responseString;
+ (NSArray *)getPeopleList:(NSString *)responseString;

@end
