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

@interface YPAthleticsViewController ()
//@property (strong, nonatomic) WKWebView *athleticsWebView;
@end

@implementation YPAthleticsViewController

- (void)addAthleticsWebview {
  WKWebView *athleticsWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
  NSString *url= ATHLETICS_URL;
  NSURL *nsurl = [NSURL URLWithString:url];
  NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
  [athleticsWebView loadRequest:req];
  athleticsWebView.allowsBackForwardNavigationGestures = YES;
  [self.view addSubview:athleticsWebView];
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  [self addAthleticsWebview];
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