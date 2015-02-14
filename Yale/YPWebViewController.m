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

@interface YPWebViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openSafari;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) WKWebView *webView;

//set only in initializer.
@property (strong) NSString *startTitle;
@property (strong) NSString *startURL;

@end

@implementation YPWebViewController

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
  [self addWebview];

  [super viewDidLoad];
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
  toolBarItems[4] = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(touchRefresh:)];
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
    //for the transit and others (not including Athletics), there is no toolbar in the storyboard, and there shouldn't be unless it's possible to create a single storyboard for YPWebViewController
    //according to the storyboard, toolbars must have height 44
    CGFloat toolbarHeight = 44;
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
    
    //as in the athletics toolbar, do in order:
    //rewind, flex space, fastfwd, flex space, refresh, flex space, action
    self.back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(touchBack:)];
    self.forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(touchForward:)];
    self.refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(touchRefresh:)];
    self.openSafari = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openSafari:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = @[self.back, flexibleSpace, self.forward, flexibleSpace, self.refresh, flexibleSpace, self.openSafari];
    [self.toolbar setItems:items animated:NO];
    [self.view addSubview:self.toolbar];
  }
  
  CGRect webViewFrame = self.view.bounds;
  webViewFrame.size.height-=self.toolbar.bounds.size.height/*+self.navigationController.navigationBar.bounds.size.height*/;
  self.webView = [[WKWebView alloc] initWithFrame:webViewFrame];
  
  NSString *url= self.startURL ? self.startURL : [self initialURL];
  NSURL *nsurl = [NSURL URLWithString:url];
  NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
  [self.webView loadRequest:req];
  self.webView.allowsBackForwardNavigationGestures = YES;
  [self.view addSubview:self.webView];
  self.webView.navigationDelegate = self;
  
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    while (self.webView.loading)
      ;
    dispatch_async(dispatch_get_main_queue(), ^{
      [YPGlobalHelper hideNotificationView];
    });
  });
}

- (id)initWithTitle:(NSString *)title initialURL:(NSString *)url
{
  if (self=[super init]) {
    self.startTitle = title;
    self.startURL = url;
  }
  return self;
}

@end
