//
//  YPEventsCategoriesViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/31/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPEventsCategoriesViewController.h"
#import "YPEventsViewController.h"

@interface YPEventsCategoriesViewController ()

@end

@implementation YPEventsCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.title = @"Calendars";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 14;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  YPEventsViewController *eventsVC = [[YPEventsViewController alloc] init];
  
  switch (indexPath.row) {
    case 0:
      eventsVC.tags = @[@"class", @"arts", @"workshop", @"community", @"conferences", @"exhibitions", @"familyfriendly", @"films", @"groupmeetings", @"performances", @"spiritual", @"worship", @"sports", @"recreation", @"talks", @"readings", @"tours"];
      break;
    case 1:
      eventsVC.tags = @[@"arts"];
      break;
    case 2:
      eventsVC.tags = @[@"class", @"workshop"];
      break;
    case 3:
      eventsVC.tags = @[@"community"];
      break;
    case 4:
      eventsVC.tags = @[@"conferences"];
      break;
    case 5:
      eventsVC.tags = @[@"exhibitions"];
      break;
    case 6:
      eventsVC.tags = @[@"familyfriendly"];
      break;
    case 7:
      eventsVC.tags = @[@"films"];
      break;
    case 8:
      eventsVC.tags = @[@"groupmeetings"];
      break;
    case 9:
      eventsVC.tags = @[@"performances"];
      break;
    case 10:
      eventsVC.tags = @[@"spiritual", @"worship"];
      break;
    case 11:
      eventsVC.tags = @[@"sports", @"recreation"];
      break;
    case 12:
      eventsVC.tags = @[@"talks", @"readings"];
      break;
    case 13:
      eventsVC.tags = @[@"tours"];
      break;
    default:
      break;
  }
  [self.navigationController pushViewController:eventsVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
  switch (indexPath.row) {
    case 0:
      cell.textLabel.text = @"All";
      break;
    case 1:
      cell.textLabel.text = @"Arts";
      break;
    case 2:
      cell.textLabel.text = @"Classes & Workshops";
      break;
    case 3:
      cell.textLabel.text = @"Community";
      break;
    case 4:
      cell.textLabel.text = @"Conferences";
      break;
    case 5:
      cell.textLabel.text = @"Exhibitions";
      break;
    case 6:
      cell.textLabel.text = @"Family Friendly";
      break;
    case 7:
      cell.textLabel.text = @"Films";
      break;
    case 8:
      cell.textLabel.text = @"Group Meetings";
      break;
    case 9:
      cell.textLabel.text = @"Performances";
      break;
    case 10:
      cell.textLabel.text = @"Spiritual and Worship";
      break;
    case 11:
      cell.textLabel.text = @"Sports and Recreation";
      break;
    case 12:
      cell.textLabel.text = @"Talks and Readings";
      break;
    case 13:
      cell.textLabel.text = @"Tours";
      break;
    default:
      break;
  }
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
