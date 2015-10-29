//
//  YPDirectoryTableViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "YPDirectoryTableViewController.h"
#import "AFNetworking.h"
#import "YPGlobalHelper.h"
#import "YPDirectoryDetailViewController.h"
#import <GAI.h>
#import <GAIFields.h>
#import "YPTheme.h"
#import <GAIDictionaryBuilder.h>

@interface YPDirectoryTableViewController ()

@end

@implementation YPDirectoryTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Directory";
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Directory VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark Data Manipulation

- (NSMutableDictionary *)sectionedPeople
{
  if (!_sectionedPeople) {
    _sectionedPeople = [[NSMutableDictionary alloc] init];
  }
  return _sectionedPeople;
}

// take raw input from self.people
// populate self.sectionedPeople and self.firstLetters
- (void)sectionPeople
{
  self.sectionedPeople = nil; // start over
  for (NSDictionary *person in self.people) {
    NSString *firstLetterOfLastName = [person[@"LastName"] substringToIndex:1];
    NSMutableArray *peopleWithThisLetter = self.sectionedPeople[firstLetterOfLastName];
    if (!peopleWithThisLetter) {
      peopleWithThisLetter = [NSMutableArray array];
      self.sectionedPeople[firstLetterOfLastName] = peopleWithThisLetter;
    }
    [peopleWithThisLetter addObject:person];
  }
  self.firstLetters = [[self.sectionedPeople allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
  // now make sure they're sorted
  for (NSString *firstLetter in self.firstLetters) {
    NSMutableArray *people = self.sectionedPeople[firstLetter];
    [people sortUsingComparator:^NSComparisonResult(NSDictionary * p1, NSDictionary *p2) {
      // sort is base solely on name. sort by last name, then if last names are equal sort by whole name
      NSString *firstName1 = p1[@"FirstName"];
      NSString *firstName2 = p2[@"FirstName"];
      NSString *lastName1 = p1[@"LastName"];
      NSString *lastName2 = p2[@"LastName"];
      NSComparisonResult result;
      if ((result = [lastName1 compare:lastName2]) != NSOrderedSame) {
        return result;
      }
      return [firstName1 compare:firstName2];
    }];
    self.sectionedPeople[firstLetter] = [people copy];
  }
}



#pragma mark - Search Bar

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  UISearchBar *searchBar = self.searchBar;
  CGRect rect = searchBar.frame;
  rect.origin.y = MIN(0, scrollView.contentOffset.y);
  searchBar.frame = rect;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  searchBar.showsCancelButton = YES;
  [searchBar setShowsCancelButton:YES animated:YES];
  [UIView beginAnimations:@"FadeIn" context:nil];
  [UIView setAnimationDuration:0.2];
  [UIView commitAnimations];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  searchBar.text = @"";
  [self hideKeyboard];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self hideKeyboard];
  NSString *searchString = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://directory.yale.edu/suggest/?q=%@", searchString]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    //NSString *responseString = operation.responseString;
    [YPGlobalHelper hideNotificationView];
    //NSData *results =
    NSError* error;
    NSArray* data = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error][@"Records"][@"Record"];
    if ([data isKindOfClass:[NSDictionary class]]) {
      self.individualData = (NSMutableDictionary *)data;
      [self.navigationController pushViewController:[YPDirectoryDetailViewController unknownPersonVCForData:self.individualData] animated:YES];
      //[self performSegueWithIdentifier:@"People Detail Segue" sender:self];
    } else if (data.count == 0) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results Found"
                                                      message:@"Your search returned no results. Try a different search string."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }/* else if ([responseString rangeOfString:@"Your search returned too many results."].location != NSNotFound) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Results"
                                                      message:@"The Yale Phonebook server limits the number of results to be at most 25. Please be more specific."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      
    }*/ else {
      if ([data isKindOfClass:[NSDictionary class]])
      {
        self.people = @[data];
      }
      else
        self.people = data;
      [self sectionPeople];
      [self.tableView reloadData];
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"Yale app is unable to reach Yale Phonebook server. Please check your Internet connection and try again."
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }];
  
  [YPGlobalHelper showNotificationInViewController:self
                                           message:@"Searching..."
                                             style:JGProgressHUDStyleDark];
  
  [operation start];
}

- (void)hideKeyboard
{
  [UIView beginAnimations:@"FadeOut" context:nil];
  [UIView setAnimationDuration:0.2];
  [UIView commitAnimations];
  
  [self.searchBar resignFirstResponder];
  [self.searchBar setShowsCancelButton:NO animated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.firstLetters count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [self.firstLetters objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSString *sectionTitle = [self.firstLetters objectAtIndex:section];
  NSArray *sectionPeople = [self.sectionedPeople objectForKey:sectionTitle];
  return [sectionPeople count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"People Cell"];
  
  NSString *sectionTitle = [self.firstLetters objectAtIndex:indexPath.section];
  NSArray *sectionPeople = [self.sectionedPeople objectForKey:sectionTitle];
  NSString *person = [[sectionPeople objectAtIndex:indexPath.row] objectForKey:@"DisplayName"];
  cell.textLabel.text = person;
  cell.textLabel.textColor = [YPTheme textColor];
  return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  /*[YPGlobalHelper showNotificationInViewController:self
                                           message:@"Loading..."
                                             style:JGProgressHUDStyleDark];
  */
  self.selectedIndexPath = indexPath;
  NSString *sectionTitle = [self.firstLetters objectAtIndex:indexPath.section];
  NSMutableDictionary *person = self.sectionedPeople[sectionTitle][indexPath.row];
  self.individualData = person;
  [self.navigationController pushViewController:[YPDirectoryDetailViewController unknownPersonVCForData:self.individualData] animated:YES];
  /*
  NSString *urlString = [[[self.sectionedPeople objectForKey:[lastName substringToIndex:1]] objectAtIndex:indexPath.row] objectForKey:@"link"];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  */
  /*[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    NSString *responseString = operation.responseString;
    self.individualData = [YPGlobalHelper getInformationForPerson:responseString];
    
    //[YPGlobalHelper hideNotificationView];
    
    [self.navigationController pushViewController:[YPDirectoryDetailViewController unknownPersonVCForData:self.individualData] animated:YES];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"YaleMobile is unable to reach Yale Phonebook server. Please check your Internet connection and try again."
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }];
  
  [operation start];*/
}

@end
