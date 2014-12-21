//
//  AboutGameDetail.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 6/6/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "AboutGameDetail.h"


@implementation AboutGameDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	UITextView* gameText =  [self createTextView];
	[gameText setTag:1];
	[self.view addSubview:gameText];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[self.view viewWithTag:1] removeFromSuperview];
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
	[super dealloc];
}

- (UITextView *)createTextView
{
	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 415.0);
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.delegate = nil;
    textView.backgroundColor = [UIColor clearColor];
	textView.editable = NO;
	textView.font = [UIFont fontWithName:@"Verdana" size:12.0];
	
	textView.text = @"MacchiTiles Lite\n\n"
	"MacchiTiles is a simple puzzle game of pairing matches. "
	"The objective is to match two of the same value tiles in adjacent cells. "
	"Clear the board of all tiles wins the game. "
	"As part of this simplicity, the game only has one undo move. "
	"This means that the player can only undo the last match. "
	"The game will not notify you how many moves are left nor the number of possible moves to solve the game. "
	"If you feel that you can't go any further, simply reset the game and try again. "
	"This was design with the KIS model in mind (keep it simple). "
	"The player can come up with as many solutions as possible without the restriction of time and the least number of moves. "
	"Though, some minor game stats are kept in the stats and settings section. "
	"For each of the games, I personally made sure there is at least one solution. Working hard pays off, so enjoy!\n\n"
	"Gameplay:\n"
	"1. Tap the tile once to select it. Selected tiles will be highlighted.\n"
	"2. To deselect a selection, tap the highlighted tile again. Deselect will move the tile back to the orginal cell if moved.\n"
	"3. Two tiles can be selected at the same time.\n"
	"4. Holding down a tap will show a path of available cells for movement.\n"
	"5. A swipe allows the tile to be moved.\n"
	"6. Tiles can be moved horizontally or vertically once only.\n"
	"7. At the end of swipe, the tile will be moved to the last touched cell.\n"
	"8. If the move is off the projected path, tile will not be moved.\n"
	"9. Two matching adjacent tiles will be removed from board.\n"
	"10. Tiles that do not match will be moved back to original cells.\n\n" 
	"Menu:\n"
	"1. Tap with two finger simultaneously to bring up the game menu.\n"
	"2. Undo will let you undo your last match.\n"
	"3. Reset will let you restart the current game.\n"
	"4. Exit will allow you to exit the current game.\n\n"
	"Contact:\n"
	"I dedicate this app to my grandmother. \n"
	"If you would like to send comments/questions, please email MacchiTiles@gmail.com or follow on twitter @MacchiTiles. "
	"I can't say that I will respond to all of them, but I will certainly try to read them all.  Thanks for playing!\n\n\n"
	"Jonathan Lin 2009, All Rights Reserved.";
	
	return textView;
}

@end
