//
//  NewGamePakGamesController.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/25/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@class ResetGameController;

@interface NewGamePakGamesController : SecondLevelViewController 
	<UITableViewDelegate, UITableViewDataSource> {
		
		NSMutableDictionary *savedData;
	
		NSArray *allGames;				// array of all games in gamepak
		NSIndexPath *lastIndexPath;		// index path for the previous row
		NSInteger selectedRow;			// integer for the selected row
		ResetGameController *childController;	// controller for the next view
		
		NSInteger gamepakNum;
		NSInteger graphicsMode;
}
@property (nonatomic, retain) NSMutableDictionary *savedData;
@property (nonatomic, retain) NSArray *allGames;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property NSInteger selectedRow;
@property NSInteger gamepakNum;
@property NSInteger graphicsMode;

- (IBAction)save:(id)sender;			// action for the 'ok' button
- (void)readSavedDataFile;				// function to read all the completed games
- (NSArray *)listOfGamesInGamePak;		// function that returns all the games in gamepak
- (NSInteger)readSettings;				// function to read the settings
@end
