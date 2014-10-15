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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openSafari;

@property (strong, nonatomic) WKWebView *athleticsWebView;

@end

@implementation YPAthleticsViewController

- (NSURL*)athleticsURL {
  NSString *url= ATHLETICS_URL;
  return [NSURL URLWithString:url];
}

- (void)addAthleticsWebview {
  self.athleticsWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
  
  NSString *url= ATHLETICS_URL;
  NSURL *nsurl = [NSURL URLWithString:url];
  NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
  [self.athleticsWebView loadRequest:req];
  self.athleticsWebView.allowsBackForwardNavigationGestures = YES;
  [self.view addSubview:self.athleticsWebView];
  self.athleticsWebView.navigationDelegate = self;
  
}


- (void)viewDidLoad {
  
  [super viewDidLoad];
  [self addAthleticsWebview];
}

-(void) updateButtons{
  self.back.enabled = self.athleticsWebView.canGoBack;
  self.forward.enabled = self.athleticsWebView.canGoForward;
  if (self.athleticsWebView.loading) {
    
  }
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation
{
  [self updateButtons];
}

-(void) webView:(WKWebView *)webView
didStartProvisionalNavigation: (WKNavigation *)navigation {
  [self updateButtons];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)touchBack:(UIBarButtonItem *)sender {
  [self.athleticsWebView goBack];
}


- (IBAction)touchForward:(UIBarButtonItem *)sender {
  [self.athleticsWebView goForward];
}


- (IBAction)touchRefresh:(id)sender {
  [self.athleticsWebView reload];
}

- (IBAction)openSafari:(UIBarButtonItem *)sender {
   [[UIApplication sharedApplication] openURL:self.athleticsURL];
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