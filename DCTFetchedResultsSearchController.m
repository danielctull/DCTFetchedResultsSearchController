/*
 DCTFetchedResultsSearchController.m
 DCTFetchedResultsSearchController
 
 Created by Daniel Tull on 27.05.2011.
 
 
 
 Copyright (c) 2011 Daniel Tull. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCTFetchedResultsSearchController.h"
#import "DCTFetchedResultsTableViewDataSource.h"
#import "DCTTableViewCell.h"

@interface DCTFetchedResultsSearchController ()


- (void)sharedInit;
- (void)dctInternal_setupFetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fetchRequest
											 managedObjectContext:(NSManagedObjectContext *)moc;

- (NSFetchRequest *)dctInternal_fetchRequestForSearchString:(NSString *)searchString
												scopeOtions:(NSArray *)scopeOptions
											 selectedOption:(NSInteger)selectedOption;

@end

@implementation DCTFetchedResultsSearchController {
	__strong NSFetchRequest *fetchRequest;
}

@synthesize searchDisplayController;
@synthesize searchBlock;
@synthesize delegate;
@synthesize fetchedResultsTableViewDataSource;
@synthesize managedObjectContext;

- (id)init {
	
	if (!(self = [super init])) return nil;
	
	[self sharedInit];
	
	return self;
}

- (void)awakeFromNib {
	[self sharedInit];
}

- (void)sharedInit {
	if (!fetchedResultsTableViewDataSource) fetchedResultsTableViewDataSource = [[DCTFetchedResultsTableViewDataSource alloc] init];
}

#pragma mark - DCTFetchedResultsSearchController

- (void)setSearchDisplayController:(UISearchDisplayController *)sdc {
	
	if ([searchDisplayController isEqual:sdc]) return;
	
	searchDisplayController = sdc;
	
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsDataSource = fetchedResultsTableViewDataSource;
	fetchedResultsTableViewDataSource.tableView = searchDisplayController.searchResultsTableView;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)moc {
	
	if ([moc isEqual:managedObjectContext]) return;
	
	managedObjectContext = moc;
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:fetchRequest
											   managedObjectContext:self.managedObjectContext];
}

#pragma mark - UISearchDisplayControllerDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {	
	
	UISearchBar *searchBar = controller.searchBar;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	NSInteger selectedOption = searchBar.selectedScopeButtonIndex;
	
	NSFetchRequest *fr = [self dctInternal_fetchRequestForSearchString:searchString
														   scopeOtions:scopeOptions
														selectedOption:selectedOption];
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:fr managedObjectContext:self.managedObjectContext];
	
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)selectedOption {
	
	UISearchBar *searchBar = controller.searchBar;
	NSString *searchString = searchBar.text;
	NSArray *scopeOptions = searchBar.scopeButtonTitles;
	
	NSFetchRequest *fr = [self dctInternal_fetchRequestForSearchString:searchString
														   scopeOtions:scopeOptions
														selectedOption:selectedOption];
	
	[self dctInternal_setupFetchedResultsControllerWithFetchRequest:fr managedObjectContext:self.managedObjectContext];
	
	
	return YES;
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

- (void)dctInternal_setupFetchedResultsControllerWithFetchRequest:(NSFetchRequest *)fr
											 managedObjectContext:(NSManagedObjectContext *)moc {
	
	if (fr == nil) return;
	
	if (moc == nil) return;
	
	if ([fr isEqual:fetchRequest] &&
		[moc isEqual:fetchedResultsTableViewDataSource.fetchedResultsController.managedObjectContext]) return;
	
	fetchedResultsTableViewDataSource.tableView = searchDisplayController.searchResultsTableView;
	fetchedResultsTableViewDataSource.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fr
																									 managedObjectContext:moc
																									   sectionNameKeyPath:nil
																												cacheName:nil];
}

@end
