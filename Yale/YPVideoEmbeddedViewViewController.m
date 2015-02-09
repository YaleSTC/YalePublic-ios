//
//  YPVideoEmbeddedViewViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPVideoEmbeddedViewViewController.h"
#import "YPGlobalHelper.h"
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
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSString *)initialURL
{
  return [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoId];
}
@end
