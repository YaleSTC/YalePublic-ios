//
//  YPFlickrCommunicator.h
//  Yale
//
//  Created by Charly Walther on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface YPFlickrCommunicator : UIView

-(NSURL *)urlForImageFromDictionary:(NSDictionary *)photoDictionary;
-(void)downloadImageForURL:(NSURL *)url completionBlock:(void (^)(UIImage *))completionBlock;
-(void)getSets:(void (^)(NSDictionary *))completionBlock;
-(void)getPhotosForSet:(NSString *)photoSetId completionBlock:(void (^)(NSDictionary *))completionBlock;



@end
