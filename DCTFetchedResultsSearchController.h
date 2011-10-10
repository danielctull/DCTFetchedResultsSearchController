/*
 DCTFetchedResultsSearchController.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FRCFetchedResultsTableViewDataSource.h"

typedef NSFetchRequest *(^DCTFetchedResultsSearchControllerSearchBlock) (NSString *searchString, NSArray *scopeOptions, NSInteger selectedOption);

@protocol DCTFetchedResultsSearchControllerDelegate;

@interface DCTFetchedResultsSearchController : NSObject <UISearchDisplayDelegate>

@property (nonatomic, strong) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong, readonly) FRCFetchedResultsTableViewDataSource *fetchedResultsTableViewDataSource;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) DCTFetchedResultsSearchControllerSearchBlock searchBlock;

@property (nonatomic, weak) IBOutlet id<DCTFetchedResultsSearchControllerDelegate> delegate;

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
@end
