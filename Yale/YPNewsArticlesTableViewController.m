//
//  YPNewsArticlesTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPNewsArticlesTableViewController.h"
#import "YPNewsEmbeddedViewController.h"
#import "AFNetworking.h"

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
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell" forIndexPath:indexPath];
  NSDictionary *articleNode = self.articlesArray[indexPath.row][@"node"];
  
  cell.textLabel.numberOfLines = 0;
  cell.textLabel.text = articleNode[@"title"];
  return cell;
}



 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"showArticle"]) {
     YPNewsEmbeddedViewController *articleVC = segue.destinationViewController;
     NSDictionary *articleNode = self.articlesArray[[self.tableView indexPathForCell:sender].row][@"node"];
     articleVC.url = articleNode[@"path"];
     articleVC.title = [NSString stringWithFormat:@"YaleNews | %@", articleNode[@"title"]];
     
     
     
   }
 }


@end
