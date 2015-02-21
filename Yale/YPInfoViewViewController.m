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

@interface YPInfoViewViewController ()
@end

@implementation YPInfoViewViewController

#pragma mark Setup VC

- (void)setupNavigationBar
{
  UINavigationBar *navigationBar = self.navigationController.navigationBar;
  navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
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

- (void)setupVC
{
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_background"]]
  ;
  UIImage *logo = [UIImage imageNamed:@"infopage-logo"];
  UIImageView *imgView = [[UIImageView alloc] initWithImage:logo];
  [imgView.layer setMasksToBounds:YES];
  
  imgView.clipsToBounds = YES;
  [self.logoImageView addSubview:imgView];
  self.logoImageView.layer.cornerRadius = 8.0f;
  self.logoImageView.layer.masksToBounds = NO;
  self.logoImageView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
  self.logoImageView.layer.shadowRadius = 5;
  self.logoImageView.layer.shadowOpacity = 0.5;
  self.logoImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.logoImageView.bounds].CGPath;
  
  self.releaseLabel.text = [NSString stringWithFormat:@"release: %@", APP_RELEASE_VERSION];
  
  [self setShadow:self.supportButton];
  
  [self setShadow:self.projectInfoButton];
  
  [self.supportButton addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchUpInside];
}



- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
  [self setupVC];
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
    mailCont.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
  }
}


// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation
- (IBAction)dissmissThisVC:(id)sender
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
