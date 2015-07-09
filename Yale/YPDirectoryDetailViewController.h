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

@interface YPDirectoryDetailViewController : UIViewController

+ (ABUnknownPersonViewController *)unknownPersonVCForData:(NSDictionary *)data;

@end
