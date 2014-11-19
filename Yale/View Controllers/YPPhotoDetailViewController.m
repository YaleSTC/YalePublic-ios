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
  UIView *overlayView;
  UIImageView *thumbnailImageView;
  UIImageView *fullscreenImageView;
  UILabel *title;
  NSIndexPath *selectedIndexPath;
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
    
    NSLog(@"%@", response);
    
      // Get a list of URLs
      NSMutableArray *photoURLs = [NSMutableArray array];
      for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photoset.photo"]) {
        NSURL *smallPhotoUrl = [flickr urlForImageFromDictionary:photoDictionary largeSize:NO];
        NSURL *largePhotoUrl = [flickr urlForImageFromDictionary:photoDictionary largeSize:YES];
        //[photoURLs addObject:url];
        [photoURLs addObject:@{@"smallPhotoUrl": smallPhotoUrl, @"largePhotoUrl":largePhotoUrl, @"title": photoDictionary[@"title"]}];
      }
    
      // Download image for each URL
      //for (NSURL *url in photoURLs) {
       for (NSDictionary *photo in photoURLs) {
        //NSLog(@"%@", url);
        [flickr downloadImageForURL:photo[@"smallPhotoUrl"] completionBlock:^(UIImage *image) {
          //NSLog(@"add image, %@", image);
          [_photoSet addObject:@{@"smallImage":image, @"title": photo[@"title"], @"largePhotoUrl":photo[@"largePhotoUrl"]}];

          [self.photoCollectionView reloadData];
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
  

  cell.photoImageView.image = _photoSet[indexPath.row][@"smallImage"];
  cell.photoTitle = _photoSet[indexPath.row][@"title"];
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:indexPath];
  selectedIndexPath = indexPath;
  NSLog(@"selected indexPath %@", indexPath);
  
  overlayView = [[UIView alloc] init];
  
  thumbnailImageView = selectedCell.photoImageView;
  fullscreenImageView = [[UIImageView alloc] initWithImage:[self photoForSelectedIndex]];
  [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
  

  
  CGRect tempPoint = CGRectMake(thumbnailImageView.center.x, thumbnailImageView.center.y, 0, 0);
  CGRect startingPoint = [self.view convertRect:tempPoint
                                       fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
  
  [overlayView setFrame:startingPoint];
  [fullscreenImageView setFrame:startingPoint];
  
  
  [overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
  
  [self.view addSubview:overlayView];
  [self.view addSubview:fullscreenImageView];
  
  float marginFactor = 0.2;
  
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     [overlayView setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
                     
                     // we want some space to display a label in portrait mode
                     int margin = (marginFactor*fullscreenImageView.bounds.size.height);
                     CGRect fullscreenFrame = CGRectMake(0,(margin/2),self.view.bounds.size.width, (self.view.bounds.size.height-margin));
                     
                     [fullscreenImageView setFrame:fullscreenFrame];
                   }
                   completion:^(BOOL finished){
                     
                     // Create title label
                     int distanceFromBottom = ((marginFactor/2)*fullscreenImageView.bounds.size.height);
                     int labelYCoordinate = (overlayView.bounds.size.height-distanceFromBottom);
                     

                     title = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYCoordinate, self.view.bounds.size.width, distanceFromBottom)];
                     title.textColor = [UIColor whiteColor];
                     title.textAlignment = NSTextAlignmentCenter;
                     title.numberOfLines = 2;
                     title.text = selectedCell.photoTitle;
                     [overlayView addSubview:title];
                   }
   ];

  
  
  UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
  singleTap.numberOfTapsRequired = 1;
  singleTap.numberOfTouchesRequired = 1;
  [overlayView addGestureRecognizer:singleTap];
  [overlayView setUserInteractionEnabled:YES];
  
  UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewLeftSwiped:)];
  [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
  [overlayView addGestureRecognizer:leftSwipe];
  
  UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewRightSwiped:)];
  [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
  [overlayView addGestureRecognizer:rightSwipe];


}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  int cellSize = (self.view.frame.size.width - 2*2)/3;
  return CGSizeMake(cellSize, cellSize);
}

-(void)fullScreenImageViewLeftSwiped:(UIGestureRecognizer *)gestureRecognizer
{
  
  //first check if there is more pictures to see.
  if(selectedIndexPath.row < (_photoSet.count-1))
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row+1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    
    fullscreenImageView.image = [self photoForSelectedIndex];
    [title setText:_photoSet[newIndex.row][@"title"]];
  }

}

-(void)fullScreenImageViewRightSwiped:(UIGestureRecognizer *)gestureRecognizer
{
  
  if(selectedIndexPath.row > 0)
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row-1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    
    fullscreenImageView.image = [self photoForSelectedIndex];
    [title setText:_photoSet[selectedIndexPath.row][@"title"]];
  }
}

-(UIImage *)photoForSelectedIndex
{
  if(_photoSet[selectedIndexPath.row][@"largeImage"]){
    NSLog(@"returning large image");
    return _photoSet[selectedIndexPath.row][@"largeImage"];
  } else {
    NSLog(@"returning small image");
    // reload large image
    YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
    [flickr downloadImageForURL:_photoSet[selectedIndexPath.row][@"largePhotoUrl"] completionBlock:^(UIImage *image) {
      
      NSLog(@"downloaded large image: %@", image);
      [fullscreenImageView setImage:image];
      NSMutableDictionary *tempWithLargeImage = [[NSMutableDictionary alloc] initWithDictionary:_photoSet[selectedIndexPath.row]];
        tempWithLargeImage[@"largeImage"] = image;
        _photoSet[selectedIndexPath.row] = tempWithLargeImage;
      }
     ];
    return _photoSet[selectedIndexPath.row][@"smallImage"];
  }
}

- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"starting fullScreenImageViewTapped");
  //CGRect point=[self.view convertRect:thumbnailImageView.bounds fromView:thumbnailImageView];
    
     YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:selectedIndexPath];
    thumbnailImageView = selectedCell.photoImageView;
    
    CGRect point=[self.view convertRect:thumbnailImageView.bounds fromView:thumbnailImageView];
  
  
  gestureRecognizer.view.backgroundColor=[UIColor clearColor];
  [title removeFromSuperview];
  title = nil;
  
  [UIView animateWithDuration:0.5
                   animations:^{
                     [fullscreenImageView setFrame:point];
                   }
                   completion:^(BOOL finished){
                     [overlayView removeFromSuperview];
                     overlayView = nil;

                     [fullscreenImageView removeFromSuperview];
                     fullscreenImageView = nil;
                   }
   ];
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
