//
//  BoardViewDetail.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/31/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_ICONS   16
#define MAX_ROWS    12
#define MAX_COLS    8
#define MAX_TILES   96
#define TILE_W      40
#define TILE_H      38
#define H_BUFFER    2
#define MAX_MATCHES 48

#define UNDO_FIRST  3
#define UNDO_SECOND 4
#define MT_ERROR    -99

#define WEST        1
#define NORTH       2
#define SOUTH       4
#define EAST        8

#define kMinimumGestureLength 10
#define kMaximumVariance      18

#define kSaveFilename @"SavedDataNum.plist"
#define kSaveFilesymb @"SavedDataSym.plist"

#define GRAPHICS_TAG  @"Graphics"
#define SETTINGS_FILE @"Settings.plist"

@class ResetGameController;

@interface BoardViewDetail : UIViewController 
	<UIActionSheetDelegate> {
	
	NSMutableArray *tileIconsNormal;
	NSMutableArray *tileIconsNegative;
	NSMutableArray *tileViews;
	NSMutableArray *tilePath;
	UIImageView *currentTileView;
	UIImageView *guideView;
	
	NSArray *currentGame;
	NSMutableArray *boardMap;
	NSInteger gamepakNum, gameNum;
	NSMutableDictionary *savedData;
	NSInteger graphicsMode;
	
	CGPoint touchStartPt, clearPoint;
	CGPoint firCenterPt, secCenterPt;
	CGPoint firEndPt, secEndPt;
	CGPoint firUndoPt, secUndoPt;
	NSMutableArray *horizMoveVec;
	NSMutableArray *vertiMoveVec;
	NSInteger startTileIndex, tagView;
	BOOL hasTileMovedOutOfBounds;
	BOOL hasMovedHoriz, hasMovedVerti;
	BOOL errorCheck;
	int firValue, secValue, totalMatches;
		
	ResetGameController *resetGameController;
}

@property (nonatomic, retain) NSArray *tileIconsNormal;
@property (nonatomic, retain) NSArray *tileIconsNegative;
@property (nonatomic, retain) NSArray *tileViews;
@property (nonatomic, retain) NSArray *tilePath;
@property (nonatomic, retain) UIImageView *currentTileView;
@property (nonatomic, retain) UIImageView *guideView;
@property (nonatomic, retain) NSArray *currentGame;
@property (nonatomic, retain) NSArray *boardMap;
@property (nonatomic, retain) NSMutableDictionary *savedData;
@property NSInteger gamepakNum;
@property NSInteger gameNum;
@property NSInteger graphicsMode;
@property CGPoint touchStartPt;
@property CGPoint clearPoint;
@property CGPoint firCenterPt;
@property CGPoint secCenterPt;
@property CGPoint firEndPt;
@property CGPoint secEndPt;
@property CGPoint firUndoPt;
@property CGPoint secUndoPt;
@property (nonatomic, retain) NSMutableArray *horizMoveVec;
@property (nonatomic, retain) NSMutableArray *vertiMoveVec;


- (int)getIndexFromPoint:(CGPoint)location asRow:(BOOL)row;
- (NSInteger)getTileAtRow:(int)row atCol:(int)col;
- (NSInteger)getTileAtPoint:(CGPoint)location;
- (CGPoint)closestGridCenterTo:(CGPoint)location;
- (CGPoint)getCenterFromIndex:(NSInteger)index;
- (NSInteger)getAdjacencyIndexAt:(NSInteger)index ofSide:(NSInteger)bound;

- (BOOL)checkViewWithTag:(NSInteger)num atPoint:(CGPoint)point;
- (NSInteger)getTagFromPoint:(CGPoint)location;
- (BOOL)setSelectedView:(UIImageView *)currentView atPoint:(CGPoint)location toValue:(int)value;
- (void)clearSelectedView:(UIImageView *)currentView;

- (void)movableRoutesFrom:(NSInteger)index;
- (void)clearRoutes;

- (void)showMovablePathsFrom:(NSInteger)startIndex;
- (void)clearPaths;
- (void)showDraggingPathAt:(CGPoint)location exclude:(NSInteger)index;
- (void)showGuideViewAt:(CGPoint)location;
- (void)debugRoutesWithPathsView;

+ (NSString *)dataFilePath:(NSString *)fileName;
- (void)saveGameData;

- (void)dialogExitGameAction:(NSString *)title;
- (void)dialogGameMenuAction;
- (void)alertGameComplete;
- (void)alertGameReset;
- (void)alertGameMessage:(NSString *)title withMessage:(NSString *)msg;
@end

@interface BoardViewDetail (PrivateMethods)
- (void)initBoard;
- (void)initIconImages;
- (void)initTileViews;
- (void)removeAllTileViews;
- (void)resetGame;

- (void)initPoints;
- (void)resetPoint:(NSInteger)tag;
- (void)saveViewsForUndo;
- (void)clearSavedUndoViews;
- (void)undoViews;
- (void)removeViews;
- (void)cancelViews;
- (void)updateBoardAfterMatch;
- (void)updateBoardAfterMoveFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void)animateView:(CGFloat)scale;

- (CGFloat)getBoundCoordAtHoriz:(BOOL)horiz atMin:(BOOL)bound;
- (CGFloat)checkCoord:(CGFloat)coord withMin:(CGFloat)min withMax:(CGFloat)max;

- (BOOL)areSelectedInAdjacentCells;

@end
