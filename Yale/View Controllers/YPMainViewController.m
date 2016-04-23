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
#import "YPEventsCategoriesViewController.h"
#import "YPDirectoryLinkViewController.h"
//#import "YPMapsViewController.h"
#import "YPMapsLinkViewController.h"
#import "YPEventsViewController.h"
#import "YPTheme.h"
#import <PureLayout/PureLayout.h>
#import "YPAppDelegate.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
@import QuartzCore;

#define COLLECTIONVIEW_REUSE_IDENTIFIER @"MainViewButtonCell"

#define UNDER_TEXT_FONT [UIFont systemFontOfSize:14] //was size 10, then 12. now bigger text fits
#define IMAGE_TEXT_MARGIN 10
#define UNDER_TEXT_HEIGHT 20

// location and size of date overlay on commencement icon.
#define IMAGE_OVERTEXT_MARGIN (-35)
#define IMAGE_OVERTEXT_HORIZ_OFFSET (1)
#define OVER_TEXT_HEIGHT 40

#define COMMENCEMENT_URL @"http://commencement.yale.edu/"
#define ARTS_EVENTS_URL @"http://artscalendar.yale.edu/"

// these really should be constants and not inline magic numbers
#define IPHONE_5_HEIGHT 568
#define IPHONE_6_HEIGHT 667 // same size as iPhone 6S
#define IPHONE_6PLUS_HEIGHT 736 // same size as iPhone 6S+

// different icon sizes for different phones
#define IPHONE_SMALL_ICON 57
#define IPHONE_MEDIUM_ICON 66
#define IPHONE_LARGE_ICON 73
#define IPAD_ICON 80

#define EVENT_COUNT (3)
typedef enum {
  YaleEventArts = 0,
  YaleEventCommencement,
  YaleEventOrientation,
} YaleEvent;

