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
@end

@implementation YPEventsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds];
  self.datePickerView.delegate = self;
  self.datePickerView.dataSource = self;
  self.title = @"Events";
  [self.view addSubview:self.datePickerView];
  
  UIBarButtonItem *todayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(onTodayButtonTouch:)];
  self.navigationItem.rightBarButtonItem = todayBarButtonItem;
  [self getEvents];
}



- (void)getEvents {
  [YPCalendarEventsServerCommunicator getEventsFromDay:[NSDate date] tilNext:60 tags:@[@"class", @"workshop", @"community"] completionBlock:^(NSArray *array) {
    NSLog(@"%@", array[2]);
  } failureBlock:^(NSError *error) {
    NSLog(@"error: %@", [error localizedDescription]);
  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Data Source

// Returns YES if the date should be marked or NO if it should not.
- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
  // The date is an `NSDate` object without time components.
  // So, we need to use dates without time components.
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
  NSDateComponents *todayComponents = [calendar components:unitFlags fromDate:[NSDate date]];
  NSDate *today = [calendar dateFromComponents:todayComponents];
  
  return [date isEqual:today];
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
  
  NSLog(@"%@", [date description]);
}


#pragma mark Interaction

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
  [self.datePickerView scrollToToday:YES];
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
