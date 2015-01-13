//
//  YPEventsViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/8/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPEventsViewController.h"
#import "YPCalendarEventsServerCommunicator.h"
#import "YPEventsDetailViewController.h"
#import "YPGlobalHelper.h"
#import "YPTheme.h"

@interface YPEventsViewController ()
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) NSArray             *events;
@property (nonatomic, strong) NSMutableDictionary *eventsDictionary;
@property (nonatomic, strong) NSArray *currentEvents;
@property (nonatomic, strong) UILabel *headerTextLabel;
@end

@implementation YPEventsViewController

#define DETAIL_HEIGHT 260

- (void)viewDidLoad
{
  [super viewDidLoad];
  CGFloat calendarHeight = self.view.bounds.size.height - DETAIL_HEIGHT;
  
  CGRect calendarFrame = CGRectMake(0, 0, self.view.bounds.size.width, calendarHeight);
  self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:calendarFrame];
  self.datePickerView.delegate = self;
  self.datePickerView.dataSource = self;
  self.title = @"Events";
  [self.view addSubview:self.datePickerView];
  
  CGRect detailFrame = CGRectMake(0, calendarHeight, self.view.bounds.size.width, DETAIL_HEIGHT);
  self.detailTableView = [[UITableView alloc] initWithFrame:detailFrame];
  self.detailTableView.dataSource = self;
  self.detailTableView.delegate = self;
  [self.detailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"detailCell"];
  [self.view addSubview:self.detailTableView];
  
  CGRect tableHeaderFrame = CGRectMake(0, 0, self.view.bounds.size.width, 24.0f);
  UIView *tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderFrame];
  tableHeaderView.backgroundColor = [YPTheme navigationBarColor];
  tableHeaderFrame.origin.y += 1;
  tableHeaderFrame.size.height -= 2;
  self.headerTextLabel = [[UILabel alloc] initWithFrame:tableHeaderFrame];
  [tableHeaderView addSubview:self.headerTextLabel];
  self.headerTextLabel.textAlignment = NSTextAlignmentCenter;
  self.headerTextLabel.textColor = [UIColor whiteColor];
  self.detailTableView.tableHeaderView = tableHeaderView;
  self.detailTableView.tableFooterView = nil;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  self.headerTextLabel.text = [formatter stringFromDate:[NSDate date]];
  
  
  
  UIBarButtonItem *todayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(onTodayButtonTouch:)];
  self.navigationItem.rightBarButtonItem = todayBarButtonItem;
  [self getEvents];
  
}

- (void)getEvents {
  NSDate *today = [NSDate date];
  
  // Getting first day of this month
  NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
  NSDateComponents *components = [calendar components:(NSCalendarUnitEra  |
                                                       NSCalendarUnitYear |
                                                       NSCalendarUnitMonth)
                                             fromDate:today];
  components.day = 1;
  NSDate *dayOneInCurrentMonth = [calendar dateFromComponents:components];
  NSLog(@"%@", dayOneInCurrentMonth);
  
  // Getting day one of 6 month back
  components.month = -6;
  components.day   = 0;
  components.year  = 0;
  components.era   = 0;
  NSDate *dayOneSixMonthsBack = [calendar dateByAddingComponents:components
                                                          toDate:dayOneInCurrentMonth
                                                         options:0];
  NSLog(@"%@", dayOneSixMonthsBack);
  
  // Getting day one of 6 month forward
  components.month = 6;
  NSDate *dayOneSixMonthsForward = [calendar dateByAddingComponents:components
                                                             toDate:dayOneInCurrentMonth
                                                            options:0];
  NSLog(@"%@", dayOneSixMonthsForward);
  
  // Getting the number of days in between the two dates
  NSInteger days = [YPEventsViewController daysBetweenDate:dayOneSixMonthsBack andDate:dayOneSixMonthsForward];
  
  [YPCalendarEventsServerCommunicator getEventsFromDay:dayOneSixMonthsBack tilNext:days tags:@[@"class", @"workshop", @"community", @"conferences", @"exhibitions", @"familyfriendly", @"films", @"groupmeetings", @"performances", @"spiritual", @"worship", @"sports", @"recreation", @"talks", @"readings", @"tours"] completionBlock:^(NSArray *array) {
    self.events = array;
    [YPGlobalHelper hideNotificationView];
    [self.datePickerView reloadData];
    [self.datePickerView selectDate:today];
  
    NSString *dateString = [self getDateString:today];
    self.currentEvents = [self.eventsDictionary objectForKey:dateString];
    [self.detailTableView reloadData];
    
  } failureBlock:^(NSError *error) {
    NSLog(@"error: %@", [error localizedDescription]);
  }];
  
  [YPGlobalHelper showNotificationInViewController:self
                                           message:@"Loading"
                                             style:JGProgressHUDStyleDark];
}

- (NSString *)getDateString:(NSDate *)date {
  NSCalendar *gregorian = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents *components =
  [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
  return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)[components month], (long)[components day], (long)[components year] % 2000];
  
}
#pragma mark - Data Source

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  NSString *dateString = [self getDateString:date];
  return [self.eventsDictionary objectForKey:dateString];
}
  

// Returns YES if all tasks on the date are completed or NO if they are not completed.
- (BOOL)datePickerView:(RSDFDatePickerView *)view isCompletedAllTasksOnDate:(NSDate *)date
{
  NSDate *now = [NSDate date];
  if ([date compare:now] == NSOrderedAscending) {
    return YES;
  } else {
    return NO;
  }
}


#pragma mark - Delegate Functions

// Returns YES if the date should be highlighted or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldHighlightDate:(NSDate *)date
{
  
  return YES;
}

// Returns YES if the date should be selected or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldSelectDate:(NSDate *)date
{
  return YES;
}

// Prints out the selected date.
- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
  NSString *dateString = [self getDateString:date];
  self.currentEvents = [self.eventsDictionary objectForKey:dateString];
  [self.detailTableView reloadData];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  self.headerTextLabel.text = [formatter stringFromDate:date];
}

#pragma mark Detail Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.currentEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.detailTableView dequeueReusableCellWithIdentifier:@"detailCell"];
  NSDictionary *event = [self.currentEvents objectAtIndex:indexPath.row];
  cell.textLabel.text = [event objectForKey:@"summary"];
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  YPEventsDetailViewController *detail = [[YPEventsDetailViewController alloc] init];
  NSDictionary *event = [self.currentEvents objectAtIndex:indexPath.row];
  detail.url = [event objectForKey:@"eventlink"];
  detail.title = [event objectForKey:@"summary"];
  [self.detailTableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (detail.url)
      [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Helper

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
  NSDate *fromDate;
  NSDate *toDate;
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
               interval:NULL forDate:fromDateTime];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
               interval:NULL forDate:toDateTime];
  
  NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate toDate:toDate options:0];
  
  return [difference day];
}

#pragma mark - Setter

- (void)setEvents:(NSArray *)events
{
  if (_events != events) {
    _events = events;
    self.eventsDictionary = [NSMutableDictionary dictionary];
    
    [_events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      NSString *dateString = obj[@"start"][@"shortdate"];
      if (![self.eventsDictionary objectForKey:dateString]) {
        [self.eventsDictionary setObject:[NSMutableArray array] forKey:dateString];
      }
      [self.eventsDictionary[dateString] addObject:obj];
    }];
    NSLog(@"Events updated: %@", self.eventsDictionary);
  }
}

#pragma mark - Interaction

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
  [self.datePickerView scrollToToday:YES];
}

@end
