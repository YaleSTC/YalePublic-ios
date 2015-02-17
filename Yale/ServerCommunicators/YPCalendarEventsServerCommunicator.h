//
//  YPCalendarEventsServerCommunicator.h
//  Yale
//
//  Created by Hengchu Zhang on 11/4/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPCalendarEventsServerCommunicator : NSObject

//either viewName or tags should be nil.
+ (void)getEventsFromDay:(NSDate *)day
                 tilNext:(NSUInteger)nDays
                viewName:(NSString *)viewName
                    tags:(NSArray *)tags
         completionBlock:(void(^)(NSArray *events))successHandler
            failureBlock:(void(^)(NSError *error))failureHandler;

@end
