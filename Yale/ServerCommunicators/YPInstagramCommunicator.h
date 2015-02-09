//
//  YPInstagramCommunicator.h
//  Yale
//
//  Created by Charly Walther on 1/31/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YPInstagramCommunicator : NSObject

-(void)getPhotos:(void (^)(NSDictionary *))completionBlock;
-(void)downloadImageForURL:(NSURL *)url completionBlock:(void (^)(UIImage *))completionBlock;

@end
