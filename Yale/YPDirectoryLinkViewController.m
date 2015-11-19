//
//  YPDirectoryLinkViewController.m
//  Yale
//
//  Created by Lee Danilek on 11/19/15.
//  Copyright © 2015 Hengchu Zhang. All rights reserved.
//

#import "YPDirectoryLinkViewController.h"

@interface YPDirectoryLinkViewController ()

@end

@implementation YPDirectoryLinkViewController

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

+ (NSString *)loadedTitle
{
    return @"Directory";
}

- (NSString *)initialURL
{
    return @"http://directory.yale.edu";
}

@end
