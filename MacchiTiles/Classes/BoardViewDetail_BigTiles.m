//
//  BoardViewDetail_BigTiles.m
//  MacchiTiles
//
//  Created by Jonathan Lin on 7/2/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import "BoardViewDetail_BigTiles.h"
#import "MacchiTilesAppDelegate.h"
#import "ResetGameController.h"

@implementation BoardViewDetail_BigTiles

@synthesize tileIconsNormal;
@synthesize tileIconsNegative;
@synthesize tileViews;
@synthesize tilePath;
@synthesize currentTileView;
@synthesize guideView;
@synthesize currentGame;
@synthesize boardMap;
@synthesize gamepakNum;
@synthesize gameNum;
@synthesize savedData;
@synthesize graphicsMode;
@synthesize touchStartPt;
@synthesize clearPoint;
@synthesize firCenterPt;
@synthesize secCenterPt;
@synthesize firEndPt;
@synthesize secEndPt;
@synthesize firUndoPt;
@synthesize secUndoPt;
@synthesize horizMoveVec;
@synthesize vertiMoveVec;

#pragma mark -
#pragma mark === Private Methods ===
#pragma mark

-(void)initBoard
{	
	self.boardMap = [[NSMutableArray alloc] init];
	self.savedData = [[NSMutableDictionary alloc] init];
	
	if (self.currentGame != nil) {
		for (int i = 0; i < B_MAX_TILES; i++){
			[boardMap addObject:@"N"];
		}
	}
	else {
		NSLog(@"Error on loading game!");
	}
}

- (void)initIconImages
{
	self.tileIconsNormal = [[NSMutableArray alloc] init];
	self.tileIconsNegative = [[NSMutableArray alloc] init];
	
	NSString *symbol = [[NSString alloc] initWithString:@""];
	if (graphicsMode == 2)
		symbol = [symbol stringByAppendingString:@"S"];
	
	for (int i = 0; i < B_MAX_ICONS; i++)
	{
		NSString *tileFilesNO = [[NSString alloc] initWithFormat:@"%d%@_NO_BG.png", i+1, symbol];
		[tileIconsNormal addObject:[UIImage imageNamed:tileFilesNO]];
		
		NSString *tileFilesNE = [[NSString alloc] initWithFormat:@"%d%@_NE_BG.png", i+1, symbol];
		[tileIconsNegative addObject:[UIImage imageNamed:tileFilesNE]];
		
		[tileFilesNO release];
		[tileFilesNE release];
	}
	
	[symbol release];
}

- (void)initTileViews
{	
	// initialize related variables
	hasTileMovedOutOfBounds = NO;
	hasMovedHoriz, hasMovedVerti = NO;
	errorCheck = NO;
	firValue, secValue, totalMatches = 0;
	
	[self initPoints];
	self.tileViews = [[NSMutableArray alloc] init];
	self.tilePath  = [[NSMutableArray alloc] init];
	self.horizMoveVec = [[NSMutableArray alloc] init];
	self.vertiMoveVec = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < B_MAX_ROWS; i++)
	{
		for (int j = 0; j < B_MAX_COLS; j++)
		{
			int stringNum = [[self.currentGame objectAtIndex:((i*B_MAX_COLS)+j)] intValue]; // get each tile value from game file
			NSInteger indexNum = (NSInteger)stringNum - 1;						   // change index to 0-based
			
			//			CGRect tileRect = CGRectMake(j*40.0, (i*38.0)+2.0, 40.0, 38.0);
			CGRect tileRect = CGRectMake(j*B_TILE_W + B_W_BUFFER, (i*B_TILE_H) + B_H_BUFFER, B_TILE_W, B_TILE_H);
			// setup tile views
			UIImageView *tempView = [[UIImageView alloc] initWithFrame:tileRect];
			[tempView setImage:[self.tileIconsNormal objectAtIndex:indexNum]];
			tempView.animationImages = [NSArray arrayWithObjects: [self.tileIconsNegative objectAtIndex:indexNum], nil];
			[tempView stopAnimating];
			
			// setup tile paths
			UIImageView *tempPath = [[UIImageView alloc] initWithFrame:tileRect];
			[tempPath setImage:[UIImage imageNamed:@"tilepath_big.png"]];
			[tempPath setHidden:YES];
			
			[tileViews addObject:tempView];
			[tilePath addObject:tempPath];
			[self.view addSubview:tempPath];
			[self.view addSubview:tempView];
			
			[tempView release];
			[tempPath release];
		}
	}
	// setup the guide view
	self.guideView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 76.0)];
	[self.guideView setImage:[UIImage imageNamed:@"guide.png"]];
	[self.guideView setHidden:YES];
	[self.view addSubview:self.guideView];
}

- (void)removeAllTileViews
{
	for (UIImageView *eachView in self.tileViews) {
		[eachView removeFromSuperview];
	}
}

