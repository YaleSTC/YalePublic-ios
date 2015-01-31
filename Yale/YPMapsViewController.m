//
//  YPMapViewController.m
//  Yale
//
//  Created by Minh Tri Pham on 1/7/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import "YPMapsViewController.h"

@interface YPMapsViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserTrackingBarButtonItem *trackingItem;
@property (strong, nonatomic) NSDictionary *buildings;

@end

@implementation YPMapsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.trackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
  
  [self.toolbar setItems:@[self.trackingItem]];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  
  self.tableView.opaque = NO;
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"json"];
  NSLog(@"FILEPATH IS");
  NSLog(filePath);
  NSData* data = [NSData dataWithContentsOfFile:filePath];
  NSLog(@"%@", data);
  NSError* error = nil;
  self.buildings = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers error:&error];
  
  NSLog(@"%@", self.buildings);
}

- (void)viewWillAppear:(BOOL)animated {
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(41.3111, -72.9267);
  MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
  [self.mapView setRegion:MKCoordinateRegionMake(location, span)];
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
 
  NSLog(@"SEARCH BAR did begin editing");
  
}

//Method to handle the UISearchBar "Search",
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
  //Perform the JSON query.
  
  
  
//  [self searchCoordinatesForAddress:[searchBar text]];
  NSLog(@"Detected search");
  //Hide the keyboard.
 // [searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"buildingCell"];
  cell.textLabel.text = @"asdf";
  return cell;
  
  
}
@end
