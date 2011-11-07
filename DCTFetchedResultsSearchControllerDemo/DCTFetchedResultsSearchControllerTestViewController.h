//
//  DCTFetchedResultsSearchControllerTestViewController.h
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 28.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTFetchedResultsSearchController.h"

@interface DCTFetchedResultsSearchControllerTestViewController : UIViewController <UITableViewDataSource> {
	NSArray *fetchedPersons;
}

@property (nonatomic, retain) IBOutlet DCTFetchedResultsSearchController *fetchedResultsSearchController;

@end
