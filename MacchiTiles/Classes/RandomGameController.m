//
//  RandomGameController.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/26/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "RandomGameController.h"
#import "MacchiTilesAppDelegate.h"
#import "ResetGameController.h"

@implementation RandomGameController
@synthesize game;
@synthesize gamepakNum;
@synthesize gameNum;

- (id)init {
	if (self = [super init]){
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[self getRandomGame];
	
	if (childController == nil)
		childController = [[ResetGameController alloc] init];
	
	// setup the game controller
	childController.title = @"Random Game";
	childController.game = self.game;
	childController.gamepakNum = self.gamepakNum;
	childController.gameNum = self.gameNum;

	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//	[delegate.navController setNavigationBarHidden:YES animated:NO];
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
#pragma mark Random Methods
- (NSInteger)getNumberOfGamePaks
{
	NSString *pname;
	NSString *lvlPath = [[NSBundle mainBundle] resourcePath];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:lvlPath];
	NSInteger count = 0;
	// count the number of gamepak files in the directory
	while (pname = [direnum nextObject]) {
		if ([[pname pathExtension] isEqualToString:@"lvl"]) {
			count++;
		}
	}
	
	[pname release];
	
	return count;
}

- (NSArray *)getGamesInGamePak:(int)gamePak
{
	NSArray *array = [[[NSArray alloc] init] autorelease];
	NSString *filename = [[NSString alloc] initWithFormat:@"GamePak%d", gamePak];
	NSString *lvlPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"lvl"];
	NSString *dataInMem = [[NSString alloc] initWithContentsOfFile:lvlPath];
	
	if (dataInMem != nil)
	{
		array = [dataInMem componentsSeparatedByString:@"\n"];
		//self.currentGame = [[self.allGames objectAtIndex:0] componentsSeparatedByString:@" "];
	}
	
	[filename release];
	[dataInMem release];
	
	return array;
}

- (void)getRandomGame
{
	// get a random game pak file
	NSInteger numGamePak = [self getNumberOfGamePaks];
	int randomGamePak = 0;
	if (numGamePak > 1)
		randomGamePak = arc4random() % numGamePak;
	
	NSArray *allGamesInPak = [self getGamesInGamePak:randomGamePak+1];
	
	// get a random game from game pak
	NSInteger numGamesInPak = [allGamesInPak count];
	int randomGameInPak = 0;
	if (numGamesInPak > 1)
		randomGameInPak = arc4random() % numGamesInPak;
	
	self.game = [[allGamesInPak objectAtIndex:randomGameInPak] componentsSeparatedByString:@" "];
	
	gamepakNum = randomGamePak+1;
	gameNum = randomGameInPak+1;
	
//	[allGamesInPak release];
}

@end
