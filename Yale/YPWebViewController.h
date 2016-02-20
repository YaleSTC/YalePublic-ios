//
//  YPWebViewController.h
//  Yale
//
//  Created by Lee Danilek on 2/9/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

// TODO: Update to SafariViewController
@interface YPWebViewController : UIViewController <WKNavigationDelegate>

+ (NSString *)loadedTitle; //override this method to provide a loaded title, like ATHLETICS_TITLE, unless title is set externally
- (NSString *)initialURL; //override this method

- (NSURL *)currentURL;

//can create instance directly (not subclass) with this, which stores everything internally.
//Do not call from subclass, because then the loadedTitle and initialURL customizations would be ignored.
- (id)initWithTitle:(NSString *)title initialURL:(NSString *)url;

@end
