//
//  YPWebViewController.h
//  Yale
//
//  Created by Lee Danilek on 2/9/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface YPWebViewController : UIViewController <WKNavigationDelegate>

+ (NSString *)loadedTitle; //override this method to provide a loaded title, like ATHLETICS_TITLE
+ (NSString *)initialURL; //override this method

- (NSURL *)currentURL;

@end
