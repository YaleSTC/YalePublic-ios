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
        NSURL *smallPhotoUrl = [flickr urlForImageFromDictionary:photoDictionary largeSize:NO];
        NSURL *largePhotoUrl = [flickr urlForImageFromDictionary:photoDictionary largeSize:YES];
        //[photoURLs addObject:url];
        [photoURLs addObject:@{@"smallPhotoUrl": smallPhotoUrl, @"largePhotoUrl":largePhotoUrl, @"title": photoDictionary[@"title"]}];
      }
    
    // Download image for each URL
    //for (NSURL *url
    for (NSDictionary *photo in photoURLs) {
      [flickr downloadImageForURL:photo[@"smallPhotoUrl"] completionBlock:^(UIImage *image) {
        //NSLog(@"add image, %@", image);
        //this threw an exception when image was nil or when photo["title"] was nil
        if (image && photo[@"title"]) {
          NSUInteger indexForRow = _photoSet.count/IMAGES_PER_ROW; //this is the index of the last row
          [_photoSet addObject:@{@"smallImage":image, @"title": photo[@"title"], @"largePhotoUrl":photo[@"largePhotoUrl"]}];
          NSMutableArray *imagesInRow = [NSMutableArray array]; //to find the size, consider all images in row
          for (NSUInteger i=indexForRow*IMAGES_PER_ROW; i<_photoSet.count; i++) {
            [imagesInRow addObject:_photoSet[i][@"smallImage"]];
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
    //[YPGlobalHelper hideNotificationView];
  }];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                     dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                     forIndexPath:indexPath];
  
  UIImage *smallImage = _photoSet[indexPath.row][@"smallImage"];
  cell.photoImageView.image = smallImage;
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
  UIImage *image = _photoSet[indexPath.row][@"smallImage"];
  NSUInteger row = indexPath.row/IMAGES_PER_ROW;
  return CGSizeMake([rowHeights[row] doubleValue]*image.size.width/image.size.height, [rowHeights[row] doubleValue]);
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
  
  //For saving a photo
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
    alertTitle = @"Failed to Save";
  }else {
    alertTitle = @"Photo Saved Successfully";
  }
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                 message:nil
                                                          preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
  [alert addAction:okAction];
  NSLog(@"%@", alertTitle);
  [self presentViewController:alert animated:YES completion:nil];
}

//UIImageView image transition crossfade
void crossfade(UIImageView* view, UIImage* image, bool isRightSwiped)
{
  //bool isRightSwiped -> YES: kCATransitionFromLeft
  CATransition* transition = [CATransition animation];
  transition.duration = 0.5f;
  transition.subtype = isRightSwiped ? kCATransitionFromLeft: kCATransitionFromRight;
  transition.type = kCATransitionReveal;
  
  [view.layer addAnimation:transition forKey:nil];
  
  view.image = image;
}

-(void)fullScreenImageViewLeftSwiped:(UIGestureRecognizer *)gestureRecognizer
{
  
  //first check if there is more pictures to see.
  if(selectedIndexPath.row < (_photoSet.count-1))
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row+1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    
    crossfade(fullscreenImageView, [self photoForSelectedIndex], NO);
    //fullscreenImageView.image = _photoSet[newIndex.row][@"image"];
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
    crossfade(fullscreenImageView,[self photoForSelectedIndex], YES);
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
#warning error handling necessary
    }
     ];
    return _photoSet[selectedIndexPath.row][@"smallImage"];
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
