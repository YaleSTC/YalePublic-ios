//
//  YPTheme.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPTheme.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation YPTheme

BOOL aprilFools() {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:@"MM dd"];}
    return [[formatter stringFromDate:[NSDate date]] isEqualToString:@"04 01"];
}

+ (UIColor *)navigationBarColor
{
  if (aprilFools()) return [UIColor colorWithRed:201./255 green:0 blue:22./255 alpha:1];
  return [UIColor colorWithRed:15/255. green:68/225. blue:129/225. alpha:1];
  //return RGB(26.0, 62.0, 123.0);
  //return RGB(14.0, 54.0, 98.0);
}

+ (UIColor *)textColor
{
  return [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];
}

@end
