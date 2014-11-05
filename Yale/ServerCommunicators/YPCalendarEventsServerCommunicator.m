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

static NSString * const CalendarBaseURL = @"http://calendar.yale.edu/feeds/feed/opa/rss";
static NSString * const YPCalendarEventsErrorDomain = @"YPCalendarEventsErrorDomain";

@implementation YPCalendarEventsServerCommunicator

+ (void)getEventsFromDay:(NSDate *)day
                 tilNext:(NSUInteger)nDays
                    tags:(NSArray *)tags
         completionBlock:(void(^)(NSArray *))successHandler
            failureBlock:(void(^)(NSError *))failureHandler
{
  NSDateFormatter *yyyyMMdd = [[NSDateFormatter alloc] init];
  [yyyyMMdd setDateFormat:@"yyyy-MM-dd"];
  
  NSString *dateString  = [yyyyMMdd stringFromDate:day];
  NSString *nDaysString = [NSString stringWithFormat:@"%lddays", nDays];
  NSString *tagsString  = @"";
  
  for (id tag in tags) {
    NSAssert([tag isKindOfClass:[NSString class]], @"Tag is not an NSString!");
    tagsString =
        (tagsString.length == 0)
            ? tag
            : [NSString stringWithFormat:@"%@,%@", tagsString, (NSString *)tag];
  }
  
  NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/tag=%@",
                         CalendarBaseURL, dateString, nDaysString, tagsString];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFXMLParserResponseSerializer new];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/rss+xml", nil];
  
  [manager GET:urlString
    parameters:nil
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
         XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
         NSDictionary *dict = [parser dictionaryWithParser:responseObject];
         id events = dict[@"channel"][@"item"];
         if ([events isKindOfClass:[NSArray class]]) {
           if (successHandler) successHandler(events);
         } else if ([events isKindOfClass:[NSDictionary class]]) {
           if (successHandler) successHandler(@[events]);
         } else {
           NSDictionary *userInfo = @{
                                      NSLocalizedDescriptionKey: @"Unexpected data format!",
                                      NSLocalizedFailureReasonErrorKey: @"Events are expected to be at dict[@\"channel\"][@\"item\"].",
                                      NSLocalizedRecoverySuggestionErrorKey: @"Contact the person in charge of Yale Calendar API."};
           NSError *error = [NSError errorWithDomain:YPCalendarEventsErrorDomain
                                                code:-1
                                            userInfo:userInfo];
           failureHandler(error);
         }
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failureHandler) failureHandler(error);
       }];
}

@end
