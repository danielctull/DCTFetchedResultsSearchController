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

@implementation DCTFetchedResultsSearchControllerTestViewController

@synthesize fetchedResultsSearchController;

- (void)dealloc {
	[fetchedResultsSearchController release], fetchedResultsSearchController = nil;
    [super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc]];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	fetchedPersons = [[moc executeFetchRequest:request error:NULL] copy];
	
	[request release];
	
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
		
		return [fr autorelease];
	};
	
	
	
	
	self.fetchedResultsSearchController.cellBlock = ^ UITableViewCell * (UITableView *tv, NSIndexPath *indexPath, id object) {
		
		UITableViewCell *cell = [[tv dequeueReusableCellWithIdentifier:@"cell"] retain];
		
		if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
														reuseIdentifier:@"cell"];
		
		Person *person = (Person *)object;
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.surname];
		
		return [cell autorelease];
	};	
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [fetchedPersons count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id object = [fetchedPersons objectAtIndex:indexPath.row];
	return self.fetchedResultsSearchController.cellBlock(tv, indexPath, object);
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
	
	[managedObjectModel release];
	
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
	[persistentStoreCoordinator release];
	
	return [managedObjectContext autorelease];
}


@end
