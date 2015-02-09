//
//  YPAthleticsViewController.m
//  
//
//  Created by Jenny Allen on 10/12/14.
//
//

#import "YPAthleticsViewController.h"
@import WebKit;
#import "Config.h"
#import "YPGlobalHelper.h"

@interface YPAthleticsViewController ()

@end

@implementation YPAthleticsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}


+ (NSString *)loadedTitle
{
  return ATHLETICS_TITLE;
}

- (NSString *)initialURL
{
  return ATHLETICS_URL;
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