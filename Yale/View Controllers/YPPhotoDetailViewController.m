//
//  YPPhotoDetailViewController.m
//  Yale
//
//  Created by Charly Walther on 10/5/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPPhotoDetailViewController.h"
#import "YPFlickrCommunicator.h"
#import "YPPhotoCollectionViewCell.h"


@interface YPPhotoDetailViewController () {
  __block NSMutableArray *_photoSet;
}

@end

@implementation YPPhotoDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"set album title");
  self.navigationItem.title = self.albumTitle;
  [self loadPhotos];
}

-(void)loadPhotos {
  _photoSet = [[NSMutableArray alloc] init];
  //[_photoSet addObject:@"test"];
  
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [flickr getPhotosForSet:self.photoSetId completionBlock:^(NSDictionary *response) {
    

      //Load actual image files here
      //NSLog(@"%@", response);
    
      // Get a list of URLs
      NSMutableArray *photoURLs = [NSMutableArray array];
      for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photoset.photo"]) {
        NSURL *url = [flickr urlForImageFromDictionary:photoDictionary];
        [photoURLs addObject:url];
      }
    
      // Download image for each URL
      for (NSURL *url in photoURLs) {
        NSLog(@"%@", url);
        [flickr downloadImageForURL:url completionBlock:^(UIImage *image) {
          NSLog(@"add image, %@", image);
          [_photoSet addObject:image];
          NSLog(@"count: %ld", _photoSet.count);

          [self.photoCollectionView reloadData];
          
          
          dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoCollectionView reloadData];
          });
          }
         ];
      }

  }];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"yolo");
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                  dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                  forIndexPath:indexPath];
  

  cell.photoImageView.image = _photoSet[indexPath.row];
  return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return _photoSet.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
