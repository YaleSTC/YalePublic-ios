//
//  YPPhotoDetailViewController.h
//  Yale
//
//  Created by Charly Walther on 10/5/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPPhotoDetailViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSString *albumTitle;
@property (strong, nonatomic) NSString *photoSetId;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;


@end
