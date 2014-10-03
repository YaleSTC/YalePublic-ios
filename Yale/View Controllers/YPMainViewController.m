//
//  YPMainViewController.m
//  Yale
//
//  Created by Hengchu Zhang on 10/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPMainViewController.h"
#import "YPMainViewButton.h"
#import <PureLayout/PureLayout.h>

@interface YPMainViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIBarButtonItem *infoButton;

@end

@implementation YPMainViewController

#pragma mark - View Setup

- (void)setupNavigationBar
{
  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
  self.navigationItem.rightBarButtonItem = self.infoButton;
  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
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

#pragma mark - View life cycles

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setupNavigationBar];
  [self setupBackgroundImage];
  
  /* Uncomment this code to see the custom mainViewButton in effect.
  UIImage *buttonImage = [UIImage imageNamed:@"TestButtonImage"];
  YPMainViewButton *button = [YPMainViewButton newAutoLayoutView];
  button.icon = buttonImage;
  button.underText = @"Yale";
  [self.view addSubview:button];
  [button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:100];
  [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:100];
   */
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
