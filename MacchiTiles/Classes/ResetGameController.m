//
//  ResetGameController.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 6/24/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "ResetGameController.h"
#import "MacchiTilesAppDelegate.h"
#import "BoardViewDetail.h"
#import "BoardViewDetail_BigTiles.h"

@implementation ResetGameController
@synthesize game;
@synthesize gamepakNum;
@synthesize gameNum;

- (id)init {
	if (self = [super init]){
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	// setup the game controller
	if ([self.game count] == 48) {
		childController = [[BoardViewDetail_BigTiles alloc] initWithNibName:@"BoardViewDetail_BigTiles" bundle:nil];
		
		childController.title = @"Big Tiles Game";
		childController.currentGame = self.game;
		childController.gamepakNum = self.gamepakNum;
		childController.gameNum = self.gameNum;
		childController.graphicsMode = [self readSettings];
	}
	else if ([self.game count] == 96) {
		childController = [[BoardViewDetail alloc] initWithNibName:@"BoardViewDetail" bundle:nil];
		
		childController.title = @"Small Tiles Game";
		childController.currentGame = self.game;
		childController.gamepakNum = self.gamepakNum;
		childController.gameNum = self.gameNum;
		childController.graphicsMode = [self readSettings];
	}
	
	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController setNavigationBarHidden:YES animated:NO];
	[delegate.navController pushViewController:childController animated:YES];
	
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[childController release];
	[game release];
	[super dealloc];
}

#pragma mark -
#pragma mark I/O Methods
- (NSInteger)readSettings
{
	NSInteger retval = -1;
	// get the path to the settings file
	NSString *filePath = [BoardViewDetail dataFilePath:SETTINGS_FILE];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		// if the file exists check the settings tag and get the value
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:filePath];
		if ([settings objectForKey:GRAPHICS_TAG] != nil) {
			retval = [[settings objectForKey:GRAPHICS_TAG] intValue];
		}
	}
	else
		retval = 0;
	
	return retval;
}

@end