- (void)resetGame
{
	// remove all tile views
	[self removeAllTileViews];
	// pop the view controller
	MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navController popViewControllerAnimated:YES];
}

- (void)initPoints
{
	clearPoint  = CGPointMake(0.0, 0.0);
	firCenterPt = clearPoint;
	secCenterPt = clearPoint;
	firEndPt    = clearPoint;
	secEndPt    = clearPoint;
}

- (void)resetPoint:(NSInteger)tag
{
	if (tag == 1) {
		firCenterPt = clearPoint;
		firEndPt = clearPoint;
	}
	else if (tag == 2) {
		secCenterPt = clearPoint;
		secEndPt = clearPoint;
	}
}

- (void)saveViewsForUndo
{
	// reset matches tiles to its original location 
	[[self.view viewWithTag:1] setCenter:firCenterPt];
	[[self.view viewWithTag:2] setCenter:secCenterPt];
	[(UIImageView *)[self.view viewWithTag:1] stopAnimating];
	[(UIImageView *)[self.view viewWithTag:2] stopAnimating];
	// need to clear any previous undo views
	if ([self.view viewWithTag:B_UNDO_FIRST] != nil)
		[self clearSelectedView:(UIImageView *)[self.view viewWithTag:B_UNDO_FIRST]];
	if ([self.view viewWithTag:B_UNDO_SECOND] != nil)
		[self clearSelectedView:(UIImageView *)[self.view viewWithTag:B_UNDO_SECOND]];
	// save views 1 and 2 for undo
	[[self.view viewWithTag:1] setTag:B_UNDO_FIRST];
	[[self.view viewWithTag:2] setTag:B_UNDO_SECOND];
	//save first and second start points for undo
	firUndoPt = firCenterPt;
	secUndoPt = secCenterPt;
}

- (void)clearSavedUndoViews
{
	[self clearSelectedView:(UIImageView *)[self.view viewWithTag:B_UNDO_FIRST]];
	[self clearSelectedView:(UIImageView *)[self.view viewWithTag:B_UNDO_SECOND]];
	firUndoPt = clearPoint;
	secUndoPt = clearPoint;
}

- (void)undoViews
{
	// need to reset the first selected point, if there is one
	if ([self.view viewWithTag:1] != nil) {
		// Unhighlight the views 
		[(UIImageView *)[self.view viewWithTag:1] stopAnimating];
		// move the tiles back to starting positions
		[[self.view viewWithTag:1] setCenter:firCenterPt];
		// clear the tags, center points
		[self clearSelectedView:(UIImageView *)[self.view viewWithTag:1]];
		[self resetPoint:1];
	}
	// set the undo views not hidden
	[[self.view viewWithTag:B_UNDO_FIRST] setHidden:NO];
	[[self.view viewWithTag:B_UNDO_SECOND] setHidden:NO];
	// update the boardmap with undo views location
	[boardMap replaceObjectAtIndex:[self getTileAtPoint:firUndoPt] withObject:@"N"];
	[boardMap replaceObjectAtIndex:[self getTileAtPoint:secUndoPt] withObject:@"N"];
	
	// clear the save undo view data
	[self clearSavedUndoViews];
	// decrement match count
	totalMatches--;
}

- (void)removeViews 
{
	if ([self.view viewWithTag:1] != nil &&
		[self.view viewWithTag:2] != nil)
	{
		// Hide the views
		[[self.view viewWithTag:1] setHidden:YES];
		[[self.view viewWithTag:2] setHidden:YES];
		// save variables for undo 
		[self saveViewsForUndo];
		
		// Clear the tags and center points
		if ([self.view viewWithTag:1] != nil)
			[self clearSelectedView:(UIImageView *)[self.view viewWithTag:1]];
		if ([self.view viewWithTag:2] != nil)
			[self clearSelectedView:(UIImageView *)[self.view viewWithTag:2]];
		
		[self resetPoint:1];
		[self resetPoint:2];
	}
	else
		NSLog(@"removeViews method error!");
}

- (void)cancelViews
{
	if ([self.view viewWithTag:1] != nil &&
		[self.view viewWithTag:2] != nil)
	{
		// Unhighlight the views 
		[(UIImageView *)[self.view viewWithTag:1] stopAnimating];
		[(UIImageView *)[self.view viewWithTag:2] stopAnimating];
		// move the tiles back to starting positions
		[[self.view viewWithTag:1] setCenter:firCenterPt];
		[[self.view viewWithTag:2] setCenter:secCenterPt];
		// clear the tags, center points
		[self clearSelectedView:(UIImageView *)[self.view viewWithTag:1]];
		[self clearSelectedView:(UIImageView *)[self.view viewWithTag:2]];
		[self resetPoint:1];
		[self resetPoint:2];
	}
	else
		NSLog(@"cancelViews method error!");
}

