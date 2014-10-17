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
  UIImageView *thumbnailImageView;
  UIImageView *fullscreenImageView;
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
  _photoSet = [NSMutableArray array];
  
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [flickr getPhotosForSet:self.photoSetId completionBlock:^(NSDictionary *response) {
    
    
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
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                  dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                  forIndexPath:indexPath];
  

  cell.photoImageView.image = _photoSet[indexPath.row];
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:indexPath];
  
  thumbnailImageView = selectedCell.photoImageView;
  fullscreenImageView = [[UIImageView alloc] init];
  [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
  
  fullscreenImageView.image = [thumbnailImageView image];
  CGRect tempPoint = CGRectMake(thumbnailImageView.center.x, thumbnailImageView.center.y, 0, 0);
  CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
  [fullscreenImageView setFrame:startingPoint];
  [fullscreenImageView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
  [self.view addSubview:fullscreenImageView];
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     [fullscreenImageView setFrame:CGRectMake(0,
                                                              0,
                                                              self.view.bounds.size.width,
                                                              self.view.bounds.size.height)];
                   }];
  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
  singleTap.numberOfTapsRequired = 1;
  singleTap.numberOfTouchesRequired = 1;
  [fullscreenImageView addGestureRecognizer:singleTap];
  [fullscreenImageView setUserInteractionEnabled:YES];

}



- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
  
  CGRect point=[self.view convertRect:thumbnailImageView.bounds fromView:thumbnailImageView];
  
  gestureRecognizer.view.backgroundColor=[UIColor clearColor];
  [UIView animateWithDuration:0.5
                   animations:^{
                     [(UIImageView *)gestureRecognizer.view setFrame:point];
                   }
                   completion:^(BOOL finished){
                     [self animationDone:gestureRecognizer.view];
                   }
   
   ];  
}

-(void)animationDone:(UIView  *)view
{
  [fullscreenImageView removeFromSuperview];
  fullscreenImageView = nil;
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
