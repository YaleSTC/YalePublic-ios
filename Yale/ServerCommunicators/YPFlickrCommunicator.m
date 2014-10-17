//
//  YPFlickrCommunicator.m
//  Yale
//
//  Created by Charly Walther on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPFlickrCommunicator.h"
#import <FlickrKit.h>
#import "Config.h"

@interface YPFlickrCommunicator () {

}
@end

@implementation YPFlickrCommunicator

-(instancetype)init
{
  [[FlickrKit sharedFlickrKit] initializeWithAPIKey:FLICKR_API_KEY sharedSecret:FLICKR_SHARED_SECRET];
  return self;
}

-(void)getSets:(void (^)(NSDictionary *))completionBlock
{
  NSLog(@"testetst");
  [[FlickrKit sharedFlickrKit] call:@"flickr.photosets.getList"
                               args:@{@"user_id": FLICKR_YALE_NSID}
                        maxCacheAge:FKDUMaxAgeOneHour
                         completion:^(NSDictionary *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (response) {
        //success handler
        NSLog(@"success handler");
        completionBlock(response);
      } else {
        // error handler
        NSLog(@"%@", error);

       #warning error handler needed
      }
    });
  }];
}

-(void)getPhotosForSet:(NSString *)photoSetId completionBlock:(void (^)(NSDictionary *))completionBlock
{
  [[FlickrKit sharedFlickrKit] call:@"flickr.photosets.getPhotos"
                               args:@{@"photoset_id": photoSetId}
                        maxCacheAge:FKDUMaxAgeOneHour
                         completion:^(NSDictionary *response, NSError *error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                             if (response) {
                               //success handler
                               completionBlock(response);
                             } else {
                               // error handler
                              #warning error handler needed
                             }
                           });
                         }];
}

-(NSURL *)urlForImageFromDictionary:(NSDictionary *)photoDictionary
{
  return [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoDictionary];
}

-(void)downloadImageForURL:(NSURL *)url completionBlock:(void (^)(UIImage *))completionBlock
{
  //Return UIImage for URL
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
      
      UIImage *image = [[UIImage alloc] initWithData:data];
      completionBlock(image);
      
    }];
}


@end
