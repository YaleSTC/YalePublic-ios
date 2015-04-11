//
//  YPMainViewController.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPMainViewController.h"
#import "YPNewsTopicsTableViewController.h"
#import "YPVideosPlaylistTableViewController.h"
#import "YPAthleticsViewController.h"
#import "YPInfoViewViewController.h"
#import "YPPhotoDetailViewController.h"
#import "YPOrientationViewController.h"
#import "YPDirectoryTableViewController.h"
#import "YPMapsViewController.h"
#import "YPEventsViewController.h"
#import "YPTheme.h"
#import <PureLayout/PureLayout.h>
#import "YPAppDelegate.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

#define COLLECTIONVIEW_REUSE_IDENTIFIER @"MainViewButtonCell"

#define UNDER_TEXT_FONT [UIFont systemFontOfSize:14] //was size 10, then 12. now bigger text fits
#define IMAGE_TEXT_MARGIN 10
#define UNDER_TEXT_HEIGHT 20

typedef enum {
  YaleEventOrientation,
  YaleEventCommencement
} YaleEvent;

@interface YPMainViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIBarButtonItem *infoButton;
@property (nonatomic, strong) NSArray *buttonImageTitles;
@property (nonatomic, strong) NSArray *buttonUnderTexts;
@property CGSize iconSize;
@property BOOL loaded;

@end

@implementation YPMainViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Main VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - View Setup

- (void)setupNavigationBar
{
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
  self.navigationItem.rightBarButtonItem = self.infoButton;
  [infoButton addTarget:self action:@selector(viewInfo) forControlEvents:UIControlEventTouchUpInside];
  //navigationBar.barStyle = UIBarStyleBlack;
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

- (void)setupButtonViews
{
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  CGSize viewSize = self.view.bounds.size;
  CGSize iconSize = self.iconSize;
  CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
  CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
  // buttons contain icons
  CGFloat horizontalMarginToIcons = (iconSize.height == 57) ? 20 : 30; //this is the horizontal margin to the icons (not the buttons)
  CGFloat buttonWidth = MIN(iconSize.width*3, viewSize.width/3); //make it big enough to fit the text below the button, even if the text is long like this text is long.
  CGFloat leftMargin = horizontalMarginToIcons-(buttonWidth-iconSize.width)/2;
  CGFloat buttonHeight = iconSize.height + IMAGE_TEXT_MARGIN + UNDER_TEXT_HEIGHT;
  CGFloat horizontalSpacing = (viewSize.width - buttonWidth*3 - leftMargin*2) / 2; //between buttons
  CGFloat horizontalSpacingBetweenIcons = (viewSize.width - iconSize.width*3 - horizontalMarginToIcons*2) / 2; //to keep vertical spacing stable
  CGFloat verticalSpacing = horizontalSpacingBetweenIcons - 20; //what is this? Well, it looks good
  
  //iPhone 4s
  if (screenSize.height <= 568)
    verticalSpacing -= 10;
  
  // height of all stuff including buttons and text (this is just the bottom of the lowest text, without a top margin)
  CGFloat totalHeight = 2*verticalSpacing + 3*buttonHeight;
  // center in screen, vertically
  CGFloat topMargin = (screenSize.height - totalHeight)/2 - navigationBarSize.height - statusBarSize.height;
  
  for (int row=0; row<3; row++) {
    for (int col=0; col<3; col++) {
      int index = row*3+col;
      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      button.frame = CGRectMake(leftMargin+col*horizontalSpacing+col*buttonWidth, topMargin+row*verticalSpacing+row*buttonHeight, buttonWidth, buttonHeight);
      [button addTarget:self action:@selector(pushViewController:) forControlEvents:UIControlEventTouchUpInside];
      [button addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
      [button addTarget:self action:@selector(buttonUnhighlight:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel|UIControlEventTouchDragExit];
      button.tag = index;
      UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonWidth/2-self.iconSize.width/2, 0, self.iconSize.width, self.iconSize.height)];
      iconView.image = [YPMainViewController imageWithImage:[UIImage imageNamed:self.buttonImageTitles[index]] scaledToSize:self.iconSize];
      [button addSubview:iconView];
      UILabel *underText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconSize.height+IMAGE_TEXT_MARGIN, buttonWidth, UNDER_TEXT_HEIGHT)];
      underText.text = self.buttonUnderTexts[index];
      underText.font = UNDER_TEXT_FONT;
      underText.textAlignment = NSTextAlignmentCenter;
      underText.textColor = [UIColor whiteColor];
      [button addSubview:underText];
      [self.view addSubview:button];
    }
  }
}

- (void)buttonHighlight:(UIButton *)button
{
  button.alpha=0.5;
}
- (void)buttonUnhighlight:(UIButton *)button
{
  button.alpha=1;
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
                            @"Events", @"Transit", [self currentEvent]==YaleEventOrientation ? @"Orientation" : @"Commencement", @"Athletics"];
  self.buttonImageTitles = @[@"NewsIcon", @"DirectoryIcon", @"MapsIcon", @"VideosIcon", @"PhotosIcon", @"EventsIcon", @"TransitIcon", [self currentEvent]==YaleEventOrientation ? @"OrientationIcon2019" : @"CommencementIcon2015", @"AthleticsIcon"];

  [self setupNavigationBar];
  [self setupBackgroundImage];
}

- (void)viewWillAppear:(BOOL)animated
{
  if (!self.loaded) {
    [self setupButtonViews];
    self.loaded = YES;
  }
  //[[UIApplication sharedApplication].delegate window].rootViewController = self.navigationController;
  [super viewWillAppear:animated];
}

//commencement is 1 january till 1 june
//dates stored in month + day/monthlength format. Uniform distribution isn't necessary, just strict monotonicity
#define ORIENTATION_START_DATE (6+2/30.)
#define COMMENCEMENT_START_DATE (1+1/31.)

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
    return ORIENTATION_START_DATE <= currentDate && currentDate < COMMENCEMENT_START_DATE ? YaleEventOrientation : YaleEventCommencement;
  } else {
    //in year, commencement comes first
    return ORIENTATION_START_DATE <= currentDate || currentDate < COMMENCEMENT_START_DATE ? YaleEventOrientation : YaleEventCommencement;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark Connect with other VCs

- (void)pushViewController:(UIButton *)button
{
  NSString *underText = self.buttonUnderTexts[button.tag];
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
    YPPhotoDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailVC"];
    
    // Have to provide album title and photoSetId
    detailViewController.albumTitle = @"Photos";
    detailViewController.photoSetId = @"INSTAGRAM";
    [self.navigationController pushViewController:detailViewController animated:YES];
  } else if ([underText isEqualToString:@"Athletics"]) {
    [self.navigationController pushViewController:[[YPAthleticsViewController alloc] init] animated:YES];
  } else if ([underText isEqualToString:@"Orientation"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPOrientationViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *orientationVC = [storyboard instantiateViewControllerWithIdentifier:@"OrientationVC"];
    [self.navigationController pushViewController:orientationVC animated:YES];
  } else if ([underText isEqualToString:@"Commencement"]) {
    [self.navigationController pushViewController:[[YPWebViewController alloc] initWithTitle:@"Commencement" initialURL:@"http://commencement.yale.edu/"] animated:YES];
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
  [self.navigationController pushViewController:infoVC animated:YES];
  // [self.navigationController presentViewController:infoVC animated:YES completion:nil];
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
