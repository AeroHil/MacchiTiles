//
//  ResetGameController.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 6/24/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@class BoardViewDetail;

@interface ResetGameController : SecondLevelViewController {
	
	NSArray *game;
	BoardViewDetail *childController;
	
	NSInteger gamepakNum, gameNum;
}

@property (nonatomic, retain) NSArray *game;
@property NSInteger gamepakNum;
@property NSInteger gameNum;

- (NSInteger)readSettings;

@end
