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

@implementation YPInstagramCommunicator

-(void)getPhotos:(void (^)(NSDictionary *))completionBlock
{
  NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", INSTAGRAM_YALE_USERID, INSTAGRAM_CLIENT_ID];
  
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

    NSData *responseData = operation.responseData;
    NSError *error = nil;
    NSDictionary *photosObject = [NSJSONSerialization
                                       JSONObjectWithData:responseData
                                       options:NSJSONReadingMutableContainers
                                       error:&error];
      
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
