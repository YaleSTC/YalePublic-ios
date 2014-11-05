//
//  YPProjectInfoViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/31/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPProjectInfoViewController.h"
@import WebKit;

@interface YPProjectInfoViewController ()

@end

@implementation YPProjectInfoViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Yale OPAC";
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self setUpWebView];
}

- (void)setUpWebView
{
  NSURL *url = [NSURL URLWithString:@"http://communications.yale.edu/mobile"];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];;
  [webView loadRequest:request];
  [self.view addSubview:webView];
}

@end
