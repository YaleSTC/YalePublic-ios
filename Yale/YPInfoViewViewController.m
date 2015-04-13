//
//  YPInfoViewViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/31/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPInfoViewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "YPTheme.h"

@interface YPInfoViewViewController () <UITextViewDelegate>
@property UITextView *textView;
@property BOOL loaded;
@end

@implementation YPInfoViewViewController

#pragma mark Setup VC

- (void)setupNavigationBar
{
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  navigationBar.barStyle = UIBarStyleBlack;
  [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                    forBarPosition:UIBarPositionAny
                                        barMetrics:UIBarMetricsDefault];
  
  [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
  self.title = @"About";
}

- (void)setShadow:(UIView *)view
{
  view.layer.masksToBounds = NO;
  view.layer.shadowColor = [UIColor blackColor].CGColor;
  view.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
  view.layer.shadowOpacity = 1.0f;
  view.layer.shadowRadius = 5.0f;
  
  view.layer.cornerRadius = 8.0f;
}

#define SIDE_MARGIN 20
#define TOP_MARGIN 25
#define BELOW_IMAGE_MARGIN 15

- (void)setupVC
{
  self.view.backgroundColor = [UIColor whiteColor];
  /*
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_background"]];
   */
  UIImage *logo = [UIImage imageNamed:@"infopage-logo"];
  UIImageView *imgView = [[UIImageView alloc] initWithImage:logo];
  [imgView.layer setMasksToBounds:YES];
  CGFloat imageHeight = imgView.bounds.size.height;
  
  imgView.clipsToBounds = YES;
  imgView.center = CGPointMake(self.view.bounds.size.width/2, TOP_MARGIN+imageHeight/2);
  [self.view addSubview:imgView];
  
  CGFloat textViewY = TOP_MARGIN+imageHeight+BELOW_IMAGE_MARGIN;
  UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(SIDE_MARGIN, textViewY, self.view.bounds.size.width-2*SIDE_MARGIN, self.view.bounds.size.height-textViewY)];
  [self.view addSubview:textView];
  [textView setAttributedText:self.projectInfo];
  textView.delegate = self;
  textView.allowsEditingTextAttributes = NO;
  textView.editable = NO;
  self.textView = textView;
}

- (NSAttributedString *)projectInfo {
  UIFont *textFont = [UIFont systemFontOfSize:14 weight:0];
  UIFont *headerFont = [UIFont systemFontOfSize:16 weight:0];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.paragraphSpacing = 0.5*textFont.lineHeight;
  paragraphStyle.paragraphSpacingBefore = 0.5*textFont.lineHeight;
  NSMutableParagraphStyle *headerParagraphStyle = [[NSMutableParagraphStyle alloc] init];
  headerParagraphStyle.paragraphSpacingBefore = headerFont.lineHeight;
  NSDictionary *headerAttributes = @{NSForegroundColorAttributeName: [YPTheme textColor], NSFontAttributeName: headerFont, NSParagraphStyleAttributeName: headerParagraphStyle};
  NSDictionary *textAttributes = @{NSForegroundColorAttributeName: [YPTheme textColor], NSFontAttributeName: textFont, NSParagraphStyleAttributeName: paragraphStyle};
  NSMutableAttributedString *info = [[NSMutableAttributedString alloc] initWithString:@"Feedback and Suggestions\n" attributes:headerAttributes];
  [info appendAttributedString:[[NSAttributedString alloc] initWithString:@"We welcome your feedback. " attributes:textAttributes]];
  NSMutableAttributedString *link = [[NSMutableAttributedString alloc] initWithString:@"Tap here to send feedback." attributes:textAttributes];
  [link addAttribute:NSLinkAttributeName value:@"http://link.com" range:NSMakeRange(0, link.length)]; // this triggers the delegate method
  [info appendAttributedString:link];
  [info appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nAbout this App" attributes:headerAttributes]];
  [info appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nVersion 1.0 of Yale was created by the Student Developer and Mentorship Program at Yale in conjunction with Office of Public Affairs and Communications and Yale ITS." attributes:textAttributes]];
  [info appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nMembers of the team include Minh Tri Pham, Hengchu Zhang, Charly Walther, Lee Danilek, Taishi Nojima, Hannia Zia, and Jenny Allen" attributes:textAttributes]];
  [info appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nWe would like to thank everyone who supported us making this application." attributes:textAttributes]];
  return [info copy];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
  [self sendMail];
  return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.textView flashScrollIndicators];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
}

#pragma mark Mail

- (void)sendMail
{
  if([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
    mailCont.mailComposeDelegate = self;
    
    [mailCont setSubject:@"Feedback"];
    [mailCont setToRecipients:[NSArray arrayWithObject:@"yalepublic@gmail.com"]];
    [mailCont setMessageBody:@"" isHTML:NO];
    [self.navigationController presentViewController:mailCont animated:YES completion:^{
      //without these lines the status bar shows up black, for some reason.
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
      [self setNeedsStatusBarAppearanceUpdate];
    }];
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  if (!self.loaded) {
    [self setupVC];
    self.loaded = YES;
  }
  [super viewWillAppear:animated];
  //[[UIApplication sharedApplication].delegate window].rootViewController = self.navigationController;
}


// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
