//
//  MacchiTilesAppDelegate.h
//  MacchiTiles
//
//  Created by Jonathan Lin on 5/18/09.
//  Copyright aeromedia studios 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MacchiTilesAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navController;
	
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;

@end

