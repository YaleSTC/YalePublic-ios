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
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                  dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                  forIndexPath:indexPath];
  

  cell.photoImageView.image = _photoSet[indexPath.row];
  
  // Add TapGestureRecognizer
  [cell.photoImageView setUserInteractionEnabled:YES];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(photoImageViewTap:)];
  [tap setNumberOfTouchesRequired:1];
  [tap setNumberOfTapsRequired:1];
  [cell.photoImageView addGestureRecognizer:tap];
  
  return cell;
}

-(void)photoImageViewTap:(UITapGestureRecognizer*)gesture {
    NSLog(@"tap");
  
  CGPoint pointInCollectionView = [gesture locationInView:self.collectionView];
  NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
  YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:selectedIndexPath];
  
  thumbnailImageView = selectedCell.photoImageView; // or whatever cell element holds your image that you want to zoom
  
  fullscreenImageView = [[UIImageView alloc] init];
  [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
  
  fullscreenImageView.image = [thumbnailImageView image];
  CGRect tempPoint = CGRectMake(thumbnailImageView.center.x, thumbnailImageView.center.y, 0, 0);
  CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:selectedIndexPath]];
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
                   }];
  [self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
  
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
