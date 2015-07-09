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
    NSString *firstLetterOfLastName = [[person[@"name"] componentsSeparatedByString:@" "].lastObject substringToIndex:1];
    NSMutableArray *peopleWithThisLetter = self.sectionedPeople[firstLetterOfLastName];
    if (!peopleWithThisLetter) {
      peopleWithThisLetter = [NSMutableArray array];
      self.sectionedPeople[firstLetterOfLastName] = peopleWithThisLetter;
    }
    [peopleWithThisLetter addObject:@{@"name":person[@"name"], @"link":person[@"link"]}];
  }
  self.firstLetters = [[self.sectionedPeople allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  for (NSString *firstLetter in self.firstLetters) {
    NSMutableArray *people = self.sectionedPeople[firstLetter];
    [people sortUsingComparator:^NSComparisonResult(NSDictionary * p1, NSDictionary *p2) {
      NSString *name1 = p1[@"name"];
      NSString *name2 = p2[@"name"];
      NSComparisonResult result;
      if ((result = [[name1 componentsSeparatedByString:@" "].lastObject compare:[name2 componentsSeparatedByString:@" "].lastObject]) != NSOrderedSame) {
        return result;
      }
      return [name1 compare:name2];
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
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://directory.yale.edu/phonebook/index.htm?searchString=%@", searchString]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *responseString = operation.responseString;
    [YPGlobalHelper hideNotificationView];
    if ([responseString rangeOfString:@"Your search results:"].location != NSNotFound) {
      self.individualData = [YPGlobalHelper getInformationForPerson:responseString];
      [self.navigationController pushViewController:[YPDirectoryDetailViewController unknownPersonVCForData:self.individualData] animated:YES];
      //[self performSegueWithIdentifier:@"People Detail Segue" sender:self];
    } else if ([responseString rangeOfString:@"No results found."].location != NSNotFound) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results Found"
                                                      message:@"Your search returned no results. You may expand your search by adding the '*' wildcard."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    } else if ([responseString rangeOfString:@"Your search returned too many results."].location != NSNotFound) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too Many Results"
                                                      message:@"The Yale Phonebook server limits the number of results to be at most 25. Please be more specific."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    } else {
      self.people = [YPGlobalHelper getPeopleList:responseString];
      [self sectionPeople];
      [self.tableView reloadData];
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"YaleMobile is unable to reach Yale Phonebook server. Please check your Internet connection and try again."
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
  NSString *person = [[sectionPeople objectAtIndex:indexPath.row] objectForKey:@"name"];
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
  [YPGlobalHelper showNotificationInViewController:self
                                           message:@"Loading..."
                                             style:JGProgressHUDStyleDark];
  
  self.selectedIndexPath = indexPath;
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  NSString *fullName = cell.textLabel.text;
  NSString *lastName = [[fullName componentsSeparatedByString:@" "] lastObject];
  
  NSString *urlString = [[[self.sectionedPeople objectForKey:[lastName substringToIndex:1]] objectAtIndex:indexPath.row] objectForKey:@"link"];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    NSString *responseString = operation.responseString;
    self.individualData = [YPGlobalHelper getInformationForPerson:responseString];
    
    [YPGlobalHelper hideNotificationView];
    
    [self.navigationController pushViewController:[YPDirectoryDetailViewController unknownPersonVCForData:self.individualData] animated:YES];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"YaleMobile is unable to reach Yale Phonebook server. Please check your Internet connection and try again."
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }];
  
  [operation start];
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSLog(@"%@",self.people);
  if ([sender isKindOfClass:[YPDirectoryTableViewController class]]) {
    YPDirectoryDetailViewController *pdvc = (YPDirectoryDetailViewController *)[segue destinationViewController];
    pdvc.data = self.individualData;
  } else if ([sender isKindOfClass:[UITableViewCell class]]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    self.selectedIndexPath = indexPath;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = sender;
    NSString *fullName = cell.textLabel.text;
    YPDirectoryDetailViewController *pdvc = (YPDirectoryDetailViewController *)[segue destinationViewController];
    pdvc.data = self.individualData;
    pdvc.title = fullName;
  }
}




@end
