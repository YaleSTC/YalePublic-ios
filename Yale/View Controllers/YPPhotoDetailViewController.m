//
//  YPPhotoDetailViewController.m
//  Yale
//
//  Created by Charly Walther on 10/5/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPPhotoDetailViewController.h"
#import "YPInstagramCommunicator.h"
#import "YPPhotoCollectionViewCell.h"
#import "YPGlobalHelper.h"
#import "Config.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

#define IMAGES_PER_ROW (2)

#define EXPAND_PHOTO_DURATION (0.4) //seconds of animation to get photo to full screen

@interface YPPhotoDetailViewController () {
  __block NSMutableArray *_photoSet;
  UIView *overlayView;
  UIImageView *thumbnailImageView;
  UIImageView *fullscreenImageView;
  UITextView *title;
  NSIndexPath *selectedIndexPath;
  NSMutableArray *rowHeights; //array of NSNumbers.
}

//to continue loading pages, have to keep this around. if photos are to be reloaded from scratch, should set this to nil.
@property (strong) YPInstagramCommunicator *instagramCommunicator;

@property (strong, nonatomic) UIProgressView *progressView;

@property int numberOfPhotosDownloading;
@property int numberOfPhotosToDownload;
@property NSUInteger totalBytesForAllPhotosDownloading;
@property NSUInteger totalBytesLoadedForAllPhotosDownloading;

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
  
  self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
  [self.view addSubview:self.progressView];
  
  [self loadPhotos];
  self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Photo VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
//when scroll to the bottom, do pagination with instagram photos.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

  if (self.instagramCommunicator && !self.instagramCommunicator.lastPageLoaded) { //if viewing instagram photos
    //if scrolled to bottom
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height) {
      if (!self.numberOfPhotosDownloading) {
        //no photos are currently being downloaded, so it's okay to load more
        [self loadPhotosFromInstagram]; //bypass the loadPhotos step, which resets the photos already set.
      }
    }
  }
}

-(void)loadPhotos {
  _photoSet = [NSMutableArray array];
  rowHeights = [NSMutableArray array];
  
  [self loadPhotosFromInstagram];
}

