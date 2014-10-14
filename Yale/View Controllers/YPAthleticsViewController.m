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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openSafariButton;
@property (strong, nonatomic) NSURL *athleticsURL;

@property (strong, nonatomic) WKWebView *athleticsWebView;

@end

@implementation YPAthleticsViewController

//- (void) setAthleticsURL:(NSURL *)athleticsURL {
//  _athleticsURL = [NSURL URLWithString:ATHLETICS]
//}

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
  self.backButton.enabled = self.athleticsWebView.canGoBack;
  self.forwardButton.enabled = self.athleticsWebView.canGoForward;
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


- (IBAction)touchReload:(UIBarButtonItem *)sender {
  [self.athleticsWebView reload];
}

//- (IBAction)touchOpenSafari:(id)sender {
//  
//}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end