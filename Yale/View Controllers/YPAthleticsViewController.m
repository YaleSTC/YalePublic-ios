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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openSafari;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;


@property (strong, nonatomic) WKWebView *athleticsWebView;

@end

@implementation YPAthleticsViewController

- (NSURL*)athleticsURL
{
  NSString *url= ATHLETICS_URL;
  return [NSURL URLWithString:url];
}

- (void)addAthleticsWebview
{
  self.athleticsWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
  
  NSString *url= ATHLETICS_URL;
  NSURL *nsurl = [NSURL URLWithString:url];
  NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
  [self.athleticsWebView loadRequest:req];
  self.athleticsWebView.allowsBackForwardNavigationGestures = YES;
  [self.view addSubview:self.athleticsWebView];
  self.athleticsWebView.navigationDelegate = self;
  
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while (self.athleticsWebView.loading)
      ;
    dispatch_async(dispatch_get_main_queue(), ^{
      [YPGlobalHelper hideNotificationView];
    });
  });
}


- (void)viewDidLoad
{
  self.title = ATHLETICS_TITLE;
  [super viewDidLoad];
  [self addAthleticsWebview];
}

-(void) updateButtons
{
  self.back.enabled = self.athleticsWebView.canGoBack;
  self.forward.enabled = self.athleticsWebView.canGoForward;
  if (self.athleticsWebView.loading) {
    [self showStopButton];
  }
  else {
    [self showRefreshButton];
  }
}

-(void) showStopButton
{
  NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:[self.toolbar items]];
  toolBarItems[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(refresh)];
  [self.toolbar setItems:toolBarItems animated:NO];
}

-(void) showRefreshButton
{
  NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:[self.toolbar items]];
  toolBarItems[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(touchRefresh:)];
  [self.toolbar setItems:toolBarItems animated:NO];
}



- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation
{
  [self updateButtons];
}

-(void) webView:(WKWebView *)webView
didStartProvisionalNavigation: (WKNavigation *)navigation
{
  [self updateButtons];
}

-(void) webView:(WKWebView *)webView
didFinishNavigation: (WKNavigation *)navigation
{
  [self updateButtons];
  self.title = ATHLETICS_TITLE;
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)touchBack:(UIBarButtonItem *)sender
{
  [self.athleticsWebView goBack];
}


- (IBAction)touchForward:(UIBarButtonItem *)sender
{
  [self.athleticsWebView goForward];
}


- (IBAction)touchRefresh:(id)sender
{
  if (self.athleticsWebView.loading) {
    [self.athleticsWebView stopLoading];
    [self showRefreshButton];
  }
  else{
    [self.athleticsWebView reload];
    [self showStopButton];
  }
}

- (IBAction)openSafari:(UIBarButtonItem *)sender
{
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