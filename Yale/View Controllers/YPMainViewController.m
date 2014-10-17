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
  self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
  self.navigationController.navigationBar.translucent = YES;
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
  flowLayout.minimumInteritemSpacing = 20;
  flowLayout.minimumLineSpacing      = 20;
  
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  self.buttonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)
                                                 collectionViewLayout:flowLayout];
  [self.buttonCollectionView registerClass:[YPMainViewButtonCollectionViewCell class]
                forCellWithReuseIdentifier:COLLECTIONVIEW_REUSE_IDENTIFIER];
  self.buttonCollectionView.opaque = NO;
  self.buttonCollectionView.backgroundColor = [UIColor clearColor];
  
  self.buttonCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.view addSubview:self.buttonCollectionView];
  
  CGFloat navBarHeight    = [self.navigationController.navigationBar frame].size.height;
  CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  
  [self.buttonCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20 + navBarHeight + statusBarHeight];
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
  cell.button.icon = [UIImage imageNamed:@"TestButtonImage"];
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
  }
  if ([underText isEqualToString:@"Videos"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPVideosViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *videosVC = [storyboard instantiateViewControllerWithIdentifier:@"VideosVC"];
    [self.navigationController pushViewController:videosVC animated:YES];
  }
  if ([underText isEqualToString:@"Photos"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPPhotoViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *newsVC = [storyboard instantiateViewControllerWithIdentifier:@"PhotoVC"];
    [self.navigationController pushViewController:newsVC animated:YES];
  }
}


@end
