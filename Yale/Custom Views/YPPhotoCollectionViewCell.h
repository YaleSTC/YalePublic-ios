//
//  YPPhotoCollectionViewCell.h
//  Yale
//
//  Created by Charly Walther on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPPhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) NSString *photoTitle;

@end
