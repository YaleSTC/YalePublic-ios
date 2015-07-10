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

+ (NSString *)orientationYear {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy"];
  NSString *yearString = [formatter stringFromDate:[NSDate date]];
  int yearInt = [yearString intValue];
  // orientation starts on june second and ends on december 31. so if it's currently 2015 I want orientation of 2019
  return [NSString stringWithFormat:@"%d", yearInt+4];
}

+ (NSString *)loadedTitle
{
  return @"Orientation";
}

- (NSString *)initialURL
{
  return [@"http://yalecollege.yale.edu/new-students/class-" stringByAppendingString:[self.class orientationYear]];
}

@end