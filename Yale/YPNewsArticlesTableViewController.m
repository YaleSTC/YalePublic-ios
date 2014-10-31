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

@interface YPNewsArticlesTableViewController ()
@property (nonatomic, strong) NSArray *articlesArray;
@end

@implementation YPNewsArticlesTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self getArticles];
}


- (void)getArticles
{
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSData *responseData = operation.responseData;
    NSError *error = nil;
    NSDictionary *articlesObject = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableContainers
                                    error:&error];
    
    self.articlesArray = articlesObject[@"news"];
    [self.tableView reloadData];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
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
  return 100.0;
}



 #pragma mark - Navigation


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"showArticle" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"showArticle"]) {
     YPNewsEmbeddedViewController *articleVC = segue.destinationViewController;
     NSDictionary *articleNode = self.articlesArray[[self.tableView indexPathForCell:sender].row][@"node"];
     articleVC.url = articleNode[@"path"];
     articleVC.title = [NSString stringWithFormat:@"YaleNews | %@", [articleNode[@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
     
     
   }
}


@end
