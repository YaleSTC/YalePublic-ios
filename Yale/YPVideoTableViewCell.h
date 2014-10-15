//
//  YPVideoTableViewCell.h
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPVideoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageContainer;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadTimeLabel;

@end
