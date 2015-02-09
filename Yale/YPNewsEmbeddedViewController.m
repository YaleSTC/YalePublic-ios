//
//  YPNewsEmbeddedViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPNewsEmbeddedViewController.h"
#import "YPGlobalHelper.h"
@import WebKit;

@interface YPNewsEmbeddedViewController ()

@end

@implementation YPNewsEmbeddedViewController

- (NSString *)initialURL
{
  return self.url;
}

- (void)viewDidLoad
{
  [self setUpTitle];
  [super viewDidLoad];
}

- (void) setUpTitle
{
  UILabel *navLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.frame];
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.font = [UIFont boldSystemFontOfSize:17.0];
  navLabel.textAlignment = NSTextAlignmentCenter;
  navLabel.text = self.title;
  navLabel.numberOfLines = 1;
  navLabel.clipsToBounds = YES;
  [self.navigationItem.titleView addSubview:navLabel];
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
