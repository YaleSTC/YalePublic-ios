//
//  YPPhotoViewController.m
//  Yale
//
//  Created by Charly Walther on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPPhotoViewController.h"
#import "YPFlickrCommunicator.h"
#import "YPStandardCell.h"
#import "YPPhotoDetailViewController.h"
#import "Config.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface YPPhotoViewController () {
  NSArray *_photoSets;
}
@end


@implementation YPPhotoViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = NAVIGATION_BAR_TITLE_PHOTOS;
  [self.photoSetTableView registerNib:[UINib nibWithNibName:@"YPStandardCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PhotoListCell"];
  [self displaySets];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Photo VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)displaySets
{
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [flickr getSets:^(NSDictionary *response) {
    NSLog(@"%@", response);
    
    _photoSets = response[@"photosets"][@"photoset"];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.photoSetTableView reloadData];
    });
  }
  ];
}


#pragma table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  YPStandardCell *cell = [self.photoSetTableView dequeueReusableCellWithIdentifier:@"PhotoListCell" forIndexPath:indexPath];
  
  NSDictionary *set = _photoSets[indexPath.row];
  
  [cell.title setText:set[@"title"][@"_content"]];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPPhotoViewController"
                                                       bundle:[NSBundle mainBundle]];
  YPPhotoDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailVC"];
  
  // Have to provide album title and photoSetId
  detailViewController.albumTitle = _photoSets[indexPath.row][@"title"][@"_content"];
  detailViewController.photoSetId = _photoSets[indexPath.row][@"id"];
  
  [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _photoSets.count;
}




@end
