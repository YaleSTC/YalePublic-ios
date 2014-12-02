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
#import "YPTheme.h"
#import "YPMainViewButton.h"
#import <PureLayout/PureLayout.h>

#define COLLECTIONVIEW_REUSE_IDENTIFIER @"MainViewButtonCell"

@interface YPMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UICollectionView *buttonCollectionView;
@property (nonatomic, strong) UIBarButtonItem *infoButton;
@property (nonatomic, strong) NSArray *buttonUnderTexts;

@end

@implementation YPMainViewController

#pragma mark - View Setup

- (void)setupNavigationBar
{
  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
  self.navigationItem.rightBarButtonItem = self.infoButton;
  [infoButton addTarget:self action:@selector(viewInfo) forControlEvents:UIControlEventTouchUpInside];
  
  self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
  self.title = @"Home";
}

- (void)setupBackgroundImage
{
  CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
  
  UIImage *backgroundImage;
  
  if (screenHeight == 568) {
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
  // 57 is the button width, 20 is the left margin to edge of screen
  flowLayout.minimumInteritemSpacing = ([UIScreen mainScreen].bounds.size.width - 57*3 - 20*2) / 2;
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
  

  
  [self.buttonCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
  [self.buttonCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
  [self.buttonCollectionView autoAlignAxisToSuperviewAxis:ALAxisVertical];
  [self.buttonCollectionView layoutIfNeeded];
  
  self.buttonCollectionView.delegate   = self;
  self.buttonCollectionView.dataSource = self;
}

#pragma mark - View life cycles

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.screenName = @"Main View";
  
  self.buttonUnderTexts = @[@"News", @"Directory", @"Maps", @"Videos", @"Photos",
                            @"Events", @"Transit", @"Athletics", @"Orientation"];
  
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  YPMainViewButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTIONVIEW_REUSE_IDENTIFIER
                                                                                       forIndexPath:indexPath];
  
  switch (indexPath.row) {
    case 0:
      cell.button.icon = [UIImage imageNamed:@"NewsIcon"];
      break;
    case 1:
      cell.button.icon = [UIImage imageNamed:@"DirectoryIcon"];
      break;
    case 2:
      cell.button.icon = [UIImage imageNamed:@"MapsIcon"];
      break;
    case 3:
      cell.button.icon = [UIImage imageNamed:@"VideosIcon"];
      break;
    case 4:
      cell.button.icon = [UIImage imageNamed:@"PhotosIcon"];
      break;
    case 5:
      cell.button.icon = [UIImage imageNamed:@"EventsIcon"];
      break;
    case 6:
      cell.button.icon = [UIImage imageNamed:@"TransitIcon"];
      break;
    case 7:
      cell.button.icon = [UIImage imageNamed:@"AthleticsIcon"];
      break;
    case 8:
      cell.button.icon = [UIImage imageNamed:@"OrientationIcon"];
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
  UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
  YPMainViewButton *button   = [YPMainViewButton newAutoLayoutView];
  [cell.contentView addSubview:button];
  [button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
  [button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
  button.underText = self.buttonUnderTexts[indexPath.row];
  button.icon      = [UIImage imageNamed:@"TestButtonImage"];
  return button.intrinsicContentSize;
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPAthleticsViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *athleticsVC = [storyboard instantiateViewControllerWithIdentifier:@"AthleticsVC"];
    [self.navigationController pushViewController:athleticsVC animated:YES];
  } else if ([underText isEqualToString:@"Orientation"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPOrientationViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *orientationVC = [storyboard instantiateViewControllerWithIdentifier:@"OrientationVC"];
    [self.navigationController pushViewController:orientationVC animated:YES];
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
  }
}

- (void)viewInfo
{
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPInfoViewController"
                                                       bundle:[NSBundle mainBundle]];
  UINavigationController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"InfoVC Root"];
  [self.navigationController presentViewController:infoVC animated:YES completion:nil];
}


@end
