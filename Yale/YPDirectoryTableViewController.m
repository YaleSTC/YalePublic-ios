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
@interface YPDirectoryTableViewController ()

@end

@implementation YPDirectoryTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Directory";
  
}


#pragma mark Data Manipulation

- (NSMutableDictionary *)sectionedPeople
{
  if (!_sectionedPeople) {
    _sectionedPeople = [[NSMutableDictionary alloc] init];
//    for (char a = 'A'; a <= 'Z'; a++)
//    {
//      _sectionedPeople[[NSString stringWithFormat:@"%c", a]] = @[];
//    }
  }

  return _sectionedPeople;
}

- (void)sectionPeople
{
  [self.sectionedPeople removeAllObjects];
  bool start = YES;
  NSString *lastLetter;
  NSMutableArray *letterArray = [[NSMutableArray alloc] init];
  for (NSDictionary *person in self.people) {
    
    NSString *fullName = [person objectForKey:@"name"];
    __block NSString *lastName = nil;
    [fullName enumerateSubstringsInRange:NSMakeRange(0, [fullName length])
                                 options:NSStringEnumerationByWords| NSStringEnumerationReverse
                              usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
      lastName = substring;
      *stop = YES;
    }];
    if ([[lastName substringToIndex:1] isEqualToString:lastLetter]) {
      [letterArray addObject:@{ @"name": fullName, @"link": [person objectForKey:@"link"] }];
    } else {
      if (!start) {
        [self.sectionedPeople setObject:[letterArray copy] forKey:lastLetter];
        [letterArray removeAllObjects];
      }
      
      lastLetter = [lastName substringToIndex:1];
       [letterArray addObject:@{ @"name": fullName, @"link": [person objectForKey:@"link"] }];
    }
    start = NO;
  }
  [self.sectionedPeople setObject:[letterArray copy] forKey:lastLetter];
  self.firstLetters = [[self.sectionedPeople allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

  
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
      [self performSegueWithIdentifier:@"People Detail Segue" sender:self];
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
  return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
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
    __block NSString *lastName = nil;
    [fullName enumerateSubstringsInRange:NSMakeRange(0, [fullName length])
                                 options:NSStringEnumerationByWords| NSStringEnumerationReverse
                              usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
                                lastName = substring;
                                *stop = YES;
                              }];
    
    
    NSString *urlString = [[[self.sectionedPeople objectForKey:[lastName substringToIndex:1]] objectAtIndex:indexPath.row] objectForKey:@"link"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
      
      [YPGlobalHelper hideNotificationView];
      
      NSString *responseString = operation.responseString;
      self.individualData = [YPGlobalHelper getInformationForPerson:responseString];
      YPDirectoryDetailViewController *pdvc = (YPDirectoryDetailViewController *)[segue destinationViewController];
      pdvc.data = self.individualData;
      [pdvc viewDidLoad];
      [pdvc.tableView reloadData];
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                      message:@"YaleMobile is unable to reach Yale Phonebook server. Please check your Internet connection and try again."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }];
    
    [YPGlobalHelper showNotificationInViewController:self
                                             message:@"Loading..."
                                               style:JGProgressHUDStyleDark];
    
    [operation start];
  }
}




@end
