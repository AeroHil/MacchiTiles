//
//  NewGamePakGamesController.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/25/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "NewGamePakGamesController.h"
#import "MacchiTilesAppDelegate.h"
#import "ResetGameController.h"
#import "BoardViewDetail.h"

@implementation NewGamePakGamesController
@synthesize savedData;
@synthesize allGames;
@synthesize lastIndexPath;
@synthesize selectedRow;
@synthesize gamepakNum;
@synthesize graphicsMode;

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)save:(id)sender{
	if (self.selectedRow >= 0) {
		if (childController == nil)
			childController = [[ResetGameController alloc] init];
		
		// setup the controller for the game view
		childController.title = @"New Game";
		childController.game = [[self.allGames objectAtIndex:self.selectedRow] componentsSeparatedByString:@" "];
		childController.gamepakNum = self.gamepakNum;
		childController.gameNum = self.selectedRow + 1;
		
		MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//		[delegate.navController setNavigationBarHidden:YES animated:NO];
		[delegate.navController pushViewController:childController animated:YES];	
	}
}

#pragma mark -
#pragma mark Main Methods
-(id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		
	}
	return self;
}

- (void)viewDidLoad {
	self.selectedRow = -1;
	self.allGames = [self listOfGamesInGamePak];
	self.graphicsMode = [self readSettings];
	[self readSavedDataFile];
	
	// create 'ok' button
	UIBarButtonItem *okButton = [[UIBarButtonItem alloc]
								 initWithTitle:@"OK" 
								 style:UIBarButtonItemStyleDone
								 target:self
								 action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = okButton;
	[okButton release];
	
	[super viewDidLoad];
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
	[savedData release];
	[allGames release];
	[lastIndexPath release];
	[childController release];
	[super dealloc];
}
#pragma mark -
#pragma mark I/O Methods
- (void)readSavedDataFile
{
	self.savedData = nil;
	// read the saved file according to the settings
	NSString *filePath = [[NSString alloc] init];
	if (self.graphicsMode == 0)
		filePath = [BoardViewDetail dataFilePath:kSaveFilename];
	else if (self.graphicsMode == 2)
		filePath = [BoardViewDetail dataFilePath:kSaveFilesymb];
	
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		self.savedData = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
}

- (NSArray *)listOfGamesInGamePak{
	NSArray *array = [[[NSArray alloc] init] autorelease];
	NSString *lvlPath = [[NSBundle mainBundle] pathForResource:self.title ofType:@"lvl"];
	NSString *dataInMem = [[NSString alloc] initWithContentsOfFile:lvlPath];
	
	// get all the games from gamepak file
	if (dataInMem != nil)
	{
		array = [dataInMem componentsSeparatedByString:@"\n"];
//		self.currentGame = [[self.allGames objectAtIndex:0] componentsSeparatedByString:@" "];
	}
	
//	[lvlPath release];
	[dataInMem release];
	
	return array;
}

- (NSInteger)readSettings
{
	NSInteger retval = -1;
	// get the path to the settings file
	NSString *filePath = [BoardViewDetail dataFilePath:SETTINGS_FILE];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		// if the file exists check the settings tag and get the value
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:filePath];
		if ([settings objectForKey:GRAPHICS_TAG] != nil)
			retval = [[settings objectForKey:GRAPHICS_TAG] intValue];
	}
	else
		retval = 0;
	
	return retval;
}

#pragma mark -
#pragma mark Table Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
	return [allGames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *NewGamePakButtonCellIdentifier = @"NewGamePakButtonCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewGamePakButtonCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
									   reuseIdentifier:NewGamePakButtonCellIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	// setup mode text
	NSString *gameMode = [NSString stringWithFormat:@"[Easy Mode]"];
	if ([[[self.allGames objectAtIndex:row] componentsSeparatedByString:@" "] count] == 96)
		gameMode = [NSString stringWithFormat:@"[Dexi Mode]"];
	// setup table row texts
	cell.text = [NSString stringWithFormat:@"Game #%d  %@", row+1, gameMode];
	NSString *iconFileName = [NSString stringWithFormat:@"checknot.png"];
	if (self.savedData != nil) {
		if ([self.savedData objectForKey:self.title] != nil) {
			if ([[self.savedData objectForKey:self.title] containsObject:[NSNumber numberWithInt:row+1]])
				iconFileName = [NSString stringWithFormat:@"check.png"];
		}
	}
	cell.image = [UIImage imageNamed:iconFileName];
	
	if (self.graphicsMode == 0)
		cell.textColor = [UIColor brownColor];
	else if (self.graphicsMode == 2)
		cell.textColor = [UIColor orangeColor];
	
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// need to check for previous selection
	int newRow = [indexPath row];
	int oldRow = [lastIndexPath row];
	
	self.selectedRow = newRow;
	
	// check if the row numbers are different and if this is the first time selection
	if (newRow != oldRow || lastIndexPath == nil)
	{
		UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath]; 
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		
		lastIndexPath = indexPath;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
}

@end
