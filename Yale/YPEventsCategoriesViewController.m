//
//  YPEventsCategoriesViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/31/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPEventsCategoriesViewController.h"
#import "YPEventsViewController.h"
#import "YPCircleView.h"


#warning find correct colors
//for easy, consistent access and lookup. also to lookup by tag
#define CATEGORIES_AND_TAGS @[ \
@[@"All", @[@"class", @"arts", @"workshop", @"community", @"conferences", @"exhibitions", @"familyfriendly", @"films", @"groupmeetings", @"performances", @"spiritual", @"worship", @"sports", @"recreation", @"talks", @"readings", @"tours"], [UIColor clearColor]], \
@[@"Arts", @[@"arts"], [UIColor orangeColor]/*darker orange*/], \
@[@"Classes & Workshops", @[@"class", @"workshop"], [UIColor redColor]], \
@[@"Community", @[@"community"], [UIColor blueColor]/*lightblue*/], \
@[@"Conferences", @[@"conferences"], [UIColor greenColor]/*darkgreen*/], \
@[@"Exhibitions", @[@"exhibitions"], [UIColor orangeColor]], \
@[@"Family Friendly", @[@"familyfriendly"], [UIColor blueColor]], \
@[@"Films", @[@"films"], [UIColor purpleColor]], \
@[@"Group Meetings", @[@"groupmeetings"], [UIColor redColor]/*crimson*/], \
@[@"Performances", @[@"performances"], [UIColor grayColor]/*beige*/], \
@[@"Spiritual and Worship", @[@"spiritual", @"worship"], [UIColor grayColor]/*pink*/], \
@[@"Sports and Recreation", @[@"sports", @"recreation"], [UIColor blueColor]/*dark blue*/], \
@[@"Talks and Readings", @[@"talks", @"readings"], [UIColor greenColor]/*light green*/], \
@[@"Tours", @[@"tours"], [UIColor yellowColor]]]

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
  return CATEGORIES_AND_TAGS.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  YPEventsViewController *eventsVC = [[YPEventsViewController alloc] init];
  eventsVC.tags = CATEGORIES_AND_TAGS[indexPath.row][1];
  [self.navigationController pushViewController:eventsVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
  cell.textLabel.text = CATEGORIES_AND_TAGS[indexPath.row][0];
  YPCircleView *circle = (YPCircleView *)[cell.contentView viewWithTag:1];
  circle.color = CATEGORIES_AND_TAGS[indexPath.row][2];
  [circle setNeedsDisplay];
  return cell;
}

+ (UIColor *)colorForTags:(NSArray *)tags
{
  for (NSArray *category in CATEGORIES_AND_TAGS) {
    if (![category[0] isEqualToString:@"All"]) {
      for (NSString *tag in tags) {
        if ([category[1] containsObject:tag]) {
          return category[2];
        }
      }
    }
  }
  return [UIColor clearColor];
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
