//
//  RandomGameController.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/26/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@class ResetGameController;

@interface RandomGameController : SecondLevelViewController {
	
	NSArray *game;							// a random game in the gamepak
	ResetGameController *childController;			// controller for the next view
	
	NSInteger gamepakNum, gameNum;
}

@property (nonatomic, retain) NSArray *game;
@property NSInteger gamepakNum;
@property NSInteger gameNum;

- (NSInteger)getNumberOfGamePaks;			 // function that returns the number of gamepak files
- (NSArray *)getGamesInGamePak:(int)gamePak; // function that return the number of games in file
- (void)getRandomGame;						 // function that returns a random game

@end
