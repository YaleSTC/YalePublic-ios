//
//  YPStandardCell.h
//  Yale
//
//  Created by Charly Walther on 10/4/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPStandardCell : UITableViewCell

#warning TODO(Charly) move the IBOutlet out of the storyboard.
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
