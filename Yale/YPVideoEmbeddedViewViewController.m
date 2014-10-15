//
//  YPVideoEmbeddedViewViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPVideoEmbeddedViewViewController.h"
@import WebKit;

@interface YPVideoEmbeddedViewViewController ()

@end

@implementation YPVideoEmbeddedViewViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self setUpWebView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)setUpWebView
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoId]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];;
  [webView loadRequest:request];
  [self.view addSubview:webView];
}
@end