-(void)loadPhotosFromInstagram {
  if (self.instagramCommunicator.lastPageLoaded) return; //if at end, do nothing
  if (!self.instagramCommunicator) self.instagramCommunicator = [[YPInstagramCommunicator alloc] init];
  self.progressView.alpha = 1;
  self.progressView.progress = 0;
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  NSUInteger photosAlreadyLoaded = _photoSet.count;

  //will get the next page of photos
  [self.instagramCommunicator getPhotos:^(NSDictionary *response) {
    // Received photos
    
    //from http://instagram.com/developer/endpoints/
    //handle errors. this may be necessary if there have been >5000 requests per hour (over all users).
    if ([response[@"meta"][@"code"] intValue] != 200) { //200 is "no error" I think.
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Instagram error %d: %@", [response[@"meta"][@"code"] intValue], response[@"meta"][@"error_type"]] message:response[@"meta"][@"error_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
    }
    
    // Get a list of URLs
    NSMutableArray *photoURLs = [NSMutableArray array];
    for (NSDictionary *photoDictionary in response[@"data"]) {
      NSLog(@"parsing photo");
      NSLog(@"%@", photoDictionary);
      
      NSURL *url = [NSURL URLWithString:photoDictionary[@"images"][@"standard_resolution"][@"url"]];
      
      //the caption can be <null>, which caused this to crash. in this case the caption object is an NSNull object
      id caption = photoDictionary[@"caption"];
      if ([caption respondsToSelector:@selector(objectForKey:)] && [[caption objectForKey:@"text"] isKindOfClass:[NSString class]]) {
        caption = caption[@"text"];
      } else {
        caption = @"";
      }
      
      int createdInt = [photoDictionary[@"created_time"] intValue];
      NSTimeInterval timestamp = (NSTimeInterval)createdInt;
      NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
      
      [photoURLs addObject:@{@"url": url,
                             @"title": caption,
                             @"date":createdDate}];
      
    }
    [YPGlobalHelper hideNotificationView];

    // Download image for each URL
    for (NSDictionary *photo in photoURLs) {
      self.numberOfPhotosToDownload++;

      [self.instagramCommunicator downloadImageForURL:photo[@"url"] completionBlock:^(UIImage *image, NSUInteger bytesLoaded) {
        //[self.photoCollectionView reloadData];
        if (self.numberOfPhotosDownloading == self.numberOfPhotosToDownload) {
          //they've all been downloaded.
          self.totalBytesForAllPhotosDownloading = 0;
          self.totalBytesLoadedForAllPhotosDownloading = 0;
          self.numberOfPhotosDownloading = 0;
          self.numberOfPhotosToDownload = 0;
        }
        
        
        //this threw an exception when image was nil or when photo["title"] was nil
        if (image && photo[@"title"]) {
          NSUInteger indexForRow = _photoSet.count/IMAGES_PER_ROW; //this is the index of the last row
          [_photoSet addObject:@{@"image":image, @"title": photo[@"title"], @"date":photo[@"date"]}];
          NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
          [_photoSet sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
          CGFloat totalWidthWithHeight1 = 0;
          //to find the size, consider all images in row
          for (NSUInteger i=indexForRow*IMAGES_PER_ROW; i<_photoSet.count; i++) {
            UIImage *imageInRow = _photoSet[i][@"image"];
            totalWidthWithHeight1 += imageInRow.size.width / imageInRow.size.height;
          }
          CGFloat totalWidthDestination = self.view.bounds.size.width-IMAGES_PER_ROW;//with some space in between
          while (rowHeights.count<indexForRow+1) [rowHeights addObject:@(0)];
          rowHeights[indexForRow]=@(totalWidthDestination/totalWidthWithHeight1);
          //don't reload the data too quickly, it looks flashy.
          [NSObject cancelPreviousPerformRequestsWithTarget:self.photoCollectionView selector:@selector(reloadData) object:nil];
          if (_photoSet.count==photosAlreadyLoaded + photoURLs.count) {
            //this is the last photo downloaded.
            [self.photoCollectionView reloadData];
            //to indicate more photos have been loaded, flash scroll indicator. have to do after delay because otherwise it's in the wrong spot.
            [self.photoCollectionView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0];
          } else {
            [self.photoCollectionView performSelector:@selector(reloadData) withObject:nil afterDelay:LOAD_WAIT];
          }
        }
      } progressBlocks:^(NSUInteger bytesLoaded) {
        self.totalBytesLoadedForAllPhotosDownloading += bytesLoaded;
        [self showImageLoadingProgress];
      } :^(NSUInteger bytesTotal) {
        self.totalBytesForAllPhotosDownloading += bytesTotal;
        self.numberOfPhotosDownloading++;
        [self showImageLoadingProgress];
      }];
      
    }
    
  } progressBlock:^(double progress) {
    [self showProgress:progress];
  }];
}

- (void)showImageLoadingProgress
{
  //the downloaded portion of all photos that have started downloading.
  double downloadedPortion = (double)self.totalBytesLoadedForAllPhotosDownloading / (double)self.totalBytesForAllPhotosDownloading;
  //but it only accounts for a proportion of the photos that will be downloading.
  //this is the proportion of the photos which have started downloading
  double startedDownloading = (double)self.numberOfPhotosDownloading / (double)self.numberOfPhotosToDownload;
  [self showProgress:downloadedPortion * startedDownloading];
}

- (void)showProgress:(double)progress
{
  if (progress < self.progressView.progress - 0.5) { //goes down a long way. this is good for when resetting to 0, don't want to animate that.
    self.progressView.progress = progress;
  } else {
    [self.progressView setProgress:progress animated:YES];
  }
  if (progress < 0.99) {
    self.progressView.alpha = 1;
  } else if (self.progressView.alpha) {
    [UIView animateWithDuration:1 animations:^{
      self.progressView.alpha = 0;
    }];
  }
}

-(BOOL)isPhotoSameMonthWithPrevious:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return NO;
  }else {
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *compOne = [calender components:unitFlags fromDate:_photoSet[indexPath.row][@"date"]];
    NSDateComponents *compTwo = [calender components:unitFlags fromDate:_photoSet[indexPath.row - 1][@"date"]];
    return ([compOne month] == [compTwo month] && [compOne year] == [compTwo year]);
  }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPPhotoCollectionViewCell *cell = [self.photoCollectionView
                                     dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell"
                                     forIndexPath:indexPath];
  
  UIImage *image;
  image = _photoSet[indexPath.row][@"image"];
  cell.photoImageView.image = image;
  cell.photoTitle = _photoSet[indexPath.row][@"title"];
  
  cell.isNewMonth = ![self isPhotoSameMonthWithPrevious:indexPath];
  NSDateFormatter* df = [[NSDateFormatter alloc] init] ;
  [df setDateFormat:@"MMM ''yy"];
  cell.updatedMonthLabel.text = [df stringFromDate:_photoSet[indexPath.row][@"date"]];
  cell.updatedMonthLabel.hidden = !cell.isNewMonth;
  
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
  UIImage *image;
  image = _photoSet[indexPath.row][@"image"];
  NSUInteger row = indexPath.row/IMAGES_PER_ROW;
  return CGSizeMake([rowHeights[row] doubleValue]*image.size.width/image.size.height, [rowHeights[row] doubleValue]);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

  YPPhotoCollectionViewCell *selectedCell = (YPPhotoCollectionViewCell *) [self.photoCollectionView cellForItemAtIndexPath:indexPath];
  selectedIndexPath = indexPath;
  
  if (selectedIndexPath.row == _photoSet.count-1) {
    //the image that will be swiped onto the screen is the last one loaded so far.
    //so paginate.
    [self loadPhotosFromInstagram];
  }
  
  NSLog(@"selected indexPath %@", indexPath);
  
  //don't allow selections to happen really frequently
  // if the user double taps on a photo, two of the big images will load and only one can be dismissed.
  
  if (overlayView) return; //don't do anything if something is already being displayed.
  overlayView = [[UIView alloc] init];
  
  fullscreenImageView = [[UIImageView alloc] initWithImage:[self photoForSelectedIndex]];
  [fullscreenImageView setContentMode:UIViewContentModeScaleAspectFit];
  
  thumbnailImageView = selectedCell.photoImageView;
  
  CGRect tempPoint = thumbnailImageView.bounds;
  CGRect startingPoint = [self.view convertRect:tempPoint
                                       fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
  
  [overlayView setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
  overlayView.alpha = 0;
  [fullscreenImageView setFrame:startingPoint];
  
  
  [overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
  
  [self.view addSubview:overlayView];
  [self.view addSubview:fullscreenImageView];
  
  float marginFactor = 0.2;
  
  // we want some space to display a label in portrait mode
  int margin = (marginFactor*fullscreenImageView.bounds.size.height);
  CGRect fullscreenFrame = CGRectMake(0,(margin/2),self.view.bounds.size.width, (self.view.bounds.size.height-margin));
  
  // Create title label
  int distanceFromBottom = ((marginFactor)*fullscreenFrame.size.height);
  int labelYCoordinate = (overlayView.bounds.size.height-distanceFromBottom);
  title = [[UITextView alloc] initWithFrame:CGRectMake(0, labelYCoordinate + distanceFromBottom * 0.1, self.view.bounds.size.width, distanceFromBottom * 0.8 ) textContainer:nil];
  title.editable = NO;
  title.backgroundColor = [UIColor clearColor];
  title.textColor = [UIColor whiteColor];
  title.textAlignment = NSTextAlignmentCenter;
  title.text = selectedCell.photoTitle;
  title.alpha = 0;
  [overlayView addSubview:title];
  
  [UIView animateWithDuration:EXPAND_PHOTO_DURATION
                   animations:^{
                     [overlayView setAlpha:1];
                     title.alpha = 1;
                     
                     [fullscreenImageView setFrame:fullscreenFrame];
                   }
                   completion:^(BOOL finished){
                     
                   }
   ];
  
  [selectedCell bringSubviewToFront:selectedCell.updatedMonthLabel];
  
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
- (void) crossfade:(UIImageView*)view image:(UIImage*) image isRightSwiped:(BOOL) isRightSwiped{
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
  if (selectedIndexPath.row == _photoSet.count-2) {
    //the image that will be swiped onto the screen is the last one loaded so far.
    //so paginate.
    [self loadPhotosFromInstagram];
  }
  //first check if there is more pictures to see.
  if(selectedIndexPath.row < (_photoSet.count-1))
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row+1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    
    [self crossfade:fullscreenImageView image:[self photoForSelectedIndex] isRightSwiped:NO];
    //fullscreenImageView.image = _photoSet[newIndex.row][@"image"];
    [title setText:_photoSet[newIndex.row][@"title"]];
    
    if (![[self.photoCollectionView indexPathsForVisibleItems] containsObject:newIndex]) {
      [self.photoCollectionView scrollToItemAtIndexPath:newIndex atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
      
    }
    [self performSelector:@selector(updateThumbnail:) withObject:newIndex afterDelay:0.2f];
  }
  
}

-(void)fullScreenImageViewRightSwiped:(UIGestureRecognizer *)gestureRecognizer
{
  
  if(selectedIndexPath.row > 0)
  {
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:selectedIndexPath.row-1 inSection:selectedIndexPath.section];
    NSLog(@"new indexPath.orw %ld", (long)newIndex.row);
    selectedIndexPath = newIndex;
    [self crossfade:fullscreenImageView image:[self photoForSelectedIndex] isRightSwiped:YES];
    [title setText:_photoSet[selectedIndexPath.row][@"title"]];
    
    if (![[self.photoCollectionView indexPathsForVisibleItems] containsObject:newIndex]) {
      [self.photoCollectionView scrollToItemAtIndexPath:newIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
    [self performSelector:@selector(updateThumbnail:) withObject:newIndex afterDelay:0.2f];
    
  }
}

- (void)updateThumbnail:(NSIndexPath*)newIndex {
    YPPhotoCollectionViewCell *newSelectedCell = (YPPhotoCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:newIndex];
    thumbnailImageView = newSelectedCell.photoImageView;
}



-(UIImage *)photoForSelectedIndex
{
  return _photoSet[selectedIndexPath.row][@"image"];
}

- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
  
  CGRect point=[self.view convertRect:thumbnailImageView.bounds fromView:thumbnailImageView];
  
  //[self.photoCollectionView scrollToItemAtIndexPath:selectedIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
  [UIView animateWithDuration:EXPAND_PHOTO_DURATION
                   animations:^{
                     gestureRecognizer.view.alpha = 0;
                     [fullscreenImageView setFrame:point];
                     title.alpha = 0;
                   }
                   completion:^(BOOL finished){
                     [overlayView removeFromSuperview];
                     overlayView = nil;
                     
                     [fullscreenImageView removeFromSuperview];
                     fullscreenImageView = nil;
                     
                     [title removeFromSuperview];
                     title = nil;
                   }
   ];
  [self.photoCollectionView reloadData];    //so that the updatedMonthLabel will be reloaded
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
