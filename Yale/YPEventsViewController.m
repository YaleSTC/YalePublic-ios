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
#import "YPEventsCategoriesViewController.h"
#import "YPCircleView.h"

@interface YPEventsViewController ()
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) NSArray             *events;
@property (nonatomic, strong) NSArray *currentEvents;
@property (nonatomic, strong) UILabel *headerTextLabel;
@end

@implementation YPEventsViewController

//this was 260. after frames changed so Detail table view scrolls all the way to the bottom, the size left for the calendar was noticeably smaller.
#define DETAIL_HEIGHT 220

- (void)viewWillAppear:(BOOL)animated
{
  //put this code here so the bounds are set AFTER self.view's bounds are set
  CGFloat calendarHeight = self.view.bounds.size.height - DETAIL_HEIGHT;
  
  CGRect calendarFrame = CGRectMake(0, 0, self.view.bounds.size.width, calendarHeight);
  self.datePickerView.frame = calendarFrame;
  
  CGRect detailFrame = CGRectMake(0, calendarHeight, self.view.bounds.size.width, DETAIL_HEIGHT);
  self.detailTableView.frame = detailFrame;
  [super viewWillAppear:animated];
  
  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 2);
  [self.view addSubview:self.progressView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  CGFloat calendarHeight = self.view.bounds.size.height - DETAIL_HEIGHT;
  
  CGRect calendarFrame = CGRectMake(0, 0, self.view.bounds.size.width, calendarHeight);
  self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:calendarFrame];
  self.datePickerView.delegate = self;
  self.datePickerView.dataSource = self;
  self.title = @"Events";
  [self.view insertSubview:self.datePickerView atIndex:0];
  
  CGRect detailFrame = CGRectMake(0, calendarHeight, self.view.bounds.size.width, DETAIL_HEIGHT);
  self.detailTableView = [[UITableView alloc] initWithFrame:detailFrame];
  self.detailTableView.dataSource = self;
  self.detailTableView.delegate = self;
  [self.detailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"detailCell"];
  [self.view insertSubview:self.detailTableView atIndex:0];
  
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
  
  // Getting day one of current month
  components.month = 0;
  components.day   = 0;
  components.year  = 0;
  components.era   = 0;
  NSDate *dayOneNow = [calendar dateByAddingComponents:components
                                                          toDate:dayOneInCurrentMonth
                                                         options:0];

  
  // Getting day one of 6 month forward
  components.month = 6;
  NSDate *dayOneSixMonthsForward = [calendar dateByAddingComponents:components
                                                             toDate:dayOneInCurrentMonth
                                                            options:0];
  NSLog(@"%@", dayOneSixMonthsForward);
  
  // Getting the number of days in between the two dates
  NSInteger days = [YPEventsViewController daysBetweenDate:dayOneInCurrentMonth andDate:dayOneSixMonthsForward];
  
  [YPCalendarEventsServerCommunicator getEventsFromDay:dayOneNow tilNext:days viewName:self.viewName completionBlock:^(NSArray *array) {
    self.events = array;
    [YPGlobalHelper hideNotificationView];
    [self.datePickerView reloadData];
    [self.datePickerView selectDate:today];
  
    NSString *dateString = [self getDateString:today];
    self.currentEvents = [self eventsForDateString:dateString];
    [self.detailTableView reloadData];
    
  } progressBlock:^(double progress) {
    [self.progressView setProgress:progress animated:YES];
    if (self.progressView.hidden != progress > 0.99) {
      [UIView animateWithDuration:1 animations:^{
        self.progressView.alpha = progress < 0.99;
      }];
    }
  } failureBlock:^(NSError *error) {
    NSLog(@"error: %@", [error localizedDescription]);
    [YPGlobalHelper hideNotificationView];
  }];
  
  [YPGlobalHelper showNotificationInViewController:self
                                           message:@"Loading"
                                             style:JGProgressHUDStyleDark];
}

- (NSString *)getDateString:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyyMMdd"];
  return [formatter stringFromDate:date];
  
}
#pragma mark - Data Source

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  NSString *dateString = [self getDateString:date];
  return [self eventsForDateString:dateString].count;
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
  self.currentEvents = [self eventsForDateString:dateString];
  [self.detailTableView reloadData];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  self.headerTextLabel.text = [formatter stringFromDate:date];
}

#pragma mark Detail Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.currentEvents count];
}

+ (NSString *)eventTitle:(NSDictionary *)event
{
  return [[[event objectForKey:@"summary"] stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"'"] stringByReplacingOccurrencesOfString:@"&lsquo;" withString:@"'"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.detailTableView dequeueReusableCellWithIdentifier:@"detailCell"];
  NSDictionary *event = [self.currentEvents objectAtIndex:indexPath.row];
  cell.textLabel.text = [self.class eventTitle:event];
  NSArray *tags = [event objectForKey:@"categories"];
  UIColor *color = [YPEventsCategoriesViewController colorForName:self.viewName tags:tags];
  
  //add circle of color to tableviewcell
  YPCircleView *circle;
  if (!(circle = (YPCircleView *)[cell.contentView viewWithTag:1])) {
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat size = 20;
    circle = [[YPCircleView alloc] initWithFrame:CGRectMake(-3, height/2-size/2, size, size)];
    circle.tag = 1;
    circle.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:circle];
  }
  circle.color = color;
  [circle setNeedsDisplay];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 44; //default. just to make sure everything is consistent
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  YPEventsDetailViewController *detail = [[YPEventsDetailViewController alloc] init];
  NSDictionary *event = [self.currentEvents objectAtIndex:indexPath.row];
  detail.url = [event objectForKey:@"eventlink"];
  detail.title = [self.class eventTitle:event];
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

//dateString is of format yyyyMMDD. this way, converting to an int will create a monotonic function date->int, to make bounds checking easy.
//checks to see if the date is between the start and end dates for each event
- (NSArray *)eventsForDateString:(NSString *)dateString
{
  //date string will be an int, in the range of 20 million. that should easily fit in an int.
  int dateIntValue = [dateString intValue];
  NSMutableArray *eventsArray = [NSMutableArray array];
  [self.events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    int startDate = [obj[@"start"][@"datetime"] intValue];
    int endDate = [obj[@"end"][@"datetime"] intValue];
    if (startDate <= dateIntValue && endDate >= dateIntValue) {
      [eventsArray addObject:obj];
    }
  }];
  return [eventsArray copy];
}

#pragma mark - Interaction

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
  [self.datePickerView scrollToToday:YES];
  [self.datePickerView selectDate:[NSDate date]];
  [self datePickerView:self.datePickerView didSelectDate:[NSDate date]]; //this isn't called automatically when set programmatically
}

@end
