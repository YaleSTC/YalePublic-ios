//
//  YPEventsViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/8/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPEventsViewController.h"
#import "YPCalendarEventsServerCommunicator.h"

@interface YPEventsViewController ()
@property (nonatomic, strong) RSDFDatePickerView *datePickerView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) NSDictionary *currentEvents;
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
  
  
  
  UIBarButtonItem *todayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(onTodayButtonTouch:)];
  self.navigationItem.rightBarButtonItem = todayBarButtonItem;
  [self getEvents];
}

- (void)getEvents {
  [YPCalendarEventsServerCommunicator getEventsFromDay:[NSDate date] tilNext:180 tags:@[@"class", @"workshop", @"community"] completionBlock:^(NSArray *array) {
    NSLog(@"%@", [array firstObject]);
  } failureBlock:^(NSError *error) {
    NSLog(@"error: %@", [error localizedDescription]);
  }];
}

- (BOOL)dateHasEvents {
  return YES;
}

#pragma mark Data Source

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  if ([self dateHasEvents])
    return YES;
  else
    return NO;
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


#pragma mark Delegate Functions

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

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
}

- ()

#pragma mark Interaction

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
  [self.datePickerView scrollToToday:YES];
}

@end