- (void)updateBoardAfterMatch
{
	CGPoint point1, point2;
	if (CGPointEqualToPoint(firEndPt, clearPoint))
		point1 = firCenterPt;
	else
		point1 = firEndPt;
	if(CGPointEqualToPoint(secEndPt, clearPoint))
		point2 = secCenterPt;
	else
		point2 = secEndPt;
	
	NSInteger index1 = [self getTileAtPoint:point1];
	NSInteger index2 = [self getTileAtPoint:point2];
	NSLog(@"updateBoardAfterMatch - index: %d", index1);
	[boardMap replaceObjectAtIndex:index1 withObject:@"Y"];
	NSLog(@"updateBoardAfterMatch - index: %d", index2);
	[boardMap replaceObjectAtIndex:index2 withObject:@"Y"];
}

- (void)updateBoardAfterMoveFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
	NSInteger startPoint = [self getTileAtPoint:start];
	NSInteger endPoint = [self getTileAtPoint:end];
	[boardMap replaceObjectAtIndex:startPoint withObject:@"Y"];
	[boardMap replaceObjectAtIndex:endPoint withObject:@"N"];
}

- (void)animateView:(CGFloat)scale
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationRepeatCount:2];
	CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
	
	[[self.view viewWithTag:1] setTransform:transform];
	[[self.view viewWithTag:2] setTransform:transform];
	// Set the transform back to the identity, thus undoing the previous scaling effect.
	[[self.view viewWithTag:1] setTransform:CGAffineTransformIdentity];
	[[self.view viewWithTag:2] setTransform:CGAffineTransformIdentity];
	[UIView commitAnimations];
}

-(CGFloat)getBoundCoordAtHoriz:(BOOL)horiz atMin:(BOOL)bound
{
	CGFloat retval = 0.0;
	CGPoint minPoint, maxPoint;
	if (horiz){
		minPoint = [self getCenterFromIndex:[[self.horizMoveVec objectAtIndex:0] intValue]];
		maxPoint = [self getCenterFromIndex:[[self.horizMoveVec objectAtIndex:[self.horizMoveVec count]-1] intValue]];
		if (bound)
			retval = minPoint.x;
		else
			retval = maxPoint.x;
	}
	else{
		minPoint = [self getCenterFromIndex:[[self.vertiMoveVec objectAtIndex:0] intValue]];
		maxPoint = [self getCenterFromIndex:[[self.vertiMoveVec objectAtIndex:[self.vertiMoveVec count]-1] intValue]];
		if (bound)
			retval = minPoint.y;
		else
			retval = maxPoint.y;
	}
	
	return retval;
}

- (CGFloat)checkCoord:(CGFloat)coord withMin:(CGFloat)min withMax:(CGFloat)max
{
	CGFloat retval = 0.0;
	if (coord < min)
		retval = min;
	else if (coord > max)
		retval = max;
	else
		retval = coord;
	
	return retval;
}

- (BOOL)areSelectedInAdjacentCells
{
	BOOL retval = NO;
	// get the first selected tile index
	CGPoint firSelectedCenter = [self.view viewWithTag:1].center;
	NSInteger indexOfFirst = [self getTileAtPoint:firSelectedCenter];
	
	for (int i = 0; i < 4; i++){
		// use bit shifting to go through the 4 adjacent cells
		NSInteger adjIndex  = [self getAdjacencyIndexAt:indexOfFirst ofSide:(1<<i)];
		if (adjIndex >= 0){
			CGPoint adjPoint = [self getCenterFromIndex:adjIndex];
			// check if the point in the adjacent cell is in the second selected tile
			if (CGRectContainsPoint([[self.view viewWithTag:2] frame], adjPoint)){
				retval = YES;
				break;
			}
		}
	}
	
	return retval;
}

#pragma mark -
#pragma mark === Positions Functions  ===
#pragma mark

-(int)getIndexFromPoint:(CGPoint)location asRow:(BOOL)row
{
	int indx = -1;
	if(row) {
		if (location.y < B_H_BUFFER)
			indx = 0;
		else if	(location.y > (460.0-B_H_BUFFER))
			indx = B_MAX_ROWS-1;
		else
			indx = (int)((location.y-B_H_BUFFER) / B_TILE_H);
	}
	else {
		if (location.x < B_W_BUFFER)
			indx = 0;
		else if	(location.x > (320.0-B_W_BUFFER))
			indx = B_MAX_COLS-1;
		else
			indx = (int)((location.x-B_W_BUFFER) / B_TILE_W);
	}
	
	return indx;
}

-(NSInteger)getTileAtRow:(int)row atCol:(int)col
{
	return (row * B_MAX_COLS) + col;
}

- (NSInteger)getTileAtPoint:(CGPoint)location
{
	int row = [self getIndexFromPoint:location asRow:YES];
	int col = [self getIndexFromPoint:location asRow:NO];
	return [self getTileAtRow:row atCol:col];
}

