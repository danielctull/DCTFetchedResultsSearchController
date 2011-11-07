//
//  DCTFetchedResultsSearchControllerTestViewController.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 28.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchControllerTestViewController.h"
#import "Person.h"

@interface DCTFetchedResultsSearchControllerTestViewController ()
- (NSManagedObjectContext *)managedObjectContext;
@end

@implementation DCTFetchedResultsSearchControllerTestViewController {
	FRCFetchedResultsTableViewDataSource *allPersonsDataSource;
}

@synthesize fetchedResultsSearchController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc]];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	
	allPersonsDataSource = [[FRCFetchedResultsTableViewDataSource alloc] init];
	allPersonsDataSource.managedObjectContext = moc;
	allPersonsDataSource.fetchRequest = request;
	self.tableView.dataSource = allPersonsDataSource;
	
	
	self.fetchedResultsSearchController.managedObjectContext = moc;
	
	self.fetchedResultsSearchController.searchBlock = ^ NSFetchRequest * (NSString *searchString, NSArray *scopeOptions, NSInteger selectedOption) {
		
		NSFetchRequest *fr = [[NSFetchRequest alloc] init];
		
		[fr setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc]];
		
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
		[fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSArray *searchStrings = [searchString componentsSeparatedByString:@" "];
		
		NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:[searchStrings count]];
		
		for (NSString *s in searchStrings)
			if (![s isEqualToString:@""])
				[predicates addObject:[NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR surname contains[cd] %@", s, s]];
		
		NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
		
		[fr setPredicate:predicate];
		
		return fr;
	};
}

- (NSManagedObjectContext *)managedObjectContext {
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SampleCoreData" 
											  withExtension:@"momd"];
	
	NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	NSString *defaultStorePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SampleCoreData"
																				  ofType:@"sqlite"];
	
	NSString *storePath = [applicationDocumentsDirectory stringByAppendingPathComponent: @"SampleCoreData.sqlite"];
	
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
		if ([[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:storePath error:&error])
			NSLog(@"Copied starting data to %@", storePath);
		else 
			NSLog(@"Error copying default DB to %@ (%@)", storePath, error);
	}
	
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil
															URL:storeURL
														options:options
														  error:&error]) {
		
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
	
	return managedObjectContext;
}


@end
