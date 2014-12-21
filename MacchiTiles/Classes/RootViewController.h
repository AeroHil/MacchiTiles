//
//  RootViewController.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/18/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StatsAndSettingsDetail;
@class AboutGameDetail;

@interface RootViewController : UITableViewController 
	<UITableViewDelegate, UITableViewDataSource> {
		
		IBOutlet UIView *headerView;			// view for the banner
		NSMutableArray	*controllers;			// array of controllers
		
		StatsAndSettingsDetail *statsController;
		AboutGameDetail        *aboutController;
}

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) NSMutableArray *controllers;

- (void)showStatsPage;
- (void)showAboutPage;

@end
