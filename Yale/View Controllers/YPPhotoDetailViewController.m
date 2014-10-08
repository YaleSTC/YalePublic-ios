//
//  YPPhotoDetailViewController.m
//  Yale
//
//  Created by Charly Walther on 10/5/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPPhotoDetailViewController.h"
#import "YPFlickrCommunicator.h"


@interface YPPhotoDetailViewController () {
  NSDictionary *_photoSet;
}

@end

@implementation YPPhotoDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"set album title");
  self.navigationItem.title = self.albumTitle;
  [self loadPhotos];
}

-(void)loadPhotos {
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [flickr getPhotosForSet:self.photoSetId completionBlock:^(NSDictionary *response) {
    
    _photoSet = response;
    dispatch_async(dispatch_get_main_queue(), ^{
      //Reload CollectionView here
      NSLog(@"%@", _photoSet);
    });
  }
   ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
