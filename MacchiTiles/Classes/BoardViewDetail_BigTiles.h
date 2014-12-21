//
//  BoardViewDetail_BigTiles.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 7/2/09.
//  Copyright 2009 aeromedia studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#define B_MAX_ICONS   12
#define B_MAX_ROWS    8
#define B_MAX_COLS    6
#define B_MAX_TILES   48
#define B_TILE_W      52
#define B_TILE_H      54
#define B_W_BUFFER    4
#define B_H_BUFFER    14
#define B_MAX_MATCHES 24

#define B_UNDO_FIRST  3
#define B_UNDO_SECOND 4
#define B_MT_ERROR    -99

#define B_WEST        1
#define B_NORTH       2
#define B_SOUTH       4
#define B_EAST        8

#define B_kMinimumGestureLength 10
#define B_kMaximumVariance      26

#define B_kSaveFilename @"SavedDataNum.plist"
#define B_kSaveFilesymb @"SavedDataSym.plist"

@class ResetGameController;

@interface BoardViewDetail_BigTiles : UIViewController 
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

@interface BoardViewDetail_BigTiles (PrivateMethods)
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
