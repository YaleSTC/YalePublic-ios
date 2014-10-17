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
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface YPPhotoViewController () {
  NSArray *_photoSets;
}
@end


@implementation YPPhotoViewController

- (void)viewDidLoad
{
  [self displaySets];
}

- (void)viewDidAppear:(BOOL)animated
{
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
//    YPPhotoDetailViewController* vc = segue.destinationViewController;
//    NSIndexPath *row = [self.photoSetTableView indexPathForSelectedRow];
#warning TODO(Charly) finish this method
  }
}


@end
