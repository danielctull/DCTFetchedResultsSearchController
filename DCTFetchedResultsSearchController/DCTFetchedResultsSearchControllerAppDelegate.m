//
//  DCTFetchedResultsSearchControllerAppDelegate.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchControllerAppDelegate.h"

@interface DCTFetchedResultsSearchControllerAppDelegate ()
- (NSManagedObjectContext *)managedObjectContext;
@end

@implementation DCTFetchedResultsSearchControllerAppDelegate

@synthesize window;

- (void)dealloc {
	[window release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
