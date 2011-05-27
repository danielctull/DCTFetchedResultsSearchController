//
//  DCTFetchedResultsSearchController.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchController.h"

@interface DCTFetchedResultsSearchController ()
- (void)dctInternal_setupFetchedResultsController;
@end

@implementation DCTFetchedResultsSearchController

@synthesize searchDisplayController;
@synthesize managedObjectContext;
@synthesize searchBlock;
@synthesize selectionBlock;
@synthesize accessorySelectionBlock;
@synthesize cellBlock;
@synthesize fetchedResultsController;
@synthesize fetchRequest;
@synthesize delegate;

#pragma mark - NSObject

- (void)dealloc {
	delegate = nil;
	[fetchRequest release], fetchRequest = nil;
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
	
	if ([fr isEqual:fetchRequest]) return;
	
	[fetchRequest release];
	fetchRequest = [fr retain];
	
	[self dctInternal_setupFetchedResultsController];
}

- (void)setSearchDisplayController:(UISearchDisplayController *)sdc {
	
	if ([searchDisplayController isEqual:sdc]) return;
	
	[searchDisplayController release];
	searchDisplayController = [sdc retain];
	
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsTableView.delegate = self;
	searchDisplayController.searchResultsTableView.dataSource = self;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)moc {
	
	if ([moc isEqual:managedObjectContext]) return;
	
	[managedObjectContext release];
	managedObjectContext = [moc retain];
	
	[self dctInternal_setupFetchedResultsController];
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
	
	return self.cellBlock(tableView, indexPath, object);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:tableView:didSelectRowAtIndexPath:withObject:)])
		[self.delegate fetchedResultsSearchController:self tableView:tableView didSelectRowAtIndexPath:indexPath withObject:object];
	
	self.selectionBlock(tableView, indexPath, object);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	id object = [fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:tableView:accessoryButtonTappedForRowWithIndexPath:withObject:)])
		[self.delegate fetchedResultsSearchController:self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath withObject:object];
	
	self.accessorySelectionBlock(tableView, indexPath, object);
}

#pragma mark - UISearchDisplayControllerDelegate methods


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {	
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	NSInteger selectedOption = searchBar.selectedScopeButtonIndex;
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:fetchRequestForSearchString:withScopeOtions:selectedOption:)]) {
		
		self.fetchRequest = [self.delegate fetchedResultsSearchController:self
											  fetchRequestForSearchString:searchString
														  withScopeOtions:scopeOptions
														   selectedOption:selectedOption];
	} else {
		self.fetchRequest = self.searchBlock(searchString, scopeOptions, selectedOption);
	}
	
	return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)selectedOption {
	
	UISearchBar *searchBar = self.searchDisplayController.searchBar;
	NSString *searchString = searchBar.text;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	
	if ([self.delegate respondsToSelector:@selector(fetchedResultsSearchController:fetchRequestForSearchString:withScopeOtions:selectedOption:)]) {
		
		self.fetchRequest = [self.delegate fetchedResultsSearchController:self
											  fetchRequestForSearchString:searchString
														  withScopeOtions:scopeOptions
														   selectedOption:selectedOption];
	} else {
		self.fetchRequest = self.searchBlock(searchString, scopeOptions, selectedOption);
	}
	
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

- (void)dctInternal_setupFetchedResultsController {
	
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
																   managedObjectContext:self.managedObjectContext
																	 sectionNameKeyPath:nil
																			  cacheName:nil];
	fetchedResultsController.delegate = self;
	[self.searchDisplayController.searchResultsTableView reloadData];
	[fetchedResultsController performFetch:nil];
}

@end
