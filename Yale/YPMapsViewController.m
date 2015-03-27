//
//  YPMapViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/7/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPMapsViewController.h"
#import "YPResultsTableViewController.h"
#import "YPTheme.h"

@interface YPMapsViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) YPResultsTableViewController *resultsTableController; 
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *buildings;
@property (nonatomic, strong) NSArray *buildingsArray;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserTrackingBarButtonItem *trackingItem;
@property (nonatomic, strong) MKPointAnnotation *currentAnnotation;

@end

@implementation YPMapsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.view.backgroundColor = [YPTheme navigationBarColor];
  self.navigationController.navigationBar.translucent = NO;
  self.trackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
  
  [self.toolbar setItems:@[self.trackingItem]];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self setupBuildings];
  self.extendedLayoutIncludesOpaqueBars = YES;
  self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)viewWillAppear:(BOOL)animated {
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(41.3111, -72.9267);
  MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
  [self.mapView setRegion:MKCoordinateRegionMake(location, span)];
  
  [self setupSearch];
  
  self.tableView.hidden = YES;
  self.tableView.clipsToBounds=YES;
  CGRect tableViewFrame = self.tableView.frame;
  CGRect navBarFrame = self.navigationController.navigationBar.frame;
  tableViewFrame.origin.y=navBarFrame.origin.y+navBarFrame.size.height;
  tableViewFrame.size.height = self.view.bounds.size.height - tableViewFrame.origin.y;
  self.tableView.frame = tableViewFrame;
  [super viewWillAppear:animated];
  
  //resetting this here makes it so the first cell in the table view is actually visible.
  self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)setupBuildings {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"json"];
  NSData* data = [NSData dataWithContentsOfFile:filePath];
  NSError* error = nil;
  self.buildings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
  self.buildingsArray = [[self.buildings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSLog(@"%@", self.buildingsArray);
}

- (void)setupSearch {
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.view addSubview:self.tableView];
  
  self.resultsTableController = [[YPResultsTableViewController alloc] init];
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
  self.searchController.searchResultsUpdater = self;
  self.tableView.tableHeaderView = self.searchController.searchBar;
  [self.searchController.searchBar sizeToFit];
  
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)];
  
  self.navigationItem.rightBarButtonItem = searchButton;
  
  
  // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
  self.resultsTableController.tableView.delegate = self;
  self.searchController.delegate = self;
  self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
  self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
  self.searchController.hidesNavigationBarDuringPresentation = NO;
  
  // Search is now just presenting a view controller. As such, normal view controller
  // presentation semantics apply. Namely that presentation will walk up the view controller
  // hierarchy until it finds the root view controller or one that defines a presentation context.
  //
  self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
  
}



- (void) searchButtonPressed {
  self.tableView.hidden = !self.tableView.hidden;
}

// MKMapViewDelegate Methods
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
  // Check authorization status (with class method)
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  
  // User has never been asked to decide on location authorization
  if (status == kCLAuthorizationStatusNotDetermined) {
    NSLog(@"Requesting when in use auth");
    [self.locationManager requestWhenInUseAuthorization];
  }
  // User has denied location use (either for this app or for all apps
  else if (status == kCLAuthorizationStatusDenied) {
    NSLog(@"Location services denied");
    // Alert the user and send them to the settings to turn on location
  }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusDenied)
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
  [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
  if (buttonIndex == 1)
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  if (self.mapView.userTrackingMode != MKUserTrackingModeNone && status == kCLAuthorizationStatusDenied) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permissson needed"
                                                    message:@"Please enable location services."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Settings", nil];
    [alert show];
  }
}

#pragma mark TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.buildings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"buildingCell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buildingCell"];
  }
  
  cell.textLabel.text = [self.buildingsArray objectAtIndex:indexPath.row];
  return cell;
}

#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  self.tableView.hidden = YES;
  tableView.hidden = YES;
  
  NSString *selectedBuilding = (tableView == self.tableView) ?
  self.buildingsArray[indexPath.row] : self.resultsTableController.filteredBuildings[indexPath.row];
  NSLog(@"selected; %@", selectedBuilding);
  self.searchController.active = NO;

  NSDictionary *locationDict = self.buildings[selectedBuilding];
  
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake([locationDict[@"Latitude"] floatValue], [locationDict[@"Longitude"] floatValue]);
  MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
  [self.mapView setRegion:MKCoordinateRegionMake(location, span)];
  
  if (self.currentAnnotation)
      [self.mapView removeAnnotation:self.currentAnnotation];
  self.currentAnnotation = [[MKPointAnnotation alloc] init];
  self.currentAnnotation.coordinate = location;
  self.currentAnnotation.title = selectedBuilding;
  
  
  [self.mapView addAnnotation:self.currentAnnotation];
  [self.mapView selectAnnotation:self.currentAnnotation animated:YES];
  
  
}




- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  MKPinAnnotationView *view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
  if (view == nil) {
    view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
  }
  view.animatesDrop = YES;
  view.canShowCallout = YES;

  return view;
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
  
}

- (void)willPresentSearchController:(UISearchController *)searchController {
  // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
  // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
  // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
  // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

  // update the filtered array based on the search text
  NSString *searchString = searchController.searchBar.text;
  NSMutableArray *searchResults = [NSMutableArray array];
  
  
  for (NSString *tempStr in self.buildingsArray) {
    
    if ([[tempStr lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound) {
      [searchResults addObject:tempStr];
    }
  }
  // hand over the filtered results to our search results table
  YPResultsTableViewController *tableController = (YPResultsTableViewController *)self.searchController.searchResultsController;
  tableController.filteredBuildings = searchResults;
  [tableController.tableView reloadData];
}



@end
