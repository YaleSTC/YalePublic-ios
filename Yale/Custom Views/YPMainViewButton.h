//
//  YPMainViewButton.h
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPMainViewButton : UIControl
#define IMAGE_TEXT_MARGIN 10
#define UNDER_TEXT_HEIGHT 20

/**
 *  The text that appears under the icon.
 */
@property (nonatomic, strong) NSString *underText;
@property (nonatomic, strong) UILabel     *underTextLabel;


/**
 *  The icon of the button.
 */
@property (nonatomic, strong) UIImage *icon;


- (CGSize)textLabelSize;
@end
