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
#import "YPTheme.h"

//for easy, consistent access and lookup. also to lookup by tag
//colors found by sampling colors from the old app
#define CATEGORY_DATA @[ \
@[@"All", @[], [UIColor clearColor]], \
@[@"Arts", @[@"arts"], [UIColor orangeColor]/*darker orange*/], \
@[@"Classes & Workshops", @[@"class", @"workshop"], [UIColor colorWithRed:0.87 green:0.08 blue:0.08 alpha:1]], \
@[@"Community", @[@"community"], [UIColor colorWithRed:0.13 green:0.67 blue:0.67 alpha:1]], \
@[@"Conferences", @[@"conferences", @"conference"], [UIColor colorWithRed:0.14 green:0.34 blue:0.07 alpha:1]], \
@[@"Exhibitions", @[@"exhibitions", @"Exhibit", @"exhibition"], [UIColor colorWithRed:0.89 green:0.63 blue:0.04 alpha:1]], \
@[@"Family Friendly", @[@"familyfriendly", @"family"], [UIColor colorWithRed:0.1 green:0.49 blue:0.87 alpha:1]], \
@[@"Films", @[@"films", @"film", @"screening"], [UIColor colorWithRed:0.58 green:0.39 blue:0.7 alpha:1]], \
@[@"Group Meetings", @[@"groupmeetings", @"meeting", @"seminar"], [UIColor colorWithRed:0.7 green:0.04 blue:0.3 alpha:1]], \
@[@"Performances", @[@"performances", @"performance"], [UIColor colorWithRed:0.74 green:0.72 blue:0.63 alpha:1]], \
@[@"Spiritual and Worship", @[@"spiritual", @"worship"], [UIColor colorWithRed:1 green:0.58 blue:0.58 alpha:1]], \
@[@"Sports and Recreation", @[@"sports", @"recreation"], [UIColor colorWithRed:0.18 green:0.29 blue:0.42 alpha:1]], \
@[@"Talks and Readings", @[@"talk", @"reading", @"lecture"], [UIColor colorWithRed:0.11 green:0.72 blue:0.46 alpha:1]], \
@[@"Tours", @[@"tours", @"tour"], [UIColor colorWithRed:0.88 green:0.81 blue:0.24 alpha:1]]]

@interface YPEventsCategoriesViewController ()

@end

@implementation YPEventsCategoriesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Calendars";
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"categoryCell"];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CATEGORY_DATA.count;
}

+ (NSString *)viewNameForCategory:(NSString *)category
{
  return [[[category stringByReplacingOccurrencesOfString:@"&" withString:@"And"] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"and" withString:@"And"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  YPEventsViewController *eventsVC = [[YPEventsViewController alloc] init];
  eventsVC.viewName = [self.class viewNameForCategory:CATEGORY_DATA[indexPath.row][0]];
  [self.navigationController pushViewController:eventsVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
  cell.textLabel.text = CATEGORY_DATA[indexPath.row][0];
  cell.textLabel.textColor = [YPTheme textColor];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  YPCircleView *circle;
  if (!(circle = [cell.contentView viewWithTag:10])) {
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat size = 40;
    CGFloat width = self.tableView.bounds.size.width;
    circle = [[YPCircleView alloc] initWithFrame:CGRectMake(width-size/2-45, height/2 - size/2, size, size)];
    [cell.contentView addSubview:circle];
    circle.tag = 10;
    circle.backgroundColor = [UIColor clearColor];
  }
  circle.color = CATEGORY_DATA[indexPath.row][2];
  [circle setNeedsDisplay];
  return cell;
}

+ (UIColor *)colorForName:(NSString *)viewName tags:(NSArray *)tags
{
  for (NSArray *category in CATEGORY_DATA) {
    if ([viewName isEqualToString:@"All"]) {
      for (NSString *tag in tags) {
        if ([category[1] containsObject:tag]) {
          return category[2];
        }
      }
    } else {
      if ([[self viewNameForCategory:category[0]] isEqualToString:viewName]) {
        return category[2];
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
