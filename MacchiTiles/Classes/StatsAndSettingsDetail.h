//
//  StatsAndSettingsDetail.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 6/3/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsAndSettingsDetail : UIViewController {

	IBOutlet UILabel *normalGames;
	IBOutlet UILabel *normalGamePaks;
	IBOutlet UILabel *symbolGames;
	IBOutlet UILabel *symbolGamePaks;
	
	NSDictionary *savedData;
	NSDictionary *savedDataSym;
	
	UIButton *clearButton;
	UIButton *appButton;
}

@property (nonatomic, retain) UILabel *normalGames;
@property (nonatomic, retain) UILabel *normalGamePaks;
@property (nonatomic, retain) UILabel *symbolGames;
@property (nonatomic, retain) UILabel *symbolGamePaks;
@property (nonatomic, retain) NSDictionary *savedData;
@property (nonatomic, retain) NSDictionary *savedDataSym;

- (void)readSavedDataFile;
- (void)removeSavedDataFiles;
- (NSInteger)getNumberOfGamePaks;			 // function that returns the number of gamepak files
- (NSArray *)getGamesInGamePak:(int)gamePak; // function that return the number of games in file

- (void)saveSettings:(id)sender;			 // function to write switch setting to plist
- (NSInteger)readSettings;
- (void)openAppStore;

- (void)alertClearCache;

@end
