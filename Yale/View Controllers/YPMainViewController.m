//
//  YPMainViewController.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPMainViewController.h"
#import "YPMainViewButtonCollectionViewCell.h"
#import "YPNewsTopicsTableViewController.h"
#import "YPVideosPlaylistTableViewController.h"
#import "YPAthleticsViewController.h"
#import "YPInfoViewViewController.h"
#import "YPOrientationViewController.h"
#import "YPDirectoryTableViewController.h"
#import "YPMapsViewController.h"
#import "YPEventsViewController.h"
#import "YPTheme.h"
#import "YPMainViewButton.h"
#import <PureLayout/PureLayout.h>

#define COLLECTIONVIEW_REUSE_IDENTIFIER @"MainViewButtonCell"
#define COMMENCEMENT_BUTTON_TEXT @"Commencement"

typedef enum {
  YaleEventOrientation,
  YaleEventCommencement
} YaleEvent;

@interface YPMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) UIBarButtonItem *infoButton;
@property (nonatomic, strong) NSArray *buttonUnderTexts;
@property CGSize iconSize;

@end

@implementation YPMainViewController

#pragma mark - View Setup

- (void)setupNavigationBar
{
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
  self.navigationItem.rightBarButtonItem = self.infoButton;
  [infoButton addTarget:self action:@selector(viewInfo) forControlEvents:UIControlEventTouchUpInside];
  navigationBar.barStyle = UIBarStyleBlack;
  navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
  navigationBar.translucent = NO;
  [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                    forBarPosition:UIBarPositionAny
                                        barMetrics:UIBarMetricsDefault];
  
  [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
  self.title = @"Home";
}

- (UIStatusBarStyle)preferredStatusBarStyle{
  return UIStatusBarStyleLightContent;
}

- (void)setupBackgroundImage
{
  CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
  
  UIImage *backgroundImage;
  
  if (screenHeight < 568) {
    backgroundImage = [UIImage imageNamed:@"background4"];
  } else if (screenHeight == 568) {
    backgroundImage = [UIImage imageNamed:@"background5"];
  } else if (screenHeight == 667) {
    backgroundImage = [UIImage imageNamed:@"background6"];
  } else if (screenHeight) {
    backgroundImage = [UIImage imageNamed:@"background6+"];
  } else {
    backgroundImage = [UIImage imageNamed:@"background5"];
  }
  
  self.backgroundImageView.image = backgroundImage;
  self.backgroundImageView.layer.zPosition -= 1;
}

- (void)setupButtonCollectionView
{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  CGFloat margin = (self.iconSize.height == 57) ? 20 : 30;
  flowLayout.minimumInteritemSpacing = ([UIScreen mainScreen].bounds.size.width - self.iconSize.height*3 - margin*2) / 2;
  flowLayout.minimumLineSpacing      = flowLayout.minimumInteritemSpacing - 20;
  
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  self.buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)
                                                 collectionViewLayout:flowLayout];
  [self.buttonCollectionView registerClass:[YPMainViewButtonCollectionViewCell class]
                forCellWithReuseIdentifier:COLLECTIONVIEW_REUSE_IDENTIFIER];
  self.buttonCollectionView.opaque = NO;
  self.buttonCollectionView.backgroundColor = [UIColor clearColor];
  
  self.buttonCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addSubview:self.buttonCollectionView];
  

  
  [self.buttonCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:margin];
  [self.buttonCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:margin];
  [self.buttonCollectionView autoAlignAxisToSuperviewAxis:ALAxisVertical];
  [self.buttonCollectionView layoutIfNeeded];
  
  self.buttonCollectionView.delegate   = self;
  self.buttonCollectionView.dataSource = self;
}

#pragma mark - View life cycles

