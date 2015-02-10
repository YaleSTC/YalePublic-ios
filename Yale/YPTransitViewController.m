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

- (NSString *)initialURL
{
  return @"http://yale.transloc.com";
}

+ (NSString *)loadedTitle
{
  return @"Transit";
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
