//
//  YPCalendarEventsServerCommunicator.h
//  Yale
//
//  Created by Hengchu Zhang on 11/4/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPCalendarEventsServerCommunicator : NSObject

+ (void)getEventsFromDay:(NSDate *)day
                 tilNext:(NSUInteger)nDays
                    tags:(NSArray *)tags
         completionBlock:(void(^)(NSArray *events))successHandler
            failureBlock:(void(^)(NSError *error))failureHandler;

@end
