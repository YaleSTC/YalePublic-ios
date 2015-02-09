//
//  YPOrientationViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 11/14/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPOrientationViewController.h"
#import "YPGlobalHelper.h"
@import WebKit;

@interface YPOrientationViewController ()

@end

@implementation YPOrientationViewController

+ (NSString *)loadedTitle
{
  return @"Orientation";
}

- (NSString *)initialURL
{
  return @"http://yalecollege.yale.edu/new-students/class-2018";
}

@end