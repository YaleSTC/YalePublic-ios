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
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>

typedef void(^SuccessHandler)(NSArray *events);

@interface YPEventsViewController ()
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) NSArray             *events;
@property (nonatomic, strong) NSArray *currentEvents;
@property (nonatomic, strong) UILabel *headerTextLabel;

@property (nonatomic, strong) SuccessHandler toExcecuteOnLoad;

@end

@implementation YPEventsViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Events VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
  
  if (self.toExcecuteOnLoad) {
    self.toExcecuteOnLoad(self.events);
  }
  [self layout];
}

//this was 260. after frames changed so Detail table view scrolls all the way to the bottom, the size left for the calendar was noticeably smaller.
#define DETAIL_HEIGHT 220

- (void)layout {
  //put this code here so the bounds are set AFTER self.view's bounds are set
  CGFloat calendarHeight = self.view.bounds.size.height - DETAIL_HEIGHT;
  
  CGRect calendarFrame = CGRectMake(0, 0, self.view.bounds.size.width, calendarHeight);
  self.datePickerView.frame = calendarFrame;
  
  CGRect detailFrame = CGRectMake(0, calendarHeight, self.view.bounds.size.width, DETAIL_HEIGHT);
  self.detailTableView.frame = detailFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [self layout];
}

- (void)viewDidLoad
{
  
  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 2);
  [self.view addSubview:self.progressView];
  
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
  UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshEvents)];
  [self.navigationItem setRightBarButtonItems:@[todayBarButtonItem, refreshBarButtonItem]];
  
  [self getEvents];
}

- (void)refreshEvents {
  [self.class storeData:nil forViewName:self.viewName];
  self.progressView.alpha = 1;
  self.progressView.progress = 0;
  [self getEvents];
}

// not sure what file type this should be. txt is pretty basic, so let's go with that. probably won't be a readable text file
#define CACHE_FILE_NAME @"events_cache.txt"

// TODO: Store in a file
+ (NSArray *)storedDataForViewName:(NSString *)viewName {
  NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:CACHE_FILE_NAME];
  NSData *data = [NSData dataWithContentsOfFile:path];
  if (!data) {
    [self storeData:nil forViewName:viewName]; // will create dictionary of viewNames
    return nil;
  }
  NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  return dict[viewName];
}

// data to store must all be combinations of objects which comply to NSCoding protocol
+ (void)storeData:(NSArray *)array forViewName:(NSString *)viewName {
  // get current dict
  NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:CACHE_FILE_NAME];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (data) {
    dict = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
  }
  if (array) {
    dict[viewName] = array;
  } else {
    [dict removeObjectForKey:viewName];
  }
  
  data = [NSKeyedArchiver archivedDataWithRootObject:[dict copy]];
  if (!path || ![data writeToFile:path atomically:YES]) {
    NSLog(@"Could not store event cache at path: %@", path);
  } else {
    NSLog(@"Saved event cache at path: %@", path);
  }
}

- (void)getEventsWithViewName:(NSString *)viewName
         completionBlock:(SuccessHandler)successHandler
           progressBlock:(void(^)(double progress))progressHandler
            failureBlock:(void(^)(NSError *error))failureHandler
{
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
  
  NSArray *storedData = [self.class storedDataForViewName:viewName];
  NSDate *dateWhenMustReload = [storedData objectAtIndex:0];
  if (!dateWhenMustReload || [dateWhenMustReload timeIntervalSinceNow] < 0) {
    NSLog(@"Reloading cache");
    NSTimeInterval weekSeconds = 7*24*60*60;
    dateWhenMustReload = [[NSDate date] dateByAddingTimeInterval:weekSeconds];
    [YPCalendarEventsServerCommunicator getEventsFromDay:dayOneNow tilNext:days viewName:viewName completionBlock:^(NSArray *events) {
      NSArray *cache = @[dateWhenMustReload, events];
      [self.class storeData:cache forViewName:viewName];
      successHandler(events);
    } progressBlock:^(double progress) {
      progressHandler(progress);
    } failureBlock:^(NSError *error) {
      failureHandler(error);
    }];
  } else {
    NSLog(@"Using cached event data");
    progressHandler(1);
    NSArray *events = storedData[1];
    self.events = events;
    self.toExcecuteOnLoad = successHandler; // this should happen in viewdidappear
    // successHandler(events);
  }
}

- (void)getEvents {
  
  [YPGlobalHelper showNotificationInViewController:self
                                           message:@"Loading"
                                             style:JGProgressHUDStyleDark];
  
  NSDate *today = [NSDate date];
  
  [self getEventsWithViewName:self.viewName completionBlock:^(NSArray *array) {
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
}

- (NSString *)getDateString:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyyMMdd"];
  return [formatter stringFromDate:date];
  
}
#pragma mark - Data Source

// Returns number of events on date
- (BOOL)datePickerView:(RSDFDatePickerView *)view numberOfEventsForDate:(NSDate *)date
{
  NSString *dateString = [self getDateString:date];
  return [self eventsForDateString:dateString].count;
}

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  return [self datePickerView:view numberOfEventsForDate:date] > 0;
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
  cell.textLabel.textColor = [YPTheme textColor];
  NSArray *tags = [event objectForKey:@"categories"];
  UIColor *color = [YPEventsCategoriesViewController colorForName:self.viewName tags:tags];
  
  //add circle of color to tableviewcell
  YPCircleView *circle;
  if (!(circle = (YPCircleView *)[cell.contentView viewWithTag:10])) {
    CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat size = 20;
    circle = [[YPCircleView alloc] initWithFrame:CGRectMake(-3, height/2-size/2, size, size)];
    circle.tag = 10;
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
