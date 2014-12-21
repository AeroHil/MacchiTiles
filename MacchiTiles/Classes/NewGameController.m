//
//  NewGameController.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/23/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "NewGameController.h"
#import "MacchiTilesAppDelegate.h"
#import "NewGamePakGamesController.h"

@implementation NewGameController
@synthesize list;

-(id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		
	}
	return self;
}
- (void)viewDidLoad {
	self.list = [self listOfGameFiles];
	
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
	[list release];
	[childController release];
	[super dealloc];
}

#pragma mark -
#pragma mark I/O Methods
- (NSMutableArray *)listOfGameFiles{
	NSString *pname;
	NSString *lvlPath = [[NSBundle mainBundle] resourcePath];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:lvlPath];
	
	NSMutableArray *gameFiles = [[[NSMutableArray alloc] init] autorelease];
	
	// look in the directory and find each files with .lvl extension
	while (pname = [direnum nextObject]) {
		if ([[pname pathExtension] isEqualToString:@"lvl"]) {
			// add the files names to array, minus the extension
			NSString *formatRowString = [pname substringToIndex:(pname.length-4)];
			[gameFiles addObject:formatRowString];
//			[formatRowString release];
		}
	}
	[pname release];
	
	return gameFiles;
}

#pragma mark -
#pragma mark Table Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
	return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *NewGameButtonCellIdentifier = @"NewGameButtonCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewGameButtonCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
									   reuseIdentifier:NewGameButtonCellIdentifier] autorelease];
	}
	// Configure the cell
	NSUInteger row = [indexPath row];
	NSString *rowString = [list objectAtIndex:row];
	cell.text = rowString;
	[rowString release];
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView 
		accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (childController == nil)
	childController = [[NewGamePakGamesController alloc] initWithStyle:UITableViewStyleGrouped ];
	
	// push the controller onto the stack for the gamepak selected
	NSUInteger row = [indexPath row];
	NSString *selectedGame = [list objectAtIndex:row];
	childController.title = selectedGame;
	childController.gamepakNum = row + 1;
	[selectedGame release];

	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController pushViewController:childController animated:YES];
}

@end
