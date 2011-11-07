//
//  DCTFetchedResultsSearchControllerAppDelegate.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchControllerAppDelegate.h"

@implementation DCTFetchedResultsSearchControllerAppDelegate

@synthesize window;

- (void)dealloc {
	[window release], window = nil;
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self.window makeKeyAndVisible];
    return YES;
}



@end
