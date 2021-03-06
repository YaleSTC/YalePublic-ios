//
//  YPWebViewController.m
//  Yale
//
//  Created by Lee Danilek on 2/9/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPWebViewController.h"
#import "Config.h"
#import "YPGlobalHelper.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface YPWebViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openSafari;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) WKWebView *webView;

//set only in initializer.
@property (strong) NSString *startTitle;
@property (strong) NSString *startURL;

@property BOOL loaded;

@end

@implementation YPWebViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  NSString *screenName = [NSString stringWithFormat:@"%@ with title: %@", NSStringFromClass([self class]), self.title];
  [tracker set:kGAIScreenName
         value:screenName];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (NSString *)loadedTitle
{
  NSLog(@"loadedTitle Should be overriden in subclass");
  return nil;
}
- (NSString *)initialURL
{
  NSLog(@"initialURL Should be overriden in subclass");
  return nil;
}

- (NSURL *)currentURL
{
  return self.webView.URL;
}

- (void)viewDidLoad
{
  if (!self.title.length) self.title = self.startTitle ? self.startTitle : [self.class loadedTitle];
  self.view.backgroundColor=[UIColor whiteColor]; //default is clear, which makes loading any part of the view after pushing a problem
  [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  // make sure the status bar stays white (it might go black if presenting a mail view controller).
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
}

- (void)viewWillLayoutSubviews
{
  if (!self.loaded) { //this shouldn't be called more than once, but it might be if a mail editor is loaded and then dismissed.
    [self addWebview]; //this can't go in viewDidLoad because then the bounds are messed up and the toolbar isn't visible.
    self.loaded = YES;
  }
}


-(void) updateButtons
{
  self.back.enabled = self.webView.canGoBack;
  self.forward.enabled = self.webView.canGoForward;
  if (self.webView.loading) {
    [self showStopButton];
  }
  else {
    [self showRefreshButton];
  }
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
  //could set title to webView.title, but for videos that's just YouTube, which is not specific. this way, only the initial video's title is displayed, which in some cases may look odd.
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
  NSLog(@"Error loading webview: %@", error.description);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
  //this gets called when user clicks on a link to the itunes store
  NSLog(@"Error loading webview (provisional):%@", error.description);
}

//code adapted from http://stackoverflow.com/questions/26501172/launching-phone-email-map-links-in-wkwebview?rq=1
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
  if(webView != self.webView) {
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  }
  
  UIApplication *app = [UIApplication sharedApplication];
  NSURL         *url = navigationAction.request.URL;
  
  // if not successful load, or if app link, or if email or phone number, use the phone's default response (open in app store, mail, or phone apps). If this link has target="_blank", this will open it in Safari.
  if (!navigationAction.targetFrame || [url.host isEqualToString:@"itunes.apple.com"] || [url.scheme isEqualToString:@"tel"] || [url.scheme isEqualToString:@"mailto"]) {
    if ([app canOpenURL:url]) {
      [app openURL:url];
      decisionHandler(WKNavigationActionPolicyCancel);
      return;
    }
  }
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (IBAction)openSafari:(UIBarButtonItem *)sender
{
  [[UIApplication sharedApplication] openURL:self.currentURL];
}

- (IBAction)touchBack:(UIBarButtonItem *)sender
{
  [self.webView goBack];
}

- (IBAction)touchForward:(UIBarButtonItem *)sender
{
  [self.webView goForward];
}

-(void) showStopButton
{
  NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:[self.toolbar items]];
  toolBarItems[4] = self.stopButton;
  [self.toolbar setItems:toolBarItems animated:NO];
}

-(void) showRefreshButton
{
  NSMutableArray *toolBarItems = [NSMutableArray arrayWithArray:[self.toolbar items]];
  toolBarItems[4] = self.refresh;
  [self.toolbar setItems:toolBarItems animated:NO];
}

- (IBAction)touchRefresh:(id)sender
{
  if (self.webView.loading) {
    [self.webView stopLoading];
    [self showRefreshButton];
  }
  else{
    [self.webView reload];
    [self showStopButton];
  }
}

- (void)addWebview
{
  if (!self.toolbar) {
    //for the transit and others, there is no toolbar in the storyboard, and there shouldn't be unless it's possible to create a single storyboard for YPWebViewController
    //according to the storyboard, toolbars must have height 44
    CGFloat toolbarHeight = 44;
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
    
    //as in the athletics toolbar, do in order:
    //rewind, flex space, fastfwd, flex space, refresh, flex space, action
    self.back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(touchBack:)];
    self.back.enabled = NO;
    self.back.accessibilityLabel = @"Back";
    self.forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(touchForward:)];
    self.forward.enabled = NO;
    self.forward.accessibilityLabel = @"Forward";
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(touchRefresh:)];
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(touchRefresh:)];
    self.openSafari = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openSafari:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = @[self.back, flexibleSpace, self.forward, flexibleSpace, self.stopButton, flexibleSpace, self.openSafari];
    [self.toolbar setItems:items animated:NO];
    [self.view addSubview:self.toolbar];
  }
  // create a progress bar for webpage loading progress.
  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  //no matter what, the progress view height is always 2 (even if you set it something else)
  self.progressView.frame = CGRectMake(0, self.view.bounds.size.height-self.toolbar.bounds.size.height, self.view.bounds.size.width, 2);
  [self.view addSubview:self.progressView];
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  [self performSelector:@selector(initializeWebView) withObject:nil afterDelay:0];
}

//this is really slow, so don't wait to do it.
- (void)initializeWebView
{
  //now set up webview. allocating the webview takes awhile and freezes the navigation transition, so attempt to allocate in another thread
  CGRect webViewFrame = self.view.bounds;
  webViewFrame.size.height-=self.toolbar.bounds.size.height;
  
  NSString *url= self.startURL ? self.startURL : [self initialURL];
  NSURL *nsurl = [NSURL URLWithString:url];
  NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
  
  self.webView = [[WKWebView alloc] initWithFrame:webViewFrame];
  
  //followed KVO tutorial at http://nshipster.com/key-value-observing/
  [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:NULL];
  
  [self.webView loadRequest:req];
  self.webView.allowsBackForwardNavigationGestures = YES;
  [self.view insertSubview:self.webView atIndex:0]; //behind the "loading..." icon
  self.webView.navigationDelegate = self;
  
  
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while (self.webView.loading)
      ;
    dispatch_async(dispatch_get_main_queue(), ^{
      [YPGlobalHelper hideNotificationView];
    });
  });
}

// callback for when WebView progress changes.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (object==self.webView && [keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
    self.progressView.progress = self.webView.estimatedProgress;
    self.progressView.hidden = self.progressView.progress > 0.99;
  }
}

- (id)initWithTitle:(NSString *)title initialURL:(NSString *)url
{
  if (self=[super init]) {
    self.startTitle = title;
    self.startURL = url;
  }
  return self;
}

- (void)dealloc
{
  // view is going away. if you don't remove observers this will crash.
  [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

@end
