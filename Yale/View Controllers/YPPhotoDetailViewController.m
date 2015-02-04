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
#import "YPGlobalHelper.h"

#define IMAGES_PER_ROW (2)

//for debugging, can show border around cells
//#import <QuartzCore/QuartzCore.h>

@interface YPPhotoDetailViewController () {
  __block NSMutableArray *_photoSet;
  UIView *overlayView;
  UIImageView *thumbnailImageView;
  UIImageView *fullscreenImageView;
  UILabel *title;
  NSIndexPath *selectedIndexPath;
  NSMutableArray *rowHeights; //array of NSNumbers.
}

@end

//if there is less than this amount of seconds between photo loads, don't update the view multiple times in succession. Wait for a pause, then update the view.
#define LOAD_WAIT 0.1

@implementation YPPhotoDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"set album title");
  self.navigationItem.title = self.albumTitle;
  [self loadPhotos];
  self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height);
}

-(void)loadPhotos {
  _photoSet = [NSMutableArray array];
  rowHeights = [NSMutableArray array];
  
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  [flickr getPhotosForSet:self.photoSetId completionBlock:^(NSDictionary *response) {
    
    NSLog(@"%@", response);
    
    // Get a list of URLs
    NSMutableArray *photoURLs = [NSMutableArray array];
    for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photoset.photo"]) {
      NSURL *url = [flickr urlForImageFromDictionary:photoDictionary];
      [photoURLs addObject:@{@"url": url, @"title": photoDictionary[@"title"]}];
    }
    
    // Download image for each URL
    //for (NSURL *url in photoURLs) {
    for (NSDictionary *photo in photoURLs) {
      [flickr downloadImageForURL:photo[@"url"] completionBlock:^(UIImage *image) {
        //NSLog(@"add image, %@", image);
        //this threw an exception when image was nil or when photo["title"] was nil
        if (image && photo[@"title"]) {
          NSUInteger indexForRow = _photoSet.count/IMAGES_PER_ROW; //this is the index of the last row
          [_photoSet addObject:@{@"image":image, @"title": photo[@"title"]}];
          NSMutableArray *imagesInRow = [NSMutableArray array]; //to find the size, consider all images in row
          for (NSUInteger i=indexForRow*IMAGES_PER_ROW; i<_photoSet.count; i++) {
            [imagesInRow addObject:_photoSet[i][@"image"]];
          }
          CGFloat totalWidthWithHeight1 = 0;
          for (UIImage *img in imagesInRow) {
            totalWidthWithHeight1 += img.size.width / img.size.height;
          }
          CGFloat totalWidthDestination = self.view.bounds.size.width-2*IMAGES_PER_ROW;//with some space in between
          while (rowHeights.count<indexForRow+1) [rowHeights addObject:@(0)];
          rowHeights[indexForRow]=@(totalWidthDestination/totalWidthWithHeight1);
          //don't reload the data too quickly, it looks flashy.
          [NSObject cancelPreviousPerformRequestsWithTarget:self.photoCollectionView selector:@selector(reloadData) object:nil];
          if (_photoSet.count==photoURLs.count) {
            //this is the last photo downloaded.
            [self.photoCollectionView reloadData];
            [YPGlobalHelper hideNotificationView];
          } else {
            [self.photoCollectionView performSelector:@selector(reloadData) withObject:nil afterDelay:LOAD_WAIT];
          }
        }
      }];
    }
  }];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                     dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                     forIndexPath:indexPath];
  
  UIImage *image = _photoSet[indexPath.row][@"image"];
  cell.photoImageView.image = image;
  cell.photoTitle = _photoSet[indexPath.row][@"title"];
  [cell.photoImageView setContentMode:UIViewContentModeScaleAspectFit];
  /*
  [cell.layer setBorderColor:[UIColor colorWithRed:213.0/255.0f green:210.0/255.0f blue:199.0/255.0f alpha:1.0f].CGColor];
  [cell.layer setBorderWidth:1.0f];
  cell.photoImageView.layer.borderColor=[UIColor blackColor].CGColor;
  cell.photoImageView.layer.borderWidth=2;
  */
  [cell removeConstraints:cell.constraints];
  //cell.translatesAutoresizingMaskIntoConstraints = NO;
  //cell.photoImageView.translatesAutoresizingMaskIntoConstraints = NO;
  UIView *imageViewSuperview = cell.photoImageView.superview;
  [imageViewSuperview addConstraint:[NSLayoutConstraint constraintWithItem:cell.photoImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:imageViewSuperview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
  [imageViewSuperview addConstraint:[NSLayoutConstraint constraintWithItem:cell.photoImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageViewSuperview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
  [imageViewSuperview addConstraint:[NSLayoutConstraint constraintWithItem:cell.photoImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:imageViewSuperview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
  [imageViewSuperview addConstraint:[NSLayoutConstraint constraintWithItem:cell.photoImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:imageViewSuperview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
  //CGSize photoSize = [self collectionView:collectionView layout:self.collectionViewLayout sizeForItemAtIndexPath:indexPath];
  //cell.photoImageView.frame = CGRectMake(0, 0, photoSize.width, photoSize.height);
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UIImage *image = _photoSet[indexPath.row][@"image"];
  NSUInteger row = indexPath.row/IMAGES_PER_ROW;
  return CGSizeMake([rowHeights[row] doubleValue]*image.size.width/image.size.height, [rowHeights[row] doubleValue]);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:indexPath];
  selectedIndexPath = indexPath;
  NSLog(@"selected indexPath %@", indexPath);
  
  overlayView = [[UIView alloc] init];
  
  thumbnailImageView = selectedCell.photoImageView;
  UIImage *image = [thumbnailImageView image];
  fullscreenImageView = [[UIImageView alloc] initWithImage:image];
  [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
  
  CGRect tempPoint = CGRectMake(thumbnailImageView.center.x, thumbnailImageView.center.y, 0, 0);
  CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
  
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

-(void)fullScreenImageViewLeftSwiped:(UIGestureRecognizer *)gestureRecognizer
{
  
  //first check if there is more pictures to see.
  if(selectedIndexPath.row < (_photoSet.count-1))
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row+1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    
    fullscreenImageView.image = _photoSet[newIndex.row][@"image"];
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
    
    fullscreenImageView.image = _photoSet[newIndex.row][@"image"];
    [title setText:_photoSet[newIndex.row][@"title"]];
  }
}

- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
  
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
