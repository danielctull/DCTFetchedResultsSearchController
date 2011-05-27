//
//  DCTFetchedResultsSearchController.h
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef NSFetchRequest *(^DCTFetchedResultsSearchControllerSearchBlock) (NSString *searchString, NSArray *scopeOptions, NSInteger selectedOption);
typedef void (^DCTFetchedResultsSearchControllerSelectionBlock) (UITableView *tableView, NSIndexPath *indexPath, id object);
typedef UITableViewCell *(^DCTFetchedResultsSearchControllerCellBlock) (UITableView *tableView, NSIndexPath *indexPath, id object);

@interface DCTFetchedResultsSearchController : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;

@property (nonatomic, retain) DCTFetchedResultsSearchControllerSearchBlock searchBlock;
@property (nonatomic, retain) DCTFetchedResultsSearchControllerSelectionBlock selectionBlock, accessorySelectionBlock;
@property (nonatomic, retain) DCTFetchedResultsSearchControllerCellBlock cellBlock;
@end
