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
#import <GAI.h>
#import <GAIFields.h>
#import <GAIDictionaryBuilder.h>
#import "JSONLoader.h"

@interface YPMapsViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, JSONLoaderDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) YPResultsTableViewController *resultsTableController; 
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *buildings;
@property (nonatomic, strong) NSArray *buildingsArray;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserTrackingBarButtonItem *trackingItem;
@property (nonatomic, strong) MKPointAnnotation *currentAnnotation;

@property (strong, nonatomic) JSONLoader *buildingLoader;

@end

@implementation YPMapsViewController

- (void)jsonLoaderNamed:(NSString *)name updatedPlist:(NSDictionary *)plist
{
  self.buildings = [self.class parseJSON:plist];
  self.buildingsArray = [[self.buildings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSLog(@"%@", self.buildingsArray);
  [self.tableView reloadData];
}

#define BUILDINGS_URL @"https://gw.its.yale.edu/soa-gateway/buildings/feed?type=json&apikey=l7xxe29bf8a290714cb1a5d05460001965f6"

- (JSONLoader *)buildingLoader
{
  if (!_buildingLoader)
  {
    _buildingLoader = [[JSONLoader alloc] initWithName:@"Buildings File" defaultName:@"buildingdata" url:BUILDINGS_URL delegate:self];
  }
  return _buildingLoader;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //Google Analytics
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName
         value:@"Maps VC"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

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

+ (NSString *)fixName:(NSString *)name
{
  
  name = [name stringByReplacingOccurrencesOfString:@"HLH" withString:@"Hillhouse "];
  name = [name stringByReplacingOccurrencesOfString:@"BLDG" withString:@"Building"];
  name = [name stringByReplacingOccurrencesOfString:@" CTR" withString:@" Center "];
  name = [name stringByReplacingOccurrencesOfString:@"ENVIRONMTL" withString:@"Environmental"];
  name = [name stringByReplacingOccurrencesOfString:@"CEN " withString:@"Central "];
  name = [name stringByReplacingOccurrencesOfString:@"," withString:@", "];
  name = [name stringByReplacingOccurrencesOfString:@" ST," withString:@" Street,"];
  name = [name stringByReplacingOccurrencesOfString:@" AVE," withString:@" Avenue,"];
  name = [name stringByReplacingOccurrencesOfString:@" ST " withString:@" Street "];
  name = [name stringByReplacingOccurrencesOfString:@"(DIV)" withString:@"(Divinity School)"];
  name = [name stringByReplacingOccurrencesOfString:@"AMITY AN " withString:@"Amity Animal "];
  name = [name stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
  name = [name stringByReplacingOccurrencesOfString:@"ACCEL." withString:@"Accelerator"];
  name = [name stringByReplacingOccurrencesOfString:@"APTS" withString:@"Appartments"];
  name = [name stringByReplacingOccurrencesOfString:@" LIB " withString:@" Library "];
  name = [name stringByReplacingOccurrencesOfString:@" MEM." withString:@" MEMORIAL"];
  name = [name stringByReplacingOccurrencesOfString:@" PAV." withString:@" PAVILION"];
  name = [name stringByReplacingOccurrencesOfString:@" AUD." withString:@" AUDITORIUM"];
  name = [name stringByReplacingOccurrencesOfString:@"PLT" withString:@"Plant"];
  name = [name stringByReplacingOccurrencesOfString:@"MOLEC " withString:@"MOLECULAR "];
  if ([name hasSuffix:@" MED"]) name = [name stringByReplacingOccurrencesOfString:@" MED" withString:@" MEDICINE"];
  name = [name stringByReplacingOccurrencesOfString:@"COMPLX" withString:@"COMPLEX"];
  name = [name stringByReplacingOccurrencesOfString:@"GOLF C " withString:@"GOLF COURSE "];
  name = [name stringByReplacingOccurrencesOfString:@" HSE" withString:@" House"];
  name = [name stringByReplacingOccurrencesOfString:@" STOR " withString:@" Storage "];
  name = [name stringByReplacingOccurrencesOfString:@" RES " withString:@" research "];
  name = [name stringByReplacingOccurrencesOfString:@" RES" withString:@" research"];
  name = [name stringByReplacingOccurrencesOfString:@"GOVT." withString:@"GOVERNMENT"];
  name = [name stringByReplacingOccurrencesOfString:@"BIO " withString:@"Biology "];
  name = [name stringByReplacingOccurrencesOfString:@"FLD" withString:@"Field"];
  name = [name stringByReplacingOccurrencesOfString:@"GRAD " withString:@"GRADUATE "];
  if ([name hasSuffix:@" COL"]) name = [name stringByReplacingOccurrencesOfString:@" COL" withString:@" College"];
  name = [name stringByReplacingOccurrencesOfString:@"DXWL" withString:@" Dixwell "];
  name = [name stringByReplacingOccurrencesOfString:@"UNIV " withString:@" UNIVERSITY "];
  //name = [name stringByReplacingOccurrencesOfString:@"GRAD-" withString:@"Graduate-"];
  name = [name stringByReplacingOccurrencesOfString:@"-PRO" withString:@"-Professional"];
  //name = [name stringByReplacingOccurrencesOfString:@" STA" withString:@" STADIUM"];
  if ([name hasSuffix:@"PEDIAT"]) name = [name stringByReplacingOccurrencesOfString:@"PEDIAT" withString:@"Pediatrics"];
  if ([name hasSuffix:@" FAC"]) name = [name stringByReplacingOccurrencesOfString:@" FAC" withString:@" FACTORY"];
  name = [name stringByReplacingOccurrencesOfString:@"CONF " withString:@" CONFERENCE "];
  name = [name stringByReplacingOccurrencesOfString:@"MAINT " withString:@" MAINTENANCE "];
  name = [name stringByReplacingOccurrencesOfString:@"MBG " withString:@"Marsh Botanical Garden "];
  if ([name hasSuffix:@" GAR"])name = [name stringByReplacingOccurrencesOfString:@" GAR" withString:@" GARAGE"];
  name = [name stringByReplacingOccurrencesOfString:@"SHEFFD" withString:@"SHEFFIELD"];
  name = [name stringByReplacingOccurrencesOfString:@"STERL-" withString:@"STERLING-"];
  name = [name stringByReplacingOccurrencesOfString:@"STRATHC" withString:@"Strathcona"];
  if ([name hasPrefix:@"WC "]) {
    name = [name stringByReplacingOccurrencesOfString:@"WC " withString:@"West Campus "];
  }
  while ([name rangeOfString:@"  "].length == 2) {
    name = [name stringByReplacingOccurrencesOfString:@"  " withString:@" "];
  }
  
  name = [name capitalizedString];
  return name;
}

// takes a JSON in the API-format and turns it into a format like
// {"nice building name": {"Longitude": number, "Latitude": number, "Address": address}}
+ (NSDictionary *)parseJSON:(NSDictionary *)json
{
  NSMutableDictionary *buildings = [NSMutableDictionary dictionary];
  for (NSDictionary *building in json[@"ServiceResponse"][@"Buildings"][@"Building"]) {
    NSString *buildingName = building[@"DESCRIPTION"];
    id longitude = building[@"LONGITUDE"];
    id latitude = building[@"LATITUDE"];
    NSString *niceBuildingName = [self fixName:buildingName];
    if (longitude && latitude) {
      NSString *address = [building[@"ADDR1_ALIAS"]?building[@"ADDR1_ALIAS"]:building[@"ADDRESS_1"] capitalizedString];
      if ([niceBuildingName isEqualToString:[self fixName:building[@"ADDRESS_1"]]]) {
        address = nil;
      }
      NSDictionary *info = address ? @{@"Longitude": longitude, @"Latitude":latitude, @"Address": address} : @{@"Longitude": longitude, @"Latitude":latitude};
      [buildings setObject:info forKey:[self fixName:buildingName]];
    }
  }
  return [buildings copy];
}

- (void)setupBuildings {
  self.buildings = [self.class parseJSON:self.buildingLoader.json];
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
  cell.textLabel.textColor = [YPTheme textColor];
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
  if (locationDict[@"Address"])
  {
    self.currentAnnotation.subtitle = locationDict[@"Address"];
  }
  
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
