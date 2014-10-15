//
//  YPVideoListTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPVideoListTableViewController.h"
#import "YPVideoTableViewCell.h"
#import "AFNetworking.h"
#import "Config.h"

@interface YPVideoListTableViewController ()
@property (nonatomic, strong) NSArray *videosArray;
@end

@implementation YPVideoListTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadVideos];
}

- (void)loadVideos
{
  NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=%@&key=%@", self.playlistID, YOUTUBE_API_KEY];
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSData *responseData = operation.responseData;
    NSError *error = nil;
    NSDictionary *videosObject = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableContainers
                                  error:&error];
    
    self.videosArray = videosObject[@"items"];
    [self.tableView reloadData];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
  
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.videosArray count];
}


- (YPVideoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  YPVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
  if (cell == nil) {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"YPVideoTableViewCell" owner:self options:nil];
    cell = [topLevelObjects objectAtIndex:0];
  }
  NSDictionary *snippet = self.videosArray[indexPath.row][@"snippet"];
  NSLog(@"%@", snippet);
  cell.titleLabel = snippet[@"title"];
  cell.subtitleLabel = snippet[@"description"];
  
  
  
  return cell;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
