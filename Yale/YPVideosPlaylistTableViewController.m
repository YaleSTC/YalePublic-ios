//
//  YPVideosPlaylistTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPVideosPlaylistTableViewController.h"
#import "YPVideoListTableViewController.h"
#import "AFNetworking.h"
#import "YPGlobalHelper.h"
#import "Config.h"

@interface YPVideosPlaylistTableViewController ()
@property (nonatomic, strong) NSArray *playlistArray;
@end

@implementation YPVideosPlaylistTableViewController

#define CHANNEL_ID @"UC4EY_qnSeAP1xGsh61eOoJA"

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Videos";
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [self loadPlaylists];
  
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)loadPlaylists
{
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=50&channelId=%@&key=%@", CHANNEL_ID, YOUTUBE_API_KEY];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [YPGlobalHelper hideNotificationView];
      });
      NSData *responseData = operation.responseData;
      NSError *error = nil;
      NSDictionary *playlistsObject = [NSJSONSerialization
                                       JSONObjectWithData:responseData
                                       options:NSJSONReadingMutableContainers
                                       error:&error];
      
      self.playlistArray = playlistsObject[@"items"];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      });
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [YPGlobalHelper hideNotificationView];
      });
      NSLog(@"Error: %@", error);
    }];
  });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.playlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"playlistCell"];
  NSDictionary *snippet = self.playlistArray[indexPath.row][@"snippet"];
  cell.textLabel.numberOfLines = 2;
  cell.textLabel.text = snippet[@"title"];
  return cell;
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"videoList"]) {
    YPVideoListTableViewController *videoListVC = segue.destinationViewController;
    NSInteger row = [self.tableView indexPathForCell:sender].row;
    videoListVC.playlistID = self.playlistArray[row][@"id"];
    videoListVC.title = self.playlistArray[row][@"snippet"][@"title"];
  }
}
 

@end
