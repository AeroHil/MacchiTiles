//
//  NewGameController.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/23/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@class NewGamePakGamesController;

@interface NewGameController : SecondLevelViewController 
	<UITableViewDelegate, UITableViewDataSource> {
		
		NSMutableArray	*list;						// array of gamepak files
		NewGamePakGamesController *childController;	// controller for next view
}
@property (nonatomic, retain) NSMutableArray *list;

- (NSMutableArray *)listOfGameFiles;	// function to return an array of game files from directory
@end
