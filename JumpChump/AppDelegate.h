//
//  AppDelegate.h
//  JumpChump
//
//  Created by admin on 3/22/14.
//  Copyright __MyCompanyName__ 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "GCViewController.h"
#import "GameCenterManager.h"
#ifdef FreeVersion
#import <RevMobAds/RevMobAds.h>
#import "Chartboost.h"
#endif
#import <MessageUI/MessageUI.h>



@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate,
GKLeaderboardViewControllerDelegate,GameCenterManagerDelegate, GKAchievementViewControllerDelegate,
#ifdef FreeVersion
RevMobAdsDelegate,ChartboostDelegate,
#endif
MFMailComposeViewControllerDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
#pragma mark GAME_CENTER
    GCViewController* viewController2;
	GameCenterManager* gameCenterManager;
	NSString* currentLeaderBoard;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@property(nonatomic, retain) GCViewController* viewController2;
@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;


- (void) showLeaderboard;

#pragma mark GAME_CENTER

- (void) addOne;
- (void)submitScore;
- (void) showLeaderboard;
- (void) showAchievements;
- (void) initGameCenter;

- (void) abrirLDB;
- (void) abrirACHV;


-(void)ShareFacebook;
-(void)ShareTwitter;
- (IBAction)openMail:(id)sender;


@end
