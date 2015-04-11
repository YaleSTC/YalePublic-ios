//
//  YPNewsArticlesTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPNewsArticlesTableViewController.h"
#import "YPNewsEmbeddedViewController.h"
#import "YPNewsArticleCell.h"
#import "AFNetworking.h"
#import "TTTTimeIntervalFormatter.h"
#import "MWFeedParser/NSString+HTML.h"
#import "YPGlobalHelper.h"
#import "YPTheme.h"

@interface YPNewsArticlesTableViewController ()
@property (nonatomic, strong) NSArray *articlesArray;
@property (strong) UIProgressView *progressView;
@end

@implementation YPNewsArticlesTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self getArticles];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (!self.progressView) {
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    [self.view addSubview:self.progressView];
  }
}


- (void)getArticles
{
  [YPGlobalHelper showNotificationInViewController:self message:@"loading..." style:JGProgressHUDStyleDark];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFHTTPRequestOperation *operation = [manager GET:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    [YPGlobalHelper hideNotificationView];
    NSData *responseData = operation.responseData;
    NSError *error = nil;
    NSDictionary *articlesObject = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableContainers
                                    error:&error];
    
    self.articlesArray = articlesObject[@"news"];
    [self.tableView reloadData];
    
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [YPGlobalHelper hideNotificationView];
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
  
}



#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.articlesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  YPNewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YPNewsArticleCell"];
  if (cell == nil) {
    // Load the top-level objects from the custom cell XIB.
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"YPNewsArticleCell" owner:self options:nil];
    cell = [topLevelObjects objectAtIndex:0];
  }
  NSDictionary *articleNode = self.articlesArray[indexPath.row][@"node"];
  
  cell.titleLabel.text = [[articleNode[@"title"] stringByDecodingHTMLEntities] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  cell.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
  cell.titleLabel.numberOfLines = 2;
  cell.titleLabel.textColor = [YPTheme textColor];
  
  cell.snippetLabel.text = [[articleNode[@"description"] stringByDecodingHTMLEntities] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  cell.snippetLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  cell.snippetLabel.numberOfLines = 1;
  
  NSString *dateString = [articleNode[@"date"] substringFromIndex:5];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm:ss zzz"];
  NSDate *date = [dateFormatter dateFromString:dateString];
  TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
  cell.timeLabel.text = [timeIntervalFormatter stringForTimeInterval:[date timeIntervalSinceNow]];
  
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([self.articlesArray count] == 0)
    return 0;
  NSDictionary *articleNode = self.articlesArray[indexPath.row][@"node"];
  
  NSString *text = [[articleNode[@"title"] stringByDecodingHTMLEntities] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  CGSize size = [text sizeWithAttributes: @{
                                            NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]
                                            }];
  CGFloat disclosureIndicatorWidth = 58.0;
  if (size.width > self.tableView.frame.size.width - disclosureIndicatorWidth)
    return 100.0;
  else
    return 80.0;
}



#pragma mark - Navigation


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"showArticle" sender:indexPath];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)indexPath
{
  if ([segue.identifier isEqualToString:@"showArticle"]) {
    YPNewsEmbeddedViewController *articleVC = segue.destinationViewController;
    NSDictionary *articleNode = self.articlesArray[indexPath.row][@"node"];
    articleVC.url = articleNode[@"path"];
    articleVC.title = [NSString stringWithFormat:@"YaleNews | %@", [articleNode[@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    
  }
}


@end
