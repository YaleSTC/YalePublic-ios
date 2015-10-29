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


//define a little class here to keep track of the progress of loading an image.
typedef void(^Completion)(UIImage*, NSUInteger);
typedef void(^ByteCallback)(NSUInteger);

@interface YPInstagramPhotoDelegate : NSObject <NSURLConnectionDataDelegate>

@property (strong) Completion completionBlock;
@property (strong) ByteCallback loadedBytes;
@property (strong) ByteCallback totalBytes;
- (id)initWithCompletionBlock:(Completion)cblock progressBlocks:(ByteCallback)loadedBytes :(ByteCallback)totalBytes;
@property NSUInteger expectedBytes;
@property (strong, nonatomic) NSMutableData *dataLoading;

@end

@implementation YPInstagramPhotoDelegate

- (id)initWithCompletionBlock:(Completion)cblock progressBlocks:(ByteCallback)loadedBytes :(ByteCallback)totalBytes
{
  if (self=[super init]) {
    self.completionBlock = cblock;
    self.loadedBytes = loadedBytes;
    self.totalBytes = totalBytes;
  }
  return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.dataLoading appendData:data];
  if (self.loadedBytes) self.loadedBytes(data.length);
  if (self.dataLoading.length >= self.expectedBytes) {
    UIImage *image = [[UIImage alloc] initWithData:self.dataLoading];
    self.completionBlock(image, self.expectedBytes);
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  self.expectedBytes = (NSUInteger)response.expectedContentLength;
  self.dataLoading = [NSMutableData dataWithCapacity:self.expectedBytes];
  if (self.totalBytes) self.totalBytes(self.expectedBytes);
}

@end

@interface YPInstagramCommunicator ()

@property (atomic) BOOL gettingPhotos;
@property (strong, atomic) NSString *nextPageURL; //atomic so should be thread-safe, so can be called after photos are loaded.

@end

@implementation YPInstagramCommunicator

//this completion block is given an NSDictionary representation of the JSON file given by the Instagram API.
-(void)getPhotos:(void (^)(NSDictionary *))completionBlock progressBlock:(void (^)(double))progressHandler
{
  if (self.gettingPhotos) return; //the request is already being handled, and hasn't yet completed. Loading again will load the same group of photos twice.
  NSString *url = [NSString stringWithFormat:self.nextPageURL ? self.nextPageURL : @"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@", INSTAGRAM_YALE_USERID, INSTAGRAM_CLIENT_ID];
  
  self.gettingPhotos = YES;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *request = [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

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
    [request setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
      double percentDone = 0;
      if (totalBytesExpectedToRead != NSURLResponseUnknownLength) {
        percentDone = (double)totalBytesRead / (double)totalBytesExpectedToRead;
      } else {
        percentDone = (totalBytesRead % 1000000l) / 1000000.0;//go from 0 to 1 for every megabyte downloaded.
      }
      progressHandler(percentDone);
    }];
  });
  
}

-(void)downloadImageForURL:(NSURL *)url completionBlock:(void (^)(UIImage *, NSUInteger))completionBlock progressBlocks:(void (^)(NSUInteger))bytesLoaded :(void (^)(NSUInteger))bytesTotal
{
  //Return UIImage for URL
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [NSURLConnection connectionWithRequest:request delegate:[[YPInstagramPhotoDelegate alloc] initWithCompletionBlock:completionBlock progressBlocks:bytesLoaded :bytesTotal]];
}


@end
