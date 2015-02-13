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

@property (atomic) BOOL lastPageLoaded;

//call getPhotos: multiple times on the same instance to get successive pages of photos.
//calling getPhotos: again before the completing block is handled will have no effect. (But it could actually be called from within completion block if necessary)
-(void)getPhotos:(void (^)(NSDictionary *))completionBlock;

-(void)downloadImageForURL:(NSURL *)url completionBlock:(void (^)(UIImage *))completionBlock;

@end
