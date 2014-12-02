//
//  YPDirectoryTableViewController.h
//  Yale
//
//  Created by Minh Tri Pham on 12/2/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPDirectoryTableViewController : UITableViewController <UIGestureRecognizerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) NSMutableDictionary *sectionedPeople;
@property (nonatomic, strong) NSArray *firstLetters;

@property (nonatomic, strong) NSMutableDictionary *individualData;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end
