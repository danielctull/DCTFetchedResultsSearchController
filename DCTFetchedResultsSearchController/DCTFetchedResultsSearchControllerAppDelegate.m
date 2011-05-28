//
//  DCTFetchedResultsSearchControllerAppDelegate.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchControllerAppDelegate.h"
#import "Person.h"

@interface DCTFetchedResultsSearchControllerAppDelegate ()
- (NSManagedObjectContext *)managedObjectContext;
@end

@implementation DCTFetchedResultsSearchControllerAppDelegate

@synthesize window;
@synthesize fetchedResultsSearchController;
@synthesize tableView;
@synthesize searchBar;

- (void)dealloc {
	[tableView release], tableView = nil;
	[searchBar release], searchBar = nil;
	[fetchedResultsSearchController release], fetchedResultsSearchController = nil;
	[window release], window = nil;
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	self.fetchedResultsSearchController.managedObjectContext = moc;
	
	self.fetchedResultsSearchController.searchBlock = ^ NSFetchRequest * (NSString *searchString, NSArray *scopeOptions, NSInteger selectedOption) {
			
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		
		[request setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc]];
		
		
		
		NSArray *searchStrings = [searchString componentsSeparatedByString:@" "];
		
		NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:[searchStrings count]];
		
		for (NSString *s in searchStrings)
			if (![s isEqualToString:@""])
				[predicates addObject:[NSPredicate predicateWithFormat:@"firstName contains[cd] %@ OR surname contains[cd] %@", s, s]];
		
		NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
		
		[request setPredicate:predicate];
		
		
		
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		return [request autorelease];
	};
	
	self.fetchedResultsSearchController.cellBlock = ^ UITableViewCell * (UITableView *tv, NSIndexPath *indexPath, id object) {
		
		UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"cell"];
		
		if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
														reuseIdentifier:@"cell"] autorelease];
		
		Person *person = (Person *)object;
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.surname];
		
		return cell;
		
	};
	
	self.tableView.tableHeaderView = self.searchBar;
	[self.window makeKeyAndVisible];
    return YES;
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
