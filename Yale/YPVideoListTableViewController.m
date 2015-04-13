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
#import "YPGlobalHelper.h"
#import "Config.h"
#import "YPTheme.h"

@interface YPVideoListTableViewController ()
@property (nonatomic, strong) NSArray *videosArray;
@property (nonatomic, strong) UIProgressView *progressView;
@property (atomic, strong) NSMutableArray *thumbnailImages; //NSArray of UIImages. The index of the image corresponds to the row of the cell it belongs in.
@end

@implementation YPVideoListTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadVideos];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.tableView setSeparatorInset:UIEdgeInsetsZero];
  if (!self.progressView) {
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    [self.view addSubview:self.progressView];
  }
}

- (void)foundImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath
{
  while (self.thumbnailImages.count <= indexPath.row) {
    [self.thumbnailImages addObject:[NSNull null]];
  }
  self.thumbnailImages[indexPath.row] = image;
  YPVideoTableViewCell *cell = (YPVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
  [cell.imageContainer setImage:image];
}

- (void)loadVideos
{
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=%@&key=%@", self.playlistID, YOUTUBE_API_KEY];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [YPGlobalHelper hideNotificationView];
      });
      NSData *responseData = operation.responseData;
      NSError *error = nil;
      NSDictionary *videosObject = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableContainers
                                    error:&error];
      
      self.videosArray = videosObject[@"items"];
      self.thumbnailImages = [NSMutableArray arrayWithCapacity:self.videosArray.count];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
      });
      
      
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [YPGlobalHelper hideNotificationView];
      });
      NSLog(@"Error: %@", error);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
      if (totalBytesExpectedToRead < 0) totalBytesExpectedToRead = totalBytesRead * 20;
      [self.progressView setProgress:(double) totalBytesRead / (double)totalBytesExpectedToRead animated:YES];
      if (totalBytesRead >= totalBytesExpectedToRead) {
        [UIView animateWithDuration:0.8 animations:^{
          self.progressView.alpha = 0;
        }];
      }
    }];
  });

  
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
  cell.titleLabel.textColor = [YPTheme textColor];
  cell.subtitleLabel.text = snippet[@"description"];
  NSURL *imgURL = [NSURL URLWithString:snippet[@"thumbnails"][@"default"][@"url"]];
  
  if (self.thumbnailImages.count <= indexPath.row || [self.thumbnailImages[indexPath.row] isKindOfClass:[NSNull class]]) {
    cell.imageContainer.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      UIImage *img = [self imageWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imgURL]]
                             scaledToSize:cell.imageContainer.bounds.size];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self foundImage:img forIndexPath:indexPath];
      });
      
    });
  } else {
    cell.imageContainer.image = self.thumbnailImages[indexPath.row];
  }
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
