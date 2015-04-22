//
//  JSONLoader.m
//  Yale
//
//  Created by Lee Danilek on 4/21/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "JSONLoader.h"

@interface JSONLoader ()

@property (strong) NSString *name;
@property (strong, nonatomic) NSData *results;
@property (strong, nonatomic) NSDictionary *dict;
@property (weak) id <JSONLoaderDelegate> delegate;

@end

@implementation JSONLoader


@synthesize results = _results;
- (void)setResults:(NSData *)results
{
  if (!results) return;
  _results = results;
  NSError *error = nil;
  self.dict = [NSJSONSerialization JSONObjectWithData:results options:NSJSONReadingMutableContainers error:&error];
}

@synthesize dict=_dict;
- (void)setDict:(NSDictionary *)dict
{
  _dict = dict;
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self.delegate jsonLoaderNamed:self.name updatedPlist:dict];
  }];
}

- (id)initWithName:(NSString *)name defaultName:(NSString *)projectName url:(NSString *)url delegate:(id<JSONLoaderDelegate>)delegate
{
  if (!(self=[super init])) return nil;
  self.delegate = delegate;
  self.name = name;
  NSString *resultsUpdateKey = [NSString stringWithFormat:@"key for expiration date of %@", name];
  NSString *localFileName = [NSString stringWithFormat:@"Cached_%@.plist", projectName];
  
  // asynchronously try to update or access the cache.
  [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
    
    NSDate *dateToUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:resultsUpdateKey];
    // should reload cache
    NSString *pathToLocalFile = [(NSString *)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:localFileName];
    BOOL lookOnline = !dateToUpdate || [dateToUpdate timeIntervalSinceNow] < 0;
    if (lookOnline) {
      // update cache asynchronously
      
      NSLog(@"Updating cache");
      NSData *internetResults = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
      if (internetResults) {
        self.results = internetResults;
        NSLog(@"Downloading data succeeded");
        // NSLog(@"Online Data found: %@", internetResults);
        
        // store cache file asynchronously
        if ([internetResults writeToFile:pathToLocalFile atomically:YES]) {
          NSTimeInterval interval = 60*60*24; // one day
          NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval]; // update every day
          [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:resultsUpdateKey];
          [[NSUserDefaults standardUserDefaults] synchronize];
          NSLog(@"Update cache succeeded. Cache expires %@", expirationDate);
        } else {
          NSLog(@"Storing cached file failed");
        }
      } else {
        lookOnline = NO;
        // might not be able to access internet
        NSLog(@"Accessing internet file failed.");
      }
    }
    if (!lookOnline) {
      // load from the cache
      NSLog(@"Accessing local cache");
      NSData *localResults = [NSData dataWithContentsOfFile:pathToLocalFile];
      if (localResults) {
        self.results = localResults;
        // NSLog(@"Cache Data found: %@", localResults);
        NSLog(@"Cache data found. Cache expires: %@", dateToUpdate);
      }
    }
  }];
  
  // this is guarenteed to succeed (loading the project file), but there could be a better version online or in cache
  // this method should be as fast as possible, even the first time. don't want to load synchronously twice, so load a worse file that must exist first. then, try to load the better file from the cache.
  NSLog(@"Using project data");
  NSData *projectResults = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:projectName ofType:@"json"]];
  if (!self.results) {
    // if somehow the cache has loaded faster, don't reload from project
    self.results = projectResults;
    NSLog(@"Project data found");
    // NSLog(@"Project data: %@", projectResults);
  }
  return self;
}

- (NSDictionary *)json {
  return self.dict;
}


@end
