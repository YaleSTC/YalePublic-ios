//
//  YPInfoViewViewController.h
//  Yale
//
//  Created by Minh Tri Pham on 10/31/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface YPInfoViewViewController : UIViewController<MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *releaseLabel;
@property (strong, nonatomic) IBOutlet UIButton *supportButton;
@property (strong, nonatomic) IBOutlet UIButton *projectInfoButton;

@end
