//
//  YPMapViewController.h
//  Yale
//
//  Created by Minh Tri Pham on 1/7/15.
//  Copyright (c) 2015 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@import CoreLocation;

@interface YPMapsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;


@end
