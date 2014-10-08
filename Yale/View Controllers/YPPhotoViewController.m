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

@interface YPPhotoViewController () {
  NSArray *_photoSets;
}
@end


@implementation YPPhotoViewController

-(void)viewDidLoad
{
  self.navigationItem.title = NAVIGATION_BAR_TITLE_PHOTOS;
  [self displaySets];
}

-(void)displaySets
{
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [flickr getSets:^(NSDictionary *response) {
    //NSLog(@"%@", response);
    
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

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"PhotoSetDetail" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _photoSets.count;
}

#pragma segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"PhotoSetDetail"])
  {
    YPPhotoDetailViewController *detailViewController = segue.destinationViewController;
    NSIndexPath *indexPath = [self.photoSetTableView indexPathForSelectedRow];
    
    // Have to provide album title and photoSetId
    detailViewController.albumTitle = _photoSets[indexPath.row][@"title"][@"_content"];
    detailViewController.photoSetId = _photoSets[indexPath.row][@"id"];
  }
}


@end
