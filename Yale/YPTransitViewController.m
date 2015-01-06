//
//  YPTransitViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 11/14/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPTransitViewController.h"
#import "YPGlobalHelper.h"
@import WebKit;


@implementation YPTransitViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Transit";
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
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://yale.transloc.com"]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];;
  [webView loadRequest:request];
  [self.view addSubview:webView];
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while (webView.loading)
      ;
    dispatch_async(dispatch_get_main_queue(), ^{
      [YPGlobalHelper hideNotificationView];
    });
  });
}
@end
