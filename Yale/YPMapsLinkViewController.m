//
//  YPMapsLinkViewController.m
//  Yale
//
//  Created by Lee Danilek on 11/3/15.
//  Copyright © 2015 Hengchu Zhang. All rights reserved.
//

#import "YPMapsLinkViewController.h"

@interface YPMapsLinkViewController ()

@end

@implementation YPMapsLinkViewController

+ (NSString *)loadedTitle
{
  return @"Maps";
}

- (NSString *)initialURL
{
  return @"http://map.yale.edu";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
