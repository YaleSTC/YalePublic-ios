//
//  YPGlobalHelper.m
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPGlobalHelper.h"
#import "YPAppDelegate.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
@implementation YPGlobalHelper

+ (void)showNotificationInViewController:(UIViewController *)vc
                                 message:(NSString *)msg
                                   style:(JGProgressHUDStyle)style
                               indicator:(JGProgressHUDIndicatorView *)indicator
{
  YPAppDelegate *delegate = [UIApplication sharedApplication].delegate;
  // Hide any showing notification first.
  [self hideNotificationView];
  
  JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:style];
  hud.position = JGProgressHUDPositionCenter;
  hud.textLabel.text = msg;
  if (indicator) {
    hud.indicatorView = indicator;
  }
  [hud showInView:vc.view];
  [delegate setSharedNotificationView:hud];
}

+ (void)showNotificationInViewController:(UIViewController *)vc
                                 message:(NSString *)msg
                                   style:(JGProgressHUDStyle)style
{
  [self showNotificationInViewController:vc message:msg style:style indicator:nil];
}

+ (void)hideNotificationView
{
  YPAppDelegate *delegate = [UIApplication sharedApplication].delegate;
  if ([delegate.sharedNotificationView isVisible]) {
    [delegate.sharedNotificationView dismiss];
  }
  delegate.sharedNotificationView = nil;
}

# pragma mark - YaleMobile 1.x HTML Parsing APIs

+ (NSMutableDictionary *)getInformationForPerson:(NSString *)responseString
{
  NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
  TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
  
  NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
  
  NSArray *headers = [doc searchWithXPathQuery:@"//th"];
  NSArray *details = [doc searchWithXPathQuery:@"//td"];
  for (NSUInteger i = 0; i < headers.count; i++) {
    NSString *header = ((TFHppleElement *)[headers objectAtIndex:i]).content;
    NSString *detail;
    
    if ([header rangeOfString:@"Email Address:"].location != NSNotFound ||
        [header rangeOfString:@"Student Address:"].location != NSNotFound ||
        [header rangeOfString:@"US Mailing Address:"].location != NSNotFound ||
        [header rangeOfString:@"Office Address:"].location != NSNotFound) {
      detail = ((TFHppleElement *)((TFHppleElement *)[details objectAtIndex:i]).firstChild).content;
    } else {
      detail = ((TFHppleElement *)[details objectAtIndex:i]).content;
    }
    
    [dataDict setObject:detail forKey:header];
  }
  
  return dataDict;
}

+ (NSArray *)getPeopleList:(NSString *)responseString
{
  NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
  TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
  NSArray *array = [doc searchWithXPathQuery:@"//ul[@class='indented-list']/li"];
  NSMutableArray *list = [[NSMutableArray alloc] init];
  
  for (NSUInteger i = 0; i < array.count; i++) {
    NSString *name = ((TFHppleElement *)[array objectAtIndex:i]).firstChild.content;
    NSString *link = [@"http://directory.yale.edu/phonebook/" stringByAppendingString:[((TFHppleElement *)[array objectAtIndex:i]).firstChild objectForKey:@"href"]];
    NSString *info = ((TFHppleElement *)[array objectAtIndex:i]).content;
    
    if ([info isEqualToString:@"- ()"]) {
      NSArray *infos = ((TFHppleElement *)[array objectAtIndex:i]).children;
      info = ((TFHppleElement *)[infos objectAtIndex:infos.count-1]).content;
    }
    info = [info stringByReplacingOccurrencesOfString:@"- " withString:@""];
    info = [info stringByReplacingOccurrencesOfString:@"(" withString:@""];
    info = [info stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    NSDictionary *person = [[NSDictionary alloc] initWithObjectsAndKeys:name, @"name", link, @"link", info, @"info", nil];
    [list addObject:person];
  }
  
  return list;
}


@end
