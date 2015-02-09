//
//  YPPhotoViewController.m
//  Yale
//
//  Created by Charly Walther on 10/3/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPPhotoViewController.h"
#import "YPFlickrCommunicator.h"
#import "YPPhotoDetailViewController.h"
#import "YPGlobalHelper.h"
#import "Config.h"
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

@interface YPPhotoViewController () {
  NSMutableArray *_photoSets;
}
@end


@implementation YPPhotoViewController

/* Provides Instagram and Flickr pictures
 * First row links to Instagram pictures
 * Subsequent rows link to Flickr albums
 */

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.title = NAVIGATION_BAR_TITLE_PHOTOS;
   //BackButton
  UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
  backItem.title = @" ";
  self.navigationItem.backBarButtonItem = backItem;
  
  self.photoSetTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [self.photoSetTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PhotoListCell"];

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
  _photoSets = [NSMutableArray array];
  /* Step one: create Instagram row */
    NSArray *instagramRow = @[@{@"title": @{@"_content": @"Instagram"}, @"id": @"INSTAGRAM"}];
    [_photoSets addObjectsFromArray:instagramRow];
    
    
  /* Step two: download and add Flickr albums as rows */
    
  YPFlickrCommunicator *flickr = [[YPFlickrCommunicator alloc] init];
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [flickr getSets:^(NSDictionary *response) {
      NSLog(@"%@", response);
      
      //_photoSets = response[@"photosets"][@"photoset"];
      [_photoSets addObjectsFromArray:response[@"photosets"][@"photoset"]];
      dispatch_async(dispatch_get_main_queue(), ^{
        [YPGlobalHelper hideNotificationView];
        [self.photoSetTableView reloadData];
      });
    }];
  });

}


#pragma table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.photoSetTableView dequeueReusableCellWithIdentifier:@"PhotoListCell" forIndexPath:indexPath];
  
  NSDictionary *set = _photoSets[indexPath.row];
  cell.textLabel.text = set[@"title"][@"_content"];
  
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    /* Flickr */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"YPPhotoViewController"
                                                         bundle:[NSBundle mainBundle]];
    YPPhotoDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoDetailVC"];
    
    // Have to provide album title and photoSetId
    detailViewController.albumTitle = _photoSets[indexPath.row][@"title"][@"_content"];
    detailViewController.photoSetId = _photoSets[indexPath.row][@"id"];
    [self.photoSetTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _photoSets.count;
}




@end
