//
//  DCTFetchedResultsSearchControllerAppDelegate.h
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTFetchedResultsSearchController.h"

@interface DCTFetchedResultsSearchControllerAppDelegate : NSObject <UIApplicationDelegate, DCTFetchedResultsSearchControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DCTFetchedResultsSearchController *fetchedResultsSearchController;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