// dates stored in month, day format
int eventStartEndDates[EVENT_COUNT][4] = {
  {8, 31, 4, 15}, // arts events is 31 august till 15 april
  {4, 16, 6, 1}, // commencement is 16 april till 1 june
  {6, 2, 8, 30}, // orientation is 2 june till 30 august
};

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
  
  if (screenHeight < IPHONE_5_HEIGHT) {
    backgroundImage = [UIImage imageNamed:@"background4"];
  } else if (screenHeight == IPHONE_5_HEIGHT) {
    backgroundImage = [UIImage imageNamed:@"background5"];
  } else if (screenHeight == IPHONE_6_HEIGHT) {
    backgroundImage = [UIImage imageNamed:@"background6"];
  } else if (screenHeight <= IPHONE_6PLUS_HEIGHT) {
    backgroundImage = [UIImage imageNamed:@"background6+"];
  } else if (screenHeight) {
    // must be ipad
    backgroundImage = [UIImage imageNamed:@"backgroundiPadPro"];
  } else {
    backgroundImage = [UIImage imageNamed:@"background5"];
  }
  UIImageView *imageView = [[UIImageView alloc] initWithImage:backgroundImage];
  self.backgroundImageView = imageView;
  [self.view addSubview:imageView];
  self.backgroundImageView.image = backgroundImage;
  self.backgroundImageView.layer.zPosition -= 1;
  self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)setupButtonViews
{
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  CGSize viewSize = self.view.bounds.size;
  CGSize iconSize = self.iconSize;
  CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
  CGSize navigationBarSize = self.navigationController.navigationBar.frame.size;
  // buttons contain icons
  CGFloat horizontalMarginToIcons = (iconSize.height == IPHONE_SMALL_ICON) ? 20 : (iconSize.height == IPAD_ICON) ? 90 : 30; //this is the horizontal margin to the icons (not the buttons)
  CGFloat buttonWidth = MIN(iconSize.width*3, viewSize.width/3); //make it big enough to fit the text below the button, even if the text is long like this text is long.
  CGFloat leftMargin = horizontalMarginToIcons-(buttonWidth-iconSize.width)/2;
  CGFloat buttonHeight = iconSize.height + IMAGE_TEXT_MARGIN + UNDER_TEXT_HEIGHT;
  CGFloat horizontalSpacing = (viewSize.width - buttonWidth*3 - leftMargin*2) / 2; //between buttons
  CGFloat horizontalSpacingBetweenIcons = (viewSize.width - iconSize.width*3 - horizontalMarginToIcons*2) / 2; //to keep vertical spacing stable
  CGFloat verticalSpacing = horizontalSpacingBetweenIcons - 20; //what is this? Well, it looks good
  
  //iPhone 4s. also, apparently iPhone 5 (since the numbers work out that way)
  if (screenSize.height <= IPHONE_5_HEIGHT)
    verticalSpacing -= 10;
  
  // height of all stuff including buttons and text (this is just the bottom of the lowest text, without a top margin)
  CGFloat totalHeight = 2*verticalSpacing + 3*buttonHeight;
  // center in screen, vertically
  CGFloat topMargin = (screenSize.height - totalHeight)/2 - navigationBarSize.height - statusBarSize.height;
  
  // TODO: Move implementation to subclass
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
      
      if ([self.buttonImageTitles[index] isEqualToString: @"Generic-Commencement-Icon.png"]) {
        UILabel *dynamicText = [[UILabel alloc] initWithFrame:CGRectMake(IMAGE_OVERTEXT_HORIZ_OFFSET, self.iconSize.height+IMAGE_OVERTEXT_MARGIN, buttonWidth, OVER_TEXT_HEIGHT)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:[NSDate date]];
        int yearInt = [yearString intValue];
        dynamicText.text = [NSString stringWithFormat:@"%d", yearInt];
        dynamicText.textAlignment = NSTextAlignmentCenter;
        dynamicText.textColor = [UIColor whiteColor];
        dynamicText.layer.shadowColor = [UIColor blackColor].CGColor;
        dynamicText.layer.shadowOffset = CGSizeMake(-2, 2);
        dynamicText.layer.shadowOpacity = 0.6;
        dynamicText.font = [UIFont systemFontOfSize: 20 weight: UIFontWeightBlack];
        dynamicText.layer.shadowRadius = 0.1;
        [button addSubview:dynamicText];
      }
      
      UILabel *underText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconSize.height+IMAGE_TEXT_MARGIN, buttonWidth, UNDER_TEXT_HEIGHT)];
      underText.text = self.buttonUnderTexts[index];
      underText.font = UNDER_TEXT_FONT;
      underText.textAlignment = NSTextAlignmentCenter;
      underText.textColor = [UIColor whiteColor];
      
      // Accessibility:
      button.accessibilityLabel = self.buttonUnderTexts[index];
      
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
  CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
  if (screenHeight <= IPHONE_5_HEIGHT) {
    self.iconSize = CGSizeMake(IPHONE_SMALL_ICON, IPHONE_SMALL_ICON);
  } else if (screenHeight <= IPHONE_6_HEIGHT) {
    self.iconSize = CGSizeMake(IPHONE_MEDIUM_ICON, IPHONE_MEDIUM_ICON);
  } else if (screenHeight <= IPHONE_6PLUS_HEIGHT) {
    self.iconSize = CGSizeMake(IPHONE_LARGE_ICON, IPHONE_LARGE_ICON);
  } else {
    self.iconSize = CGSizeMake(IPAD_ICON, IPAD_ICON);
  }
  self.screenName = @"Main View";
  
  self.buttonUnderTexts = @[@"News", @"Directory", @"Maps", @"Videos", @"Photos",
                            @"Events", @"Transit", [self currentEvent]==YaleEventOrientation ? @"Orientation" : [self currentEvent]==YaleEventCommencement ? @"Commencement" : @"Arts Events", @"Athletics"];
  self.buttonImageTitles = @[@"NewsIcon", @"DirectoryIcon", @"MapsIcon", @"VideosIcon", @"PhotosIcon", @"EventsIcon", @"TransitIcon", [self currentEvent]==YaleEventOrientation ? @"OrientationIcon2019" : self.currentEvent == YaleEventArts ? @"ArtsEventsIcon" : @"Generic-Commencement-Icon.png", @"AthleticsIcon"];

  [self setupNavigationBar];
  [self setupBackgroundImage];
}

