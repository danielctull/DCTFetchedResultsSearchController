//
//  DCTFetchedResultsSearchController.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchController.h"

@interface DCTFetchedResultsSearchController () {
	NSFetchedResultsController *fetchedResultsController;
}
@end

@implementation DCTFetchedResultsSearchController

@synthesize searchDisplayController;
@synthesize managedObjectContext;
@synthesize searchBlock;
@synthesize selectionBlock;
@synthesize accessorySelectionBlock;
@synthesize cellBlock;

#pragma mark - NSObject

- (void)dealloc {
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

- (void)setFetchRequest:(NSFetchRequest *)fr {
	
	if ([fr isEqual:self.fetchRequest]) return;
	
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fr
																			managedObjectContext:self.managedObjectContext
																	 sectionNameKeyPath:nil
																			  cacheName:nil];
	fetchedResultsController.delegate = self;
	[self.searchDisplayController.searchResultsTableView reloadData];
	[fetchedResultsController performFetch:nil];
}

- (NSFetchRequest *)fetchRequest {
	return fetchedResultsController.fetchRequest;
}

- (void)setSearchDisplayController:(UISearchDisplayController *)sdc {
	
	if ([searchDisplayController isEqual:sdc]) return;
	
	[searchDisplayController release];
	searchDisplayController = [sdc retain];
	
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsTableView.delegate = self;
	searchDisplayController.searchResultsTableView.dataSource = self;
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
	return self.cellBlock(tableView, indexPath, object);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	self.selectionBlock(tableView, indexPath, object);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	self.accessorySelectionBlock(tableView, indexPath, object);
}

#pragma mark - UISearchDisplayControllerDelegate methods


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {	
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	NSInteger selectedOption = searchBar.selectedScopeButtonIndex;
	
	self.fetchRequest = self.searchBlock(searchString, scopeOptions, selectedOption);
	
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)selectedOption {
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSString *searchString = searchBar.text;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	
	self.fetchRequest = self.searchBlock(searchString, scopeOptions, selectedOption);
	
	return NO;
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

@end
