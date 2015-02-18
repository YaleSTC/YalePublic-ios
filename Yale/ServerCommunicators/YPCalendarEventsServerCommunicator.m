//
//  YPCalendarEventsServerCommunicator.m
//  Yale
//
//  Created by Hengchu Zhang on 11/4/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPCalendarEventsServerCommunicator.h"
#import <AFNetworking/AFNetworking.h>
#import <XMLDictionary/XMLDictionary.h>

static NSString * const CalendarBaseURL = @"http://calendar.yale.edu/feeds/feed/opa/json";
static NSString * const YPCalendarEventsErrorDomain = @"YPCalendarEventsErrorDomain";

@implementation YPCalendarEventsServerCommunicator

+ (void)getEventsFromDay:(NSDate *)day
                 tilNext:(NSUInteger)nDays
                viewName:(NSString *)viewName
                    tags:(NSArray *)tags
         completionBlock:(void(^)(NSArray *))successHandler
            failureBlock:(void(^)(NSError *))failureHandler
{
  NSDateFormatter *yyyyMMdd = [[NSDateFormatter alloc] init];
  [yyyyMMdd setDateFormat:@"yyyy-MM-dd"];
  
  NSString *dateString  = [yyyyMMdd stringFromDate:day];
  NSString *nDaysString = [NSString stringWithFormat:@"%ddays", (int)nDays];
  NSString *urlString;
  if (viewName) {
    urlString = [NSString stringWithFormat:@"%@/%@/%@/viewName=%@",
                 CalendarBaseURL, dateString, nDaysString, viewName];
  } else {
    urlString = [NSString stringWithFormat:@"%@/%@/%@/tag=%@",
                 CalendarBaseURL, dateString, nDaysString, [tags componentsJoinedByString:@","]];
  }
  NSLog(@"%@", urlString);
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFXMLParserResponseSerializer new];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/javascript", nil];
  
  [manager GET:urlString
    parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *responseString = [[operation responseString] substringFromIndex:23];
         NSError  *jsonError;
         id events = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:NSJSONReadingMutableContainers
                                                       error:&jsonError];
         if (jsonError) {
           failureHandler(jsonError);
         } else {
           successHandler(events[@"bwEventList"][@"events"]);
         }
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failureHandler) failureHandler(error);
       }];
}

@end
