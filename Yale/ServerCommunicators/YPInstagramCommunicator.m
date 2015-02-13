//
//  YPInstagramCommunicator.m
//  Yale
//
//  Created by Charly Walther on 1/31/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPInstagramCommunicator.h"
#import "Config.h"
#import "AFNetworking.h"

@interface YPInstagramCommunicator ()

@property (atomic) BOOL gettingPhotos;
@property (strong, atomic) NSString *nextPageURL; //atomic so should be thread-safe, so can be called after photos are loaded.

@end

@implementation YPInstagramCommunicator

//this completion block is given an NSDictionary representation of the JSON file given by the Instagram API.
-(void)getPhotos:(void (^)(NSDictionary *))completionBlock
{
  if (self.gettingPhotos) return; //the request is already being handled, and hasn't yet completed. Loading again will load the same group of photos twice.
  NSString *url = [NSString stringWithFormat:self.nextPageURL ? self.nextPageURL : @"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", INSTAGRAM_YALE_USERID, INSTAGRAM_CLIENT_ID];
  
  self.gettingPhotos = YES;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

    NSData *responseData = operation.responseData;
    NSError *error = nil;
    NSDictionary *photosObject = [NSJSONSerialization
                                       JSONObjectWithData:responseData
                                       options:NSJSONReadingMutableContainers
                                       error:&error];
      self.nextPageURL = photosObject[@"pagination"][@"next_url"];
      if (!self.nextPageURL) { //not sure if this is the correct case, but hopefully it is.
        self.lastPageLoaded = YES;
      }
      
      self.gettingPhotos = NO;
      completionBlock(photosObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
      NSLog(@"Error: %@", error);
    }];
  });
  
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