-(CGPoint)closestGridCenterTo:(CGPoint)location
{
	int row = [self getIndexFromPoint:location asRow:YES];
	int col = [self getIndexFromPoint:location asRow:NO];
	
	CGFloat xCoord = (B_TILE_W/2)+(B_TILE_W* col);
	CGFloat yCoord = (B_TILE_H/2)+(B_TILE_H* row);
	CGPoint retval = CGPointMake(xCoord+B_W_BUFFER, yCoord+B_H_BUFFER);
	
	return retval;
}

- (CGPoint)getCenterFromIndex:(NSInteger)index
{
	CGPoint retval = clearPoint;
	if (index >= 0 && index < B_MAX_TILES)
	{
		int col = index % B_MAX_COLS;
		int row = (int)(index / B_MAX_COLS);
		
		CGFloat xCoord = (B_TILE_W/2)+(B_TILE_W* col);
		CGFloat yCoord = (B_TILE_H/2)+(B_TILE_H* row);
		retval.x = xCoord + B_W_BUFFER;
		retval.y = yCoord + B_H_BUFFER;
	}
	return retval;
}

- (NSInteger)getAdjacencyIndexAt:(NSInteger)index ofSide:(NSInteger)bound;
{
	NSInteger retval = B_MT_ERROR;
	
	if (bound == B_WEST){       // check west 
		if ((index % B_MAX_COLS) != 0)
			retval = index - 1;
		else
			retval = -1;      // no west tile
	}
	else if (bound == B_NORTH){ // check north
		if ((index - B_MAX_COLS) >= 0)
			retval = index - B_MAX_COLS;
		else
			retval = -2;      // no north tile
	}
	else if (bound == B_EAST){  // check east
		if ((index % B_MAX_COLS) != (B_MAX_COLS-1))
			retval = index + 1;
		else
			retval = -4;      // no east tile
	}
	else if (bound == B_SOUTH){ // check south
		if ((index + B_MAX_COLS) < B_MAX_TILES)
			retval = index + B_MAX_COLS;
		else
			retval = -8;      // no south tile
	}
	else
		NSLog(@"getAdjacencyIndexAt method error!");
	
	return retval;
}

#pragma mark -
#pragma mark === View functions  ===
#pragma mark

- (BOOL)checkViewWithTag:(NSInteger)num atPoint:(CGPoint)point
{
	return CGRectContainsPoint([[self.view viewWithTag:num] frame], point);
}

- (NSInteger)getTagFromPoint:(CGPoint)location
{
	NSInteger tag = 0;
	if ([self checkViewWithTag:1 atPoint:location])
		tag = 1;
	else if ([self checkViewWithTag:2 atPoint:location])
		tag = 2;
	else{
		NSLog(@"ERROR! tag is emtpy!");
	}
	
	return tag;
}

- (BOOL)setSelectedView:(UIImageView *)currentView atPoint:(CGPoint)location toValue:(int)value
{
	BOOL retval = YES;
	// nothing has been tagged, set the first tag
	if ([self.view viewWithTag:1] == nil &&
		[self.view viewWithTag:2] == nil){
		currentView.tag = 1;
		firCenterPt = [self closestGridCenterTo:location];
		firValue = value;
	}
	// set the second tag
	else if ([self.view viewWithTag:1] != nil &&
			 [self.view viewWithTag:2] == nil){
		currentView.tag = 2;
		secCenterPt = [self closestGridCenterTo:location];
		secValue = value;
	}
	// something went wrong, need to clear everything
	else { 
		NSLog(@"setSelectedView method error!");
		retval = NO;
	}
	
	return retval;
}

- (void)clearSelectedView:(UIImageView *)currentView 
{
	currentView.tag = 0;
}

- (void)movableRoutesFrom:(NSInteger)index
{
	// Add the original index first
	[self.horizMoveVec addObject:[NSNumber numberWithInt:index]];
	[self.vertiMoveVec addObject:[NSNumber numberWithInt:index]];
	// Get the adjacent tiles from the original
	// check west bound
	NSInteger recur = [self getAdjacencyIndexAt:index ofSide:B_WEST];
	while (recur >= 0){
		if ([self.boardMap objectAtIndex:recur] == @"Y"){
			[self.horizMoveVec addObject:[NSNumber numberWithInt:recur]];
			recur = [self getAdjacencyIndexAt:recur ofSide:B_WEST];
		}
		else
			break;
	}
	// check north bound
	recur = [self getAdjacencyIndexAt:index ofSide:B_NORTH];
	while (recur >= 0){
		if ([self.boardMap objectAtIndex:recur] == @"Y"){
			[self.vertiMoveVec addObject:[NSNumber numberWithInt:recur]];
			recur = [self getAdjacencyIndexAt:recur ofSide:B_NORTH];
		}
		else
			break;
	}
	// check east bound
	recur = [self getAdjacencyIndexAt:index ofSide:B_EAST];
	while (recur >= 0){
		if ([self.boardMap objectAtIndex:recur] == @"Y"){
			[self.horizMoveVec addObject:[NSNumber numberWithInt:recur]];
			recur = [self getAdjacencyIndexAt:recur ofSide:B_EAST];
		}
		else
			break;
	}
	// check south bound
	recur = [self getAdjacencyIndexAt:index ofSide:B_SOUTH];
	while (recur >= 0){
		if ([self.boardMap objectAtIndex:recur] == @"Y"){
			[self.vertiMoveVec addObject:[NSNumber numberWithInt:recur]];
			recur = [self getAdjacencyIndexAt:recur ofSide:B_SOUTH];
		}
		else
			break;
	}
	
	//sort the arrays - the selector compare: is part of the NSNumber class
	if ([self.horizMoveVec count] > 1)
		[self.horizMoveVec sortUsingSelector:@selector(compare:)];
	if ([self.vertiMoveVec count] > 1)
		[self.vertiMoveVec sortUsingSelector:@selector(compare:)];
	
}

