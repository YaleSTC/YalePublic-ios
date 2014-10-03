//
//  YPMainViewButton.h
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPMainViewButton : UIControl

/**
 *  The text that appears under the icon.
 */
@property (nonatomic, strong) NSString *underText;

/**
 *  The icon of the button.
 */
@property (nonatomic, strong) UIImage *icon;

@end
