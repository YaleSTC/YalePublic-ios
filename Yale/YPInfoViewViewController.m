//
//  YPInfoViewViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/31/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPInfoViewViewController.h"

@interface YPInfoViewViewController ()
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@end

@implementation YPInfoViewViewController

#pragma mark Setup Navigation Bar

- (void)setupNavigationBar
{
  UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
  self.navigationItem.rightBarButtonItem = self.doneButton;
  self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
  [doneButton addTarget:self action:[self.presentingViewController dismissViewControllerAnimated:YES completion:nil] forControlEvents:UItouch]
  self.navigationController.navigationBar.translucent = YES;
  self.title = @"Done";
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
  
//  self.backgroundImageView.image = backgroundImage;
//  self.backgroundImageView.layer.zPosition -= 1;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupNavigationBar];
  [self setupBackgroundImage];
}

- (void)didReceiveMemoryWarning {
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
