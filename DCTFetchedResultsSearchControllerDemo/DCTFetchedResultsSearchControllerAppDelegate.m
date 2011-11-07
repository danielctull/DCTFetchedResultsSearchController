//
//  DCTFetchedResultsSearchControllerAppDelegate.m
//  DCTFetchedResultsSearchController
//
//  Created by Daniel Tull on 27.05.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import "DCTFetchedResultsSearchControllerAppDelegate.h"
#import "DCTFetchedResultsSearchControllerTestViewController.h"

@implementation DCTFetchedResultsSearchControllerAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	DCTFetchedResultsSearchControllerTestViewController *vc = [[DCTFetchedResultsSearchControllerTestViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	
	
	self.window.rootViewController = nav;
	[self.window makeKeyAndVisible];
    return YES;
}



@end
