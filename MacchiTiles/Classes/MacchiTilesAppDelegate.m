//
//  MacchiTilesAppDelegate.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/18/09.
//  Copyright aeromedia studios 2009. All rights reserved.
//

#import "MacchiTilesAppDelegate.h"

@implementation MacchiTilesAppDelegate

@synthesize window;
@synthesize navController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
	[window addSubview:navController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[navController release];
    [window release];
    [super dealloc];
}


@end
