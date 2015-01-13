//
//  YPEventsViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/8/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPEventsViewController.h"
#import "YPCalendarEventsServerCommunicator.h"
#import "YPGlobalHelper.h"

@interface YPEventsViewController ()
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) NSArray *events;
@end

@implementation YPEventsViewController

#define DETAIL_HEIGHT 200

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
  
  [YPCalendarEventsServerCommunicator getEventsFromDay:dayOneSixMonthsBack tilNext:days tags:@[@"class", @"workshop", @"community"] completionBlock:^(NSArray *array) {
    self.events = array;
    [YPGlobalHelper hideNotificationView];
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
  return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)[components month], (long)[components day], (long)[components year]];
  
}
#pragma mark - Data Source

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  NSLog(@"%@", [self getDateString:date]);
  return YES;
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
  
  [self.detailTableView reloadData];
  NSLog(@"%@", [date description]);
}

#pragma mark Detail Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.detailTableView dequeueReusableCellWithIdentifier:@"detailCell"];
  return cell;
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
    NSLog(@"Updated events: %@", [self.events firstObject]);
  }
}

#pragma mark - Interaction

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
  [self.datePickerView scrollToToday:YES];
}

@end