- (void)viewDidLoad
{
  [super viewDidLoad];
  if (self.view.frame.size.height <= 568) {
    self.iconSize = CGSizeMake(57, 57);
  } else if (self.view.frame.size.height <= 667) {
    self.iconSize = CGSizeMake(66, 66);
  } else {
    self.iconSize = CGSizeMake(73, 73);
  }
  self.screenName = @"Main View";
  
  self.buttonUnderTexts = @[@"News", @"Directory", @"Maps", @"Videos", @"Photos",
                            @"Events", @"Transit", @"Athletics", [self currentEvent]==YaleEventOrientation ? @"Orientation" : COMMENCEMENT_BUTTON_TEXT];

  [self setupNavigationBar];
  [self setupBackgroundImage];
  [self setupButtonCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.buttonCollectionView reloadData];
  CGSize size = self.buttonCollectionView.collectionViewLayout.collectionViewContentSize;
  [self.buttonCollectionView autoSetDimensionsToSize:size];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return [self.buttonUnderTexts count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

#warning Find out when the icon should change
//dates stored in month + day/monthlength format. Uniform distribution isn't necessary, just strict monotonicity
#define ORIENTATION_START_DATE (4+10/30.)
#define COMMENCEMENT_START_DATE (8+1/31.)

//uses the current date to find the icon name for the event, like Orientation or Commencement
- (YaleEvent)currentEvent
{
  //get current month+day/monthlength of date.
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
  double month = [dateComponents month];
  double day = [dateComponents day];
  NSRange rangeInMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
  double currentDate = month + day / rangeInMonth.length;
  //don't make any assumptions about the dates, like which comes first in the year.
  if (ORIENTATION_START_DATE < COMMENCEMENT_START_DATE) {
    //in the year, orientation comes first
    return ORIENTATION_START_DATE < currentDate && currentDate < COMMENCEMENT_START_DATE ? YaleEventOrientation : YaleEventCommencement;
  } else {
    //in year, commencement comes first
    return ORIENTATION_START_DATE < currentDate || currentDate < COMMENCEMENT_START_DATE ? YaleEventOrientation : YaleEventCommencement;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPMainViewButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTIONVIEW_REUSE_IDENTIFIER
                                                                                       forIndexPath:indexPath];
  //this is just temporary, so the underText knows how big to be
  cell.button.bounds = CGRectMake(0, 0, self.iconSize.width, self.iconSize.height + IMAGE_TEXT_MARGIN + UNDER_TEXT_HEIGHT);
  switch (indexPath.row) {
    case 0:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"NewsIcon"] scaledToSize:self.iconSize];
      break;
    case 1:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"DirectoryIcon"] scaledToSize:self.iconSize];
      break;
    case 2:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"MapsIcon"] scaledToSize:self.iconSize];
      break;
    case 3:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"VideosIcon"] scaledToSize:self.iconSize];
      break;
    case 4:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"PhotosIcon"] scaledToSize:self.iconSize];
      break;
    case 5:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"EventsIcon"] scaledToSize:self.iconSize];
      break;
    case 6:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"TransitIcon"] scaledToSize:self.iconSize];
      break;
    case 7:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:@"AthleticsIcon"] scaledToSize:self.iconSize];
      break;
    case 8:
      cell.button.icon = [YPMainViewController imageWithImage:[UIImage imageNamed:[self currentEvent]==YaleEventOrientation ? @"OrientationIcon" : @"Mobile-Icons-2014-09-18_23"] scaledToSize:self.iconSize];
      break;

  }
  cell.button.underText = self.buttonUnderTexts[indexPath.row];
  [cell.button addTarget:self action:@selector(pushViewController:) forControlEvents:UIControlEventTouchUpInside];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(self.iconSize.width, self.iconSize.height + IMAGE_TEXT_MARGIN + UNDER_TEXT_HEIGHT);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
  return CGSizeZero;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark Connect with other VCs

- (void)pushViewController:(YPMainViewButton *)button
{
  NSString *underText = button.underText;
  if ([underText isEqualToString:@"News"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPNewsViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *newsVC = [storyboard instantiateViewControllerWithIdentifier:@"NewsVC"];
    [self.navigationController pushViewController:newsVC animated:YES];
  } else if ([underText isEqualToString:@"Videos"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPVideosViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *videosVC = [storyboard instantiateViewControllerWithIdentifier:@"VideosVC"];
    [self.navigationController pushViewController:videosVC animated:YES];
  } else if ([underText isEqualToString:@"Photos"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPPhotoViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *newsVC = [storyboard instantiateViewControllerWithIdentifier:@"PhotoVC"];
    [self.navigationController pushViewController:newsVC animated:YES];
  } else if ([underText isEqualToString:@"Athletics"]) {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPAthleticsViewController" bundle:[NSBundle mainBundle]];
    //UINavigationController *athleticsVC = [storyboard instantiateViewControllerWithIdentifier:@"AthleticsVC"];
    [self.navigationController pushViewController:[[YPAthleticsViewController alloc] init] animated:YES];
  } else if ([underText isEqualToString:@"Orientation"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPOrientationViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *orientationVC = [storyboard instantiateViewControllerWithIdentifier:@"OrientationVC"];
    [self.navigationController pushViewController:orientationVC animated:YES];
  } else if ([underText isEqualToString:COMMENCEMENT_BUTTON_TEXT]) {
    [self.navigationController pushViewController:[[YPWebViewController alloc] initWithTitle:COMMENCEMENT_BUTTON_TEXT initialURL:@"http://commencement.yale.edu/"] animated:YES];
  } else if ([underText isEqualToString:@"Transit"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPTransitViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *transitVC = [storyboard instantiateViewControllerWithIdentifier:@"TransitVC"];
    [self.navigationController pushViewController:transitVC animated:YES];
  } else if ([underText isEqualToString:@"Directory"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPDirectoryViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *directoryVC = [storyboard instantiateViewControllerWithIdentifier:@"DirectoryVC"];
    [self.navigationController pushViewController:directoryVC animated:YES];
  } else if ([underText isEqualToString:@"Maps"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPMapsViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *mapsVC = [storyboard instantiateViewControllerWithIdentifier:@"MapsVC"];
    [self.navigationController pushViewController:mapsVC animated:YES];
  } else if ([underText isEqualToString:@"Events"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPEventsViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *eventsVC = [storyboard instantiateViewControllerWithIdentifier:@"EventsVC"];
    [self.navigationController pushViewController:eventsVC animated:YES];
  }
}

- (void)viewInfo
{
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPInfoViewController"
                                                       bundle:[NSBundle mainBundle]];
  UINavigationController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"InfoVC Root"];
  [self.navigationController presentViewController:infoVC animated:YES completion:nil];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
  //UIGraphicsBeginImageContext(newSize);
  // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
  // Pass 1.0 to force exact pixel size.
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
