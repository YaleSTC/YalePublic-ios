//
//  YPNewsEmbeddedViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPNewsEmbeddedViewController.h"
@import WebKit;

@interface YPNewsEmbeddedViewController ()

@end

@implementation YPNewsEmbeddedViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setUpWebView];
  [self setUpTitle];
}

- (void) setUpTitle
{
  UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 20)];
  navLabel.backgroundColor = [UIColor clearColor];
  navLabel.textColor = [UIColor whiteColor];
  navLabel.font = [UIFont boldSystemFontOfSize:17.0];
  navLabel.textAlignment = NSTextAlignmentCenter;
  navLabel.text = self.title;
  navLabel.numberOfLines = 1;
  navLabel.clipsToBounds = YES;
  [self.navigationItem.titleView addSubview:navLabel];
  NSLog(@"%@", self.title);
}

#pragma mark Set Up Web View

- (void)setUpWebView
{
  NSURL *url = [NSURL URLWithString:self.url];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];;
  [webView loadRequest:request];
  [self.view addSubview:webView];
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
