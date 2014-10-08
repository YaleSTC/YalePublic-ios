//
//  YPNewsTopicsTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 10/7/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPNewsTopicsTableViewController.h"
#import "YPNewsArticlesTableViewController.h"

@interface YPNewsTopicsTableViewController ()

@end

@implementation YPNewsTopicsTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"News";
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"TopicCell"forIndexPath:indexPath];
  
  if (indexPath.row == 0) {
    cell.textLabel.text = @"All Topics";
  } else if (indexPath.row == 1) {
    cell.textLabel.text = @"Arts and Humanitis";
  } else if (indexPath.row == 2) {
    cell.textLabel.text = @"Business, Law, Society";
  } else if (indexPath.row == 3) {
    cell.textLabel.text = @"Campus and Community";
  } else if (indexPath.row == 4) {
    cell.textLabel.text = @"Science and Health";
  } else if (indexPath.row == 5) {
    cell.textLabel.text = @"World and Environment";
  }
  return cell;
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   if ([segue.identifier isEqualToString:@"showArticleList"]) {
     YPNewsArticlesTableViewController *articlesVC = segue.destinationViewController;
     NSInteger row = [self.tableView indexPathForCell:sender].row;
     if (row == 0) {
       articlesVC.url = @"http://news.yale.edu/topics/all/json";
       articlesVC.title = @"All Topics";
     } else if (row == 1) {
       articlesVC.url = @"http://news.yale.edu/topics/arts-humanities/json";
       articlesVC.title = @"Arts and Humanities";
     } else if (row == 2) {
       articlesVC.url = @"http://news.yale.edu/topics/business-law-society/json";
       articlesVC.title = @"Business, Law, Society";
     } else if (row == 3) {
       articlesVC.url = @"http://news.yale.edu/topics/campus-community/json";
       articlesVC.title = @"Campus and Community";
     } else if (row == 4) {
       articlesVC.url = @"http://news.yale.edu/topics/science-health/json";
       articlesVC.title = @"Science and Health";
     } else if (row == 5) {
       articlesVC.url = @"http://news.yale.edu/topics/world-environment/json";
       articlesVC.title = @"World and Environment";
     }
   }
 }


@end
