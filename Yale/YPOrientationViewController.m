//
//  YPOrientationViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 11/14/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPOrientationViewController.h"
@import WebKit;

@interface YPOrientationViewController ()

@end

@implementation YPOrientationViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Orientation";
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self setUpWebView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)setUpWebView
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://yalecollege.yale.edu/new-students/class-2018"]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];;
  [webView loadRequest:request];
  [self.view addSubview:webView];
}
@end