- (void)clearRoutes
{
	[self.horizMoveVec removeAllObjects];
	[self.vertiMoveVec removeAllObjects];
}

#pragma mark -
#pragma mark === Path functions  ===
#pragma mark

- (void)showMovablePathsFrom:(NSInteger)startIndex
{
	if ([self.horizMoveVec count] > 1) {
		for (int i = 0; i < [self.horizMoveVec count]; i++) {
			NSInteger indexNumHor = [[self.horizMoveVec objectAtIndex:i] intValue];
			if (indexNumHor != startIndex)
				[[self.tilePath objectAtIndex:indexNumHor] setHidden:NO];
		}
	}
	
	if ([self.vertiMoveVec count] > 1) {
		for (int i = 0; i < [self.vertiMoveVec count]; i++) {
			NSInteger indexNumVer = [[self.vertiMoveVec objectAtIndex:i] intValue];
			if (indexNumVer != startIndex)
				[[self.tilePath objectAtIndex:indexNumVer] setHidden:NO];
		}
	}
}

- (void)clearPaths
{
	for (UIImageView *eachPath in self.tilePath) {
		if (![eachPath isHidden])
			[eachPath setHidden:YES];
	}
}

- (void)showDraggingPathAt:(CGPoint)location exclude:(NSInteger)index
{
	NSInteger tileIndex = [self getTileAtPoint:location];
	if (tileIndex != index){
		if ( [self.boardMap objectAtIndex:tileIndex] == @"Y" &&
			[[self.tilePath objectAtIndex:tileIndex] isHidden])
			[[self.tilePath objectAtIndex:tileIndex] setHidden:NO];
	}
}

- (void)showGuideViewAt:(CGPoint)location
{
	CGPoint fingerCenter = [self closestGridCenterTo:location];
	
	if (!CGPointEqualToPoint(self.guideView.center, fingerCenter))
		[self.guideView setCenter:fingerCenter];
}

- (void)debugRoutesWithPathsView
{
	for (int i = 0; i < B_MAX_TILES; i++) {
		if ([self.boardMap objectAtIndex:i] == @"Y")
			[[self.tilePath objectAtIndex:i] setHidden:NO];
		else
			[[self.tilePath objectAtIndex:i] setHidden:YES];
	}
}

#pragma mark -
#pragma mark === Persistent Data Functions  ===
#pragma mark

+ (NSString *)dataFilePath:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)saveGameData
{
	BOOL needToWrite = NO;
	NSString *filePath = [[NSString alloc] init];
	// check the settings and get the path to the file accordingly
	if (self.graphicsMode == 0)
		filePath = [BoardViewDetail_BigTiles dataFilePath:B_kSaveFilename];
	else if (self.graphicsMode == 2)
		filePath = [BoardViewDetail_BigTiles dataFilePath:B_kSaveFilesymb];
	
	NSString *gamePakName = [[NSString alloc] initWithFormat:@"GamePak%d", self.gamepakNum];
	// check if the file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		self.savedData = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	// key is found in dictionary
	if ([self.savedData objectForKey:gamePakName] != nil) {
		// check if the array already has the gameNum, if not, add it
		if (![[self.savedData objectForKey:gamePakName] containsObject:[NSNumber numberWithInt:self.gameNum]]) {
			[[self.savedData objectForKey:gamePakName] addObject:[NSNumber numberWithInt:self.gameNum]];
			needToWrite = YES;
		}
	}
	// key not found
	else {
		// create a new dictionary entry
		[self.savedData setObject:[NSArray arrayWithObject:[NSNumber numberWithInt:self.gameNum]] 
		 forKey:gamePakName];
		needToWrite = YES;
	}
	// write to file
	if (needToWrite)
		[self.savedData writeToFile:filePath atomically:YES];
	
	[gamePakName release];
}

