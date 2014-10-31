//
//  YPVideoListTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/12/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPVideoListTableViewController.h"
#import "YPVideoTableViewCell.h"
#import "YPVideoEmbeddedViewViewController.h"
#import "AFNetworking.h"
#import "TTTTimeIntervalFormatter.h"
#import "Config.h"

@interface YPVideoListTableViewController ()
@property (nonatomic, strong) NSArray *videosArray;
@end

@implementation YPVideoListTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self loadVideos];
  [self.tableView setSeparatorInset:UIEdgeInsetsZero];
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

#pragma mark - Helpers

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
  UIGraphicsBeginImageContext(newSize);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
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
  cell.titleLabel.text = snippet[@"title"];
  cell.subtitleLabel.text = snippet[@"description"];
  NSURL *imgURL = [NSURL URLWithString:snippet[@"thumbnails"][@"default"][@"url"]];
  UIImage *img = [self imageWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imgURL]]
                         scaledToSize:cell.imageContainer.bounds.size];
  [cell.imageContainer setImage:img];
  
  NSString *dateString = [snippet[@"publishedAt"] substringToIndex:10];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  NSDate *date = [dateFormatter dateFromString:dateString];
  TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
  cell.uploadTimeLabel.text = [NSString stringWithFormat:@"Uploaded %@", [timeIntervalFormatter stringForTimeInterval:[date timeIntervalSinceNow]]];
  
  
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 130.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"viewVideo" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"viewVideo"]) {
    YPVideoEmbeddedViewViewController *evVC = segue.destinationViewController;
    NSInteger row = [self.tableView indexPathForCell:sender].row;
    NSDictionary *snippet = self.videosArray[row][@"snippet"];
    evVC.videoId = snippet[@"resourceId"][@"videoId"];
    evVC.title = snippet[@"title"];
    
  }
}


@end