- (void)viewWillLayoutSubviews
{
  if (!self.loaded) {
    [self setupButtonViews];
    self.loaded = YES;
    
    
    CGRect frame = self.view.bounds;
    //CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // depending on the type of phone, different things are included in the background photo (whose idea was that?)
    frame.origin.y -= navBarHeight + statusBarHeight;
    frame.size.height += navBarHeight + statusBarHeight;
    /*
    if (screenHeight < IPHONE_5_HEIGHT) {
        frame.size.height += navBarHeight + statusBarHeight;
        frame.origin.y -= navBarHeight + statusBarHeight;
      // for iPhone 4, only the main view is in the image
    } else if (screenHeight <= IPHONE_5_HEIGHT) {
      // for iPhone 5, the main view, the status bar, and the nav bar are all in the image
      frame.size.height += navBarHeight + statusBarHeight;
      frame.origin.y -= navBarHeight + statusBarHeight;
    } else if (screenHeight <= IPHONE_6_HEIGHT) {
      // iPhone 6, status bar and nav bar are in image again
      frame.size.height += navBarHeight + statusBarHeight;
      frame.origin.y -= navBarHeight + statusBarHeight;
    } else if (screenHeight <= IPHONE_6PLUS_HEIGHT) {
      // for iPhone 6+, image contains main view and nav bar (not status bar)
      frame.size.height += navBarHeight;
      frame.origin.y -= navBarHeight;
    } else if (screenHeight) {
#warning IPAD_SIZE_OF_BACKGROUND
      // what is contained in the background image?
      frame.size.height += navBarHeight;
      frame.origin.y -= navBarHeight;
    }
    */
    
    self.backgroundImageView.frame = frame;
  }
  //[[UIApplication sharedApplication].delegate window].rootViewController = self.navigationController;
  [super viewWillLayoutSubviews];
}

//uses the current date to find the icon name for the event, like Orientation or Commencement
- (YaleEvent)currentEvent
{
  //get current month+day/monthlength of date.
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
  int month = (int)[dateComponents month];
  int day = (int)[dateComponents day];
  
  // determines whether one date (in format {month, day}) comes before another
  BOOL(^before)(int*, int*) = ^BOOL(int* first, int* second) {
    return first[0] < second[0] || (first[0] == second[0] && first[1] < second[1]);
  };
  BOOL(^equal)(int*, int*) = ^BOOL(int* first, int* second) {
    return first[0] == second[0] && first[1] == second[1];
  };
  // determines whether one date (in format {month, day}) comes between two others
  BOOL(^between)(int*, int*, int*) = ^BOOL(int* middle, int* start, int* end) {
    if (equal(middle, start) || equal(middle, end)) {
      return YES;
    }
    if (before(end, start)) {
      // event spans the new year
      return before(start, middle) || before(middle, end);
    }
    return before(start, middle) && before(middle, end);
  };
  
  int currentDate[2] = {month, day};
  
  //don't make any assumptions about the dates, like which comes first in the year.
  for (YaleEvent event = 0; event < EVENT_COUNT; event++) {
    int* startEndDates = eventStartEndDates[event];
    if (between(currentDate, startEndDates, startEndDates+2)) {
      return event;
    }
  }
  return YaleEventArts;
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
    detailViewController.albumTitle = @"Instagram Photos";
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
    [self.navigationController pushViewController:[[YPWebViewController alloc] initWithTitle:@"Commencement" initialURL:COMMENCEMENT_URL] animated:YES];
  } else if ([underText isEqualToString:@"Arts Events"]) {
    [self.navigationController pushViewController:[[YPWebViewController alloc] initWithTitle:@"Arts Events" initialURL:ARTS_EVENTS_URL] animated:YES];
  } else if ([underText isEqualToString:@"Transit"]) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPTransitViewController"
                                                         bundle:[NSBundle mainBundle]];
    UINavigationController *transitVC = [storyboard instantiateViewControllerWithIdentifier:@"TransitVC"];
    [self.navigationController pushViewController:transitVC animated:YES];
  } else if ([underText isEqualToString:@"Directory"]) {
    [self.navigationController pushViewController:[[YPDirectoryLinkViewController alloc] init] animated:YES];
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPDirectoryViewController"
                                                         //bundle:[NSBundle mainBundle]];
    //UINavigationController *directoryVC = [storyboard instantiateViewControllerWithIdentifier:@"DirectoryVC"];
    //[self.navigationController pushViewController:directoryVC animated:YES];
  } else if ([underText isEqualToString:@"Maps"]) {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPMapsViewController"
                                                         //bundle:[NSBundle mainBundle]];
    //UINavigationController *mapsVC = [storyboard instantiateViewControllerWithIdentifier:@"MapsVC"];
    //[self.navigationController pushViewController:mapsVC animated:YES];
    [self.navigationController pushViewController:[[YPMapsLinkViewController alloc] init] animated:YES];
  } else if ([underText isEqualToString:@"Events"]) {
    [self.navigationController pushViewController:[[YPEventsCategoriesViewController alloc] init] animated:YES];
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
