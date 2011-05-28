//
//  DCTFetchedResultsSearchController.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchController.h"

@interface DCTFetchedResultsSearchController ()

- (void)dctInternal_setupFetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
											 managedObjectContext:(NSManagedObjectContext *)moc;

- (NSFetchRequest *)dctInternal_fetchRequestForSearchString:(NSString *)searchString
												scopeOtions:(NSArray *)scopeOptions
											 selectedOption:(NSInteger)selectedOption;

@end

@implementation DCTFetchedResultsSearchController

@synthesize searchDisplayController;
@synthesize managedObjectContext;
@synthesize searchBlock;
@synthesize selectionBlock;
@synthesize accessorySelectionBlock;
@synthesize cellBlock;
@synthesize fetchedResultsController;
@synthesize delegate;

#pragma mark - NSObject

- (void)dealloc {
	delegate = nil;
	[fetchedResultsController release], fetchedResultsController = nil;
	[searchDisplayController release], searchDisplayController = nil;
	[managedObjectContext release], managedObjectContext = nil;
	[searchBlock release], searchBlock = nil;
	[selectionBlock release], selectionBlock = nil;
	[accessorySelectionBlock release], accessorySelectionBlock = nil;
	[cellBlock release], cellBlock = nil;
	[super dealloc];
}

#pragma mark - DCTFetchedResultsSearchController

- (void)setSearchDisplayController:(UISearchDisplayController *)sdc {
	
	if ([searchDisplayController isEqual:sdc]) return;
	
	[searchDisplayController release];
	searchDisplayController = [sdc retain];
	
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsDataSource = self;
	searchDisplayController.searchResultsDelegate = self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)moc {
	
	if ([moc isEqual:managedObjectContext]) return;
	
	[managedObjectContext release];
	managedObjectContext = [moc retain];
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:self.fetchedResultsController.fetchRequest
											   managedObjectContext:self.managedObjectContext];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:tableView:cellForRowAtIndexPath:withObject:)])
		return [self.delegate fetchedResultsSearchController:self tableView:tableView cellForRowAtIndexPath:indexPath withObject:object];
	
	if (self.cellBlock != nil) 
		return self.cellBlock(tableView, indexPath, object);
	
	return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:tableView:didSelectRowAtIndexPath:withObject:)])
		[self.delegate fetchedResultsSearchController:self tableView:tableView didSelectRowAtIndexPath:indexPath withObject:object];
	
	if (self.selectionBlock != nil) self.selectionBlock(tableView, indexPath, object);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:tableView:accessoryButtonTappedForRowWithIndexPath:withObject:)])
		[self.delegate fetchedResultsSearchController:self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath withObject:object];
	
	if (self.accessorySelectionBlock != nil) self.accessorySelectionBlock(tableView, indexPath, object);
}

#pragma mark - UISearchDisplayControllerDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {	
	
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), searchString);
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	NSInteger selectedOption = searchBar.selectedScopeButtonIndex;
	
	NSFetchRequest *fr = [self dctInternal_fetchRequestForSearchString:searchString
														   scopeOtions:scopeOptions
														selectedOption:selectedOption];
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:fr managedObjectContext:self.managedObjectContext];
	
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)selectedOption {
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSString *searchString = searchBar.text;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	
	NSFetchRequest *fr = [self dctInternal_fetchRequestForSearchString:searchString
														   scopeOtions:scopeOptions
														selectedOption:selectedOption];
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:fr managedObjectContext:self.managedObjectContext];
	
	
	return YES;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

/*
 These methods are taken straight from Apple's documentation on NSFetchedResultsController.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.searchDisplayController.searchResultsTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	UITableView *tableView = self.searchDisplayController.searchResultsTableView;
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
					 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.searchDisplayController.searchResultsTableView endUpdates];
}


#pragma mark - Internal

- (NSFetchRequest *)dctInternal_fetchRequestForSearchString:(NSString *)searchString
												scopeOtions:(NSArray *)scopeOptions
											 selectedOption:(NSInteger)selectedOption {
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:fetchRequestForSearchString:scopeOtions:selectedOption:)])
		return [self.delegate fetchedResultsSearchController:self
								 fetchRequestForSearchString:searchString
												 scopeOtions:scopeOptions
											  selectedOption:selectedOption];
		
	if (self.searchBlock != nil) 
		return self.searchBlock(searchString, scopeOptions, selectedOption);
	
	return nil;
}

- (void)dctInternal_setupFetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
											 managedObjectContext:(NSManagedObjectContext *)moc {
	
	if (fetchRequest == nil) return;
	
	if (moc == nil) return;
	
	if ([fetchRequest isEqual:self.fetchedResultsController.fetchRequest] &&
		[moc isEqual:self.fetchedResultsController.managedObjectContext]) return;
	
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																   managedObjectContext:moc
																	 sectionNameKeyPath:nil
																			  cacheName:nil];
	fetchedResultsController.delegate = self;
	[fetchedResultsController performFetch:nil];
	//[self.searchDisplayController.searchResultsTableView reloadData];
}

@end
