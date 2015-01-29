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
  NSLog(@"set album title: %@",self.albumTitle);
  
  //NavigationBar title
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = self.albumTitle;
  [titleLabel sizeToFit];
  self.navigationItem.titleView = titleLabel;
  //self.navigationItem.title = self.albumTitle;
  
  //BackButton
  UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
  backItem.title = @" ";
  self.navigationItem.backBarButtonItem = backItem;
  
  NSLog(@"backButtonTitle: %@",backItem.title);
  
  [self loadPhotos];
}

-(void)loadPhotos {
  _photoSet = [NSMutableArray array];
  
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  [flickr getPhotosForSet:self.photoSetId completionBlock:^(NSDictionary *response) {
    
    NSLog(@"%@", response);
    
    // Get a list of URLs
    NSMutableArray *photoURLs = [NSMutableArray array];
    for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photoset.photo"]) {
      NSURL *url = [flickr urlForImageFromDictionary:photoDictionary];
      //[photoURLs addObject:url];
      [photoURLs addObject:@{@"url": url, @"title": photoDictionary[@"title"]}];
    }
    
    // Download image for each URL
    //for (NSURL *url in photoURLs) {
    for (NSDictionary *photo in photoURLs) {
      //NSLog(@"%@", url);
      [flickr downloadImageForURL:photo[@"url"] completionBlock:^(UIImage *image) {
        //NSLog(@"add image, %@", image);
        [_photoSet addObject:@{@"image":image, @"title": photo[@"title"]}];
        [self.photoCollectionView reloadData];
      }];
    }
    [YPGlobalHelper hideNotificationView];
  }];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                     dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                     forIndexPath:indexPath];
  
  
  cell.photoImageView.image = _photoSet[indexPath.row][@"image"];
  cell.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
  cell.photoTitle = _photoSet[indexPath.row][@"title"];
  return cell;
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
  
  //For downloading a photo
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewLongPressed:)];
  [overlayView addGestureRecognizer:longPress];
  
}


-(void)fullScreenImageViewLongPressed:(UIGestureRecognizer *)gestureRecognizer
{
  //Show a dialog to download the photo
  UIAlertController* downloadSheet = [UIAlertController alertControllerWithTitle:@"Saving This Photo"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction* downloadingAction = [UIAlertAction actionWithTitle:@"Save"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                              //Saving Code here
                                                              UIImageWriteToSavedPhotosAlbum(fullscreenImageView.image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
                                                            }];
  UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction *action) {
                                                         //cancel
                                                       }];
  [downloadSheet addAction:downloadingAction];
  [downloadSheet addAction:cancelAction];
  [self presentViewController:downloadSheet animated:YES completion:nil];
}

-(void)savingImageIsFinished:(UIImage*)_image didFinishSavingWithError:(NSError*)_error contextInfo:(void*)_contextInfo
{
  NSString* alertTitle;
  if (_error) {
    alertTitle = @"Saving Failed";
  }else {
    alertTitle = @"Photo Saved Successfully!";
  }
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
  [alert addAction:okAction];
  [self presentViewController:alert animated:YES completion:nil];
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
