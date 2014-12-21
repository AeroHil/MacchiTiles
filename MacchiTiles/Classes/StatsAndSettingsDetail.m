//
//  StatsAndSettingsDetail.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 6/3/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "StatsAndSettingsDetail.h"
#import "MacchiTilesAppDelegate.h"
#import "BoardViewDetail.h"


@implementation StatsAndSettingsDetail
@synthesize normalGames;
@synthesize normalGamePaks;
@synthesize symbolGames;
@synthesize symbolGamePaks;
@synthesize savedData;
@synthesize savedDataSym;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {

	[self readSavedDataFile];
	
	NSInteger gamepakTotal = [self getNumberOfGamePaks];
	NSInteger gamesTotal = 0;
	NSInteger gamepakDone = 0;
	NSInteger gamesDone = 0;
	
	// setting up stats for normal games
	for (int i = 0; i < gamepakTotal; i++)
	{
		NSInteger games = [[self getGamesInGamePak:i+1] count];
		gamesTotal = gamesTotal + games;
		
		if (self.savedData != nil) {
			NSString *formatName = [[NSString alloc] initWithFormat:@"GamePak%d", i+1];
			if ([self.savedData objectForKey:formatName] != nil) {
				NSInteger savedGames = [[self.savedData objectForKey:formatName] count];
				gamesDone = gamesDone + savedGames;
				
				if (savedGames == games)
					gamepakDone++;
			}
			
			[formatName release];
		}
	}
	normalGames.text = [[NSString alloc] initWithFormat:@"%d / %d", gamesDone, gamesTotal];
	normalGamePaks.text = [[NSString alloc] initWithFormat:@"%d / %d", gamepakDone, gamepakTotal];
	
	gamesTotal = 0;
	gamepakDone = 0;
	gamesDone = 0;
	// setting up stats for symbol games
	for (int i = 0; i < gamepakTotal; i++)
	{
		NSInteger games = [[self getGamesInGamePak:i+1] count];
		gamesTotal = gamesTotal + games;
		
		if (self.savedDataSym != nil) {
			NSString *formatName = [[NSString alloc] initWithFormat:@"GamePak%d", i+1];
			if ([self.savedDataSym objectForKey:formatName] != nil) {
				NSInteger savedGames = [[self.savedDataSym objectForKey:formatName] count];
				gamesDone = gamesDone + savedGames;
				
				if (savedGames == games)
					gamepakDone++;
			}
			
			[formatName release];
		}
	}
	symbolGames.text = [[NSString alloc] initWithFormat:@"%d / %d", gamesDone, gamesTotal];
	symbolGamePaks.text = [[NSString alloc] initWithFormat:@"%d / %d", gamepakDone, gamepakTotal];
	
	// Set up segmented buttons
	NSArray *segmentTextContent = [NSArray arrayWithObjects: @"Numbers", @"", @"Symbols", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	CGRect frame = CGRectMake(85.0, 270.0, 149.0, 30.0);
	segmentedControl.frame = frame;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl setWidth:1.0 forSegmentAtIndex:1];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	segmentedControl.tintColor = [UIColor lightGrayColor];
	NSInteger selectedIndex = [self readSettings];
	if (selectedIndex >= 0)
		segmentedControl.selectedSegmentIndex = selectedIndex;
	[segmentedControl addTarget:self action:@selector(saveSettings:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segmentedControl];
	[segmentedControl release];

	// set up clear cache button
	clearButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	CGRect buttonFrame = CGRectMake(25.0, 365.0, 24.0, 24.0);
	[clearButton setFrame:buttonFrame];
	[clearButton setImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
	[clearButton addTarget:self action:@selector(alertClearCache) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:clearButton];
	
	// set up app store button
	appButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	CGRect appFrame = CGRectMake(110.0, 316.0, 100.0, 65.0);
	[appButton setFrame:appFrame];
	[appButton setImage:[UIImage imageNamed:@"version2.png"] forState:UIControlStateNormal];
	[appButton addTarget:self action:@selector(openAppStore) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:appButton];

	
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
	[normalGames release];
	[normalGamePaks release];
	[savedData release];
	[savedDataSym release];
	[clearButton release];
	[super dealloc];
}

#pragma mark -
#pragma mark I/O Methods
- (void)readSavedDataFile
{
	self.savedData = nil;
	self.savedDataSym = nil;
	NSString *filePath = [BoardViewDetail dataFilePath:kSaveFilename];
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		self.savedData = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	
	filePath = [BoardViewDetail dataFilePath:kSaveFilesymb];
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		self.savedDataSym = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
}

- (void)removeSavedDataFiles
{
	NSString *filePath = [BoardViewDetail dataFilePath:kSaveFilename];
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	
	filePath = [BoardViewDetail dataFilePath:kSaveFilesymb];
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	
	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController popToRootViewControllerAnimated:YES];
}

- (NSInteger)getNumberOfGamePaks
{
	NSString *pname;
	NSString *lvlPath = [[NSBundle mainBundle] resourcePath];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:lvlPath];
	NSInteger count = 0;
	
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

- (void)saveSettings:(id)sender
{
//	[sender selectedSegmentIndex]
	BOOL needToWrite = NO;
	NSString *filePath = [BoardViewDetail dataFilePath:SETTINGS_FILE];
	NSMutableDictionary *saveSetting;
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		saveSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:filePath] autorelease];
		if ([[saveSetting objectForKey:GRAPHICS_TAG] intValue] != [sender selectedSegmentIndex]) {
			[saveSetting setObject:[NSNumber numberWithInt:[sender selectedSegmentIndex]] forKey:GRAPHICS_TAG];
			needToWrite = YES;
		}
	}
	else {
		saveSetting = [[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:[sender selectedSegmentIndex]]			
														  forKey:GRAPHICS_TAG] autorelease];
		needToWrite = YES;
	}
	
	// write to file
	if (needToWrite)
		[saveSetting writeToFile:filePath atomically:YES];
}

- (NSInteger)readSettings
{
	NSInteger retval = -1;
	NSString *filePath = [BoardViewDetail dataFilePath:SETTINGS_FILE];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:filePath];
		if ([settings objectForKey:GRAPHICS_TAG] != nil) {
			retval = [[settings objectForKey:GRAPHICS_TAG] intValue];
		}
	}
	else
		retval = 0;
	
	return retval;
}

- (void)openAppStore
{
	NSURL *appStoreUrl = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=325351629&mt=8"];
	[[UIApplication sharedApplication] openURL:appStoreUrl];
}

#pragma mark -
#pragma mark Alert Methods
- (void)alertClearCache
{
	// open an alert with just one button
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Clear Cache?"
						  message:@"Are you really sure you want to clear all local data?"
						  delegate:self 
						  cancelButtonTitle:@"No!" 
						  otherButtonTitles: @"Yes, clear all.", nil];
	alert.tag = 8;
	[alert show];	
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// called by alertClearCache
	if (alertView.tag == 8) {
		if (buttonIndex != [alertView cancelButtonIndex])
			[self removeSavedDataFiles];
	}
}

@end
