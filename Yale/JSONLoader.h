//
//  JSONLoader.h
//  Yale
//
//  Created by Lee Danilek on 4/21/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONLoaderDelegate <NSObject>

// will get called on main thread
- (void)jsonLoaderNamed:(NSString *)name updatedPlist:(NSDictionary *)plist;

@end

// this class is for loading a JSON file. First a local file is loaded. Then, if a cache exists and hasn't expired, the cached JSON file is loaded. If the cache has expired, the file is downloaded from the internet and cached.
@interface JSONLoader : NSObject

// name must be unique to the file being loaded (used to store expiration date)
// default name is of form "buildings" where "buildings.json" is the project file name
- (id)initWithName:(NSString *)name defaultName:(NSString *)projectName url:(NSString *)url delegate:(id <JSONLoaderDelegate>)delegate;

- (NSDictionary *)json;

@end
