//
//  YPNewsArticleCell.h
//  Yale
//
//  Created by Minh Tri Pham on 10/9/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPNewsArticleCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *snippetLabel;

@end
