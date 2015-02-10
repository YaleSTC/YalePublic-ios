//
//  YPResultsTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 2/2/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPResultsTableViewController.h"

@implementation YPResultsTableViewController

- (void)viewDidLoad
{
  self.extendedLayoutIncludesOpaqueBars = YES;
  self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeTop;
  [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.filteredBuildings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"buildingCell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buildingCell"];
    
  }
  cell.textLabel.text = [self.filteredBuildings objectAtIndex:indexPath.row];
  
  return cell;
}
@end
