//
//  RootViewController.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/18/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "RootViewController.h"
#import "SecondLevelViewController.h"
#import "MacchiTilesAppDelegate.h"
#import "NewGameController.h"
#import "RandomGameController.h"
#import "StatsAndSettingsDetail.h"
#import "AboutGameDetail.h"


@implementation RootViewController
@synthesize controllers;
@synthesize headerView;

- (void)viewDidLoad {
	self.title = @"Menu";
	NSMutableArray *array = [[NSMutableArray alloc] init];
							 //WithObjects: @"New Game", @"Random Game", @"Resume Game", @"Options", nil];
	
	// set up the table's header view based on our UIView 'myHeaderView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	// set up the new game controller
	NewGameController *newGame = [[NewGameController alloc] initWithStyle:UITableViewStyleGrouped];
	newGame.title = @"New Game";
	newGame.rowImage = [UIImage imageNamed:@"button_tile.png"];
	[array addObject:newGame];
	[newGame release];
	
	// set up the random game controller
	RandomGameController *randGame = [[RandomGameController alloc] init];
	randGame.title = @"Random Game";
	randGame.rowImage = [UIImage imageNamed:@"button_tile.png"];
	[array addObject:randGame];
	[randGame release];
	
	// set up the stats and settings page
	SecondLevelViewController *stats = [[SecondLevelViewController alloc] init];
	stats.title = @"Stats and Settings";
	stats.rowImage = [UIImage imageNamed:@"button_tile.png"];
	[array addObject:stats];
	[stats release];
	
	// set up the about page
	SecondLevelViewController *about = [[SecondLevelViewController alloc] init];
	about.title = @"About MacchiTiles";
	about.rowImage = [UIImage imageNamed:@"button_tile.png"];
	[array addObject:about];
	
	self.controllers = array;
	[array release];
	[super viewDidLoad];
	
}

- (void)showStatsPage {
	if (statsController == nil)
		statsController = [[StatsAndSettingsDetail alloc] 
						   initWithNibName:@"StatsAndSettingsViewDetail" bundle:nil];
	
	// setup the game controller
	statsController.title = @"Stats and Settings";
	
	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController pushViewController:statsController animated:YES];	
}

- (void)showAboutPage {
	if (aboutController == nil)
		aboutController = [[AboutGameDetail alloc] 
						   initWithNibName:@"AboutGameViewDetail" bundle:nil];
	
	// setup the game controller
	aboutController.title = @"About This Game";
	
	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController pushViewController:aboutController animated:YES];	
}

- (void)dealloc {
	[headerView release];
	[controllers release];
	[statsController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// there will only be two sections in from the root screen
	return 2;
}

-(NSInteger)tableView:(UITableView *)tableView 
	numberOfRowsInSection:(NSInteger)section {	
	NSInteger rows = 0;
	// setup each rows
    switch (section) {
        case 0:
			rows = 3;
			break;
        case 1:
            rows = 1;
            break;
        default:
            break;
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView
	cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *RootViewControllerCell = @"RootViewControllerCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RootViewControllerCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:RootViewControllerCell] autorelease];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	// make sure correct rows correspond to the right sections
    NSInteger row = indexPath.row + (indexPath.section*3);
	SecondLevelViewController *controller = [controllers objectAtIndex:row];
	cell.text = controller.title;
	cell.image = controller.rowImage;
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView 
	accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView 
	didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// push the controller onto the stack when a row is selected
//	NSUInteger row = [indexPath row];
	NSInteger row = indexPath.row + (indexPath.section*3);
	
	if (row == 2)
		[self showStatsPage];
	else if (row == 3)
		[self showAboutPage];
	else {
		SecondLevelViewController *nextController = [self.controllers objectAtIndex:row];
		MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.navController pushViewController:nextController animated:YES];
	}
}

@end