#pragma mark -
#pragma mark === Main functions  ===
#pragma mark

- (void)viewWillAppear:(BOOL)animated{
	
	[self initBoard];
	[self initIconImages];
	[self initTileViews];	
	//	[self saveGameData];
	
	[super viewWillAppear:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*- (void)viewDidLoad {
 
 [self initBoard];
 [self initIconImages];
 [self initTileViews];
 
 //	UIImageView *temp = [self.tileViews objectAtIndex:95];
 //	temp.center = CGPointMake(40.0, 40.0);
 
 }*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[tileIconsNormal release];
	[tileIconsNegative release];
	[tileViews release];
	[tilePath release];
	[currentTileView release];
	[guideView release];
	[currentGame release];
	[boardMap release];
	[savedData release];
	[horizMoveVec release];
	[vertiMoveVec release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

///////////////////////////////////////////////////////////////////////////////////
// Handles the start of a touch
///////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!errorCheck) {
		UITouch *touch = [touches anyObject];
		//	NSUInteger tapCount = [touch tapCount];
		NSUInteger numTouches = [touches count];
		
		if (numTouches >=2 ) {
			[self dialogGameMenuAction];
		}
		else {
			int tileValue = 0;
			touchStartPt = [touch locationInView:self.view];
			startTileIndex = [self getTileAtPoint:touchStartPt];
//			NSLog(@"touchesBegan - index: %d", startTileIndex);
			for (UIImageView *eachView in self.tileViews)
			{
				if (CGRectContainsPoint([eachView frame], touchStartPt))
				{
					[self.guideView setCenter:[self closestGridCenterTo:touchStartPt]];
					[self.guideView setHidden:NO];
					if (![eachView isHidden]){
						self.currentTileView = eachView;
						if (!self.currentTileView.isAnimating){
							tileValue = [[self.currentGame objectAtIndex:startTileIndex] intValue];				
							if (![self setSelectedView:self.currentTileView atPoint:touchStartPt toValue:tileValue]) {
								errorCheck = YES;
								[self alertGameMessage:@"Be Patient!" 
										   withMessage:@"Tile processing is still going on! Please wait for animation to finish."];
								break;
							}
							// Highlight the view and set the relating info
							[self.currentTileView startAnimating];
							// Get tag number
							tagView = [self getTagFromPoint:touchStartPt];
							// Calculated movable routes from this tile
							[self movableRoutesFrom:startTileIndex];
							// Show all available paths
							[self showMovablePathsFrom:startTileIndex];
							break;
						}
						else {
							// This view already has been selected and it has to be the first selection
							// otherwise touchesEnded will take care of clearing
							if (!CGPointEqualToPoint(firEndPt, clearPoint)){
								[self.currentTileView setCenter:firCenterPt];
								[self updateBoardAfterMoveFromPoint:firEndPt toPoint:firCenterPt];
							}
							// unhighlighted it and clear all related info
							[self.currentTileView stopAnimating];
							[self clearSelectedView:self.currentTileView];
							[self resetPoint:1];
							break;
						}
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////
// Handles the continuation of a touch.
///////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// check if a tile is already selected AND no error was caught from touch began
	if (tagView > 0 && !errorCheck){
		
		UITouch *touch = [touches anyObject];
		CGPoint touchCurrentPt = [touch locationInView:self.view];
		
		CGFloat xMoved, yMoved;
		CGFloat minMovement, maxMovement;
		CGFloat deltaX = fabsf(touchStartPt.x - touchCurrentPt.x);
		CGFloat deltaY = fabsf(touchStartPt.y - touchCurrentPt.y);
		// enable the guide view
		[self showGuideViewAt:touchCurrentPt];
		
		// user has moved point, clear the tile paths
		if(!hasMovedHoriz && !hasMovedVerti)
			[self clearPaths];
		
		// Horizontal swipe detected
		if (deltaX >= B_kMinimumGestureLength && deltaY <= B_kMaximumVariance && !hasMovedVerti && !hasTileMovedOutOfBounds) {
			// flag that only horizontal moves are allowed here
			hasMovedHoriz = YES;
			// get the min and max movement
			minMovement = [self getBoundCoordAtHoriz:YES atMin:YES];
			maxMovement = [self getBoundCoordAtHoriz:YES atMin:NO];
			// horizontal moves only effect x coordinate
			xMoved = [self checkCoord:touchCurrentPt.x withMin:minMovement withMax:maxMovement];
			yMoved = [self.view viewWithTag:tagView].center.y;
			[self showDraggingPathAt:CGPointMake(xMoved, yMoved) exclude:startTileIndex];
//			[self showGuideViewAt:CGPointMake(xMoved, yMoved)];
//			[[self.view viewWithTag:tagView] setCenter:CGPointMake(xMoved, yMoved)];
			
			// check to see if swipe is out of bounds
			if ((touchCurrentPt.x - B_kMaximumVariance) > maxMovement ||
				(touchCurrentPt.x + B_kMaximumVariance) < minMovement)
				hasTileMovedOutOfBounds = YES;
		}
		// Vertical swipe detected
		else if (deltaY >= B_kMinimumGestureLength && deltaX <= B_kMaximumVariance && !hasMovedHoriz && !hasTileMovedOutOfBounds) {
			//flag that only vertical moves are allowed here
			hasMovedVerti = YES;
			// get the min and max movement
			minMovement = [self getBoundCoordAtHoriz:NO atMin:YES];
			maxMovement = [self getBoundCoordAtHoriz:NO atMin:NO];
			// vertical moves only effect y coordinate
			xMoved = [self.view viewWithTag:tagView].center.x;
			yMoved = [self checkCoord:touchCurrentPt.y withMin:minMovement withMax:maxMovement];
			[self showDraggingPathAt:CGPointMake(xMoved, yMoved) exclude:startTileIndex];
//			[self showGuideViewAt:CGPointMake(xMoved, yMoved)];
//			[[self.view viewWithTag:tagView] setCenter:CGPointMake(xMoved, yMoved)];
			
			// check to see if swipe is out of bounds
			if ((touchCurrentPt.y - B_kMaximumVariance) > maxMovement ||
				(touchCurrentPt.y + B_kMaximumVariance) < minMovement)
				hasTileMovedOutOfBounds = YES;
		}
		else if ((deltaX >= B_kMinimumGestureLength && deltaY > B_kMaximumVariance) ||
			     (deltaY >= B_kMinimumGestureLength && deltaX > B_kMaximumVariance) || hasTileMovedOutOfBounds) { 
			// touches moved outside of the swipes
			hasTileMovedOutOfBounds = YES;
			if (hasMovedHoriz || hasMovedVerti){
				[[self.view viewWithTag:tagView] setCenter:[self closestGridCenterTo:touchStartPt]];
				[self.currentTileView stopAnimating];
				[self clearSelectedView:self.currentTileView];
				[self resetPoint:tagView];
				[self clearPaths];
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////
// Handles the end of a touch event.
///////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// turn off guide view righ away
	[self.guideView setHidden:YES];
	
	if (!errorCheck) {
		UITouch *touch = [touches anyObject];
		CGPoint touchCurrentPt = [touch locationInView:self.view];
		CGPoint closestCenter = [self closestGridCenterTo:touchCurrentPt];
		NSInteger endTileIndex = [self getTileAtPoint:closestCenter];
//		NSLog(@"touchesEnded - endTileIndex = %d", endTileIndex);
		
		[self clearPaths];
		// if the start and end index do not match and it hasn't moved
		// that means user fat fingered. self correct it.
		if ((endTileIndex != startTileIndex) && !(hasMovedHoriz || hasMovedVerti)) {
			endTileIndex = startTileIndex;
			closestCenter = [self getCenterFromIndex:endTileIndex];
			NSLog(@"Fat Fingered!");
		}
		
//		if (hasMovedHoriz || hasMovedVerti)
//			NSLog(@"has moved!");
		
		// set end point and snap to grid only if the tile has been selected
		// and not out of bounds
		if (!hasTileMovedOutOfBounds && self.currentTileView.isAnimating && tagView > 0 &&
			                          ([self.boardMap objectAtIndex:endTileIndex] == @"Y")) {
			// set the end point of the tile move
			if (!CGPointEqualToPoint(firCenterPt, clearPoint) &&
				 CGPointEqualToPoint(secCenterPt, clearPoint))
				firEndPt = closestCenter;
			else
				secEndPt = closestCenter;
			
			// Check for the first/second moved tile and make sure when released, snaps into grid
			if (hasMovedHoriz || hasMovedVerti) 
			{
				BOOL withInPath = NO;
				if (hasMovedHoriz)
					withInPath = [self.horizMoveVec containsObject:[NSNumber numberWithInt:endTileIndex]];
				else if (hasMovedVerti)
					withInPath = [self.vertiMoveVec containsObject:[NSNumber numberWithInt:endTileIndex]];
				else
					NSLog(@"Error checking moved tiles in toucheEnded");
				
				// check to see that the end tile index is within the movable path
				if (withInPath) {
					[[self.view viewWithTag:tagView] setCenter:closestCenter];
					[self updateBoardAfterMoveFromPoint:touchStartPt toPoint:touchCurrentPt];
				}
				else {
					[self.currentTileView stopAnimating];
					[self clearSelectedView:self.currentTileView];
					[self resetPoint:tagView];
				}
			}
		}
		
		// Check for two tiles to be selected
		if ([self.view viewWithTag:1] != nil && 
			[self.view viewWithTag:2] != nil)
		{
			// animate and remove the two tiles if they match
			if (firValue == secValue && [self areSelectedInAdjacentCells]){
				totalMatches++;
				[self updateBoardAfterMatch];
				[self animateView:0.80];
				[self performSelector:@selector(removeViews) withObject:nil afterDelay:0.3f];
			}
			else{ // if they do not match, put them back and unselect them.
				if (!CGPointEqualToPoint(secEndPt, clearPoint))
					[self updateBoardAfterMoveFromPoint:secEndPt toPoint:secCenterPt];
				if (!CGPointEqualToPoint(firEndPt, clearPoint))
					[self updateBoardAfterMoveFromPoint:firEndPt toPoint:firCenterPt];
				[self animateView:1.15];
				[self performSelector:@selector(cancelViews) withObject:nil afterDelay:0.3f];
			}
		}
		
		// touch has ended, reset moved states
		if (hasMovedHoriz)
			hasMovedHoriz = NO;
		if (hasMovedVerti)
			hasMovedVerti = NO;
		if (hasTileMovedOutOfBounds)
			hasTileMovedOutOfBounds = NO;
		
		// reset global tag number
		if (tagView != 0)
			tagView = 0;
		
		// Clear the route arrays right after touches ended
		[self clearRoutes];
		
//		[self debugRoutesWithPathsView];
		
		if (totalMatches == B_MAX_MATCHES) {
			[self saveGameData];
			[self performSelector:@selector(alertGameComplete) withObject:nil afterDelay:0.8f];
		}
	}
	else
		errorCheck = NO;
}

#pragma mark -
#pragma mark === Popup Notifications ===
#pragma mark

- (void)dialogExitGameAction:(NSString *)title {
	//	NSString *title = [[NSString alloc] initWithString:(NSString *)alertMessage];
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:title
								  delegate:self 	
								  cancelButtonTitle:@"No" 
								  destructiveButtonTitle:@"Yes" 
								  otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	actionSheet.tag = 100;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
	[title release];
}

- (void)dialogGameMenuAction {
	//	NSString *title = [[NSString alloc] initWithString:(NSString *)alertMessage];
	// open a dialog with an OK and cancel button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] 
								  initWithTitle:@"Game Options"
								  delegate:self 	
								  cancelButtonTitle:@"Cancel" 
								  destructiveButtonTitle:nil 
								  otherButtonTitles:@"Undo Move", @"Reset Game", @"Exit Game", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.destructiveButtonIndex = 2;  // make the exit game button red (destructive)
	actionSheet.tag = 101;
	[actionSheet showInView:self.view];      // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (actionSheet.tag == 100) {
		if (buttonIndex == [actionSheet destructiveButtonIndex]) {
			// before pops the stack back to the root, remove all tiles
			[self removeAllTileViews];
			
			MacchiTilesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
			[delegate.navController setNavigationBarHidden:NO];
			[delegate.navController popToRootViewControllerAnimated:YES];
		}
	}
	
	if (actionSheet.tag == 101) {
		// Undo Move button
		if (buttonIndex == 0) {
			if (!CGPointEqualToPoint(firUndoPt, clearPoint) || 
				!CGPointEqualToPoint(secUndoPt, clearPoint))
				[self undoViews];
			else
				[self alertGameMessage:@"Cannot Undo!" withMessage:@"There is no undo moves"];
		}
		if (buttonIndex == 1)
			[self alertGameReset];
		if (buttonIndex == 2)
			[self dialogExitGameAction:@"Are you sure you want to leave? Game will not be saved"];
	}
}

- (void)alertGameComplete
{
	NSString *alertMsg = [[NSString alloc] 
						  initWithFormat:@"Congrats! GamePak%d: Game%d finished!", 
						  self.gamepakNum, self.gameNum];
	
	// open an alert with just one button
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Game Complete!" 
						  message:alertMsg
						  delegate:self 
						  cancelButtonTitle:@"Yay! I win!" 
						  otherButtonTitles: nil];
	alert.tag = 9;
	[alert show];	
	[alert release];
	[alertMsg release];
}

- (void)alertGameReset
{
	// open an alert with just one button
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Game Reset?"
						  message:@"Are you really sure you want to reset game?"
						  delegate:self 
						  cancelButtonTitle:@"No!" 
						  otherButtonTitles: @"Yes, Please.", nil];
	alert.tag = 8;
	[alert show];	
	[alert release];
}

- (void)alertGameMessage:(NSString *)title withMessage:(NSString *)msg 
{
	// open an alert with just one button
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:title
						  message:msg
						  delegate:nil 
						  cancelButtonTitle:nil 
						  otherButtonTitles: @"Ok! Sorry!",nil];
	[alert show];	
	[alert release];	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// called by alertGameReset
	if (alertView.tag == 8) {
		if (buttonIndex != [alertView cancelButtonIndex])
			[self resetGame];
	}
	// called by alertGameComplete
	else if (alertView.tag == 9)
		[self dialogExitGameAction:@"Back to Main Menu?"];
}

@end
