//
//  YPDirectoryDetailViewController.h
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@import AddressBookUI;

@interface YPDirectoryDetailViewController : UIViewController<MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
- (void)loadData;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *phoneURL;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
+ (ABUnknownPersonViewController *)unknownPersonVCForData:(NSDictionary *)data;

@end
