//
//  DCTFetchedResultsSearchController.h
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef NSFetchRequest *(^DCTFetchedResultsSearchControllerSearchBlock) (NSString *searchString, NSArray *scopeOptions, NSInteger selectedOption);
typedef void (^DCTFetchedResultsSearchControllerSelectionBlock) (UITableView *tableView, NSIndexPath *indexPath, id object);
typedef UITableViewCell *(^DCTFetchedResultsSearchControllerCellBlock) (UITableView *tableView, NSIndexPath *indexPath, id object);

@protocol DCTFetchedResultsSearchControllerDelegate;

@interface DCTFetchedResultsSearchController : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic, retain) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) DCTFetchedResultsSearchControllerSearchBlock searchBlock;
@property (nonatomic, copy) DCTFetchedResultsSearchControllerSelectionBlock selectionBlock;
@property (nonatomic, copy) DCTFetchedResultsSearchControllerSelectionBlock accessorySelectionBlock;
@property (nonatomic, copy) DCTFetchedResultsSearchControllerCellBlock cellBlock;

@property (nonatomic, assign) IBOutlet id<DCTFetchedResultsSearchControllerDelegate> delegate;
@end


@protocol DCTFetchedResultsSearchControllerDelegate <NSObject>
@optional
- (NSFetchRequest *)fetchedResultsSearchController:(DCTFetchedResultsSearchController *)fetchedResultsSearchController
					   fetchRequestForSearchString:(NSString *)searchString
									   scopeOtions:(NSArray *)scopeOptions
									selectedOption:(NSInteger)selectedOption;

- (UITableViewCell *)fetchedResultsSearchController:(DCTFetchedResultsSearchController *)fetchedResultsSearchController
										  tableView:(UITableView *)tableView
							  cellForRowAtIndexPath:(NSIndexPath *)indexPath
										 withObject:(id)object;

- (void)fetchedResultsSearchController:(DCTFetchedResultsSearchController *)fetchedResultsSearchController
							 tableView:(UITableView *)tableView
			   didSelectRowAtIndexPath:(NSIndexPath *)indexPath
							withObject:(id)object;

- (void)fetchedResultsSearchController:(DCTFetchedResultsSearchController *)fetchedResultsSearchController
							 tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
							withObject:(id)object;

@end
