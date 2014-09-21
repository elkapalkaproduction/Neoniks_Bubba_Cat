//
//  GamePlayLaer.m
//  JumpChump
//
//  Created by admin on 3/22/14.
//
//

#import "GamePlayLaer.h"
#import "AnimatedText.h"
#import "global.h"
#import "SharedData.h"
#ifdef FreeVersion
#import "Chartboost.h"
#import <RevMobAds/RevMobAds.h>
#endif
#import "AppDelegate.h"
#include <math.h>
#import "Appirater.h"
#import "math.h"
#import "BCGameLogic.h"
#import <AudioToolbox/AudioServices.h>
#import "AboutUsLayer.h"

@interface GamePlayLaer ()

@property(nonatomic)BOOL isGameStartedAlready;

@end

@implementation GamePlayLaer
#define changeThemeAuto YES


#define propellerSpeed 100

#define characterScale 0.4f
#define characterInitialPositionY 72
#define characterSpeedX 4
#define characterMaxSpeedX 100
#define accelerationHorizontalFactor 7.0f
#define characterAccelerationRatioX 1.18f
#define characterMaxIncline 28
#define InclineSpeed 120.0f


#define pipeScaleSize .6
#define spaceBetweenLeftAndRightPipes 170
#define spaceBetweenSetOfPipes  220
#define pipesStartPosY (SCREEN_HEIGHT / 2 + 50)

#define swingScale 1.1f
#define swingOffsetHorizontal -8
#define swingOffsetVertical 29

#define propellerScale 1.3f
#define propellerOffsetHorizontal -3
#define propellerOffsetVertical -8

#define SwingDurationInSeconds 1.5f

#define useCoin YES
#define useOnlyTheFirstCoinImage NO

#define font_size 65.0f
#define fontOffsetY -10
#define fontR   255 // max is 255
#define fontG   255
#define fontB   255
#define scoreShadowOffset (3 * SCALE_X)



#define displayInstructionDuration 3.5
#define TIME_ACT_INTERVAL   0.04f
#define TIME_ACT_INDIVIDUAL 0.14f * SCALE_Y

#define PI 3.14159265
#define DEBUG_MODE_ON NO

+(CCScene *) scene
{
    
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayLaer *layer = [GamePlayLaer node];
	// add layer as a child to scene
	[scene addChild: layer z:1];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]))
    {
		// enable events
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
        preparingNextWave = YES;
        characterPlaying = NO;
        
        
        
        currentCharacterFileName = @"textures/character/character";
        
        /*NSString *selectedChar = [[NSUserDefaults standardUserDefaults] objectForKey:@"CharacterSelected"];
        
        if(selectedChar != nil && [selectedChar caseInsensitiveCompare:@""] != 0)
        {
            if([selectedChar caseInsensitiveCompare:@"character2"] == 0)
            {
                currentCharacterFileName = @"textures/inapp-purchases/character2/character2";
            }
            else if([selectedChar caseInsensitiveCompare:@"character3"] == 0)
            {
                currentCharacterFileName = @"textures/inapp-purchases/character3/character3";
            }
        }*/

        
        [self initLogo];
        [self initPhysics];
        [self initBackground];
        [self CreateGroundAndClouds];
        [self InitializePaddle];
        [self initializeInstructions];
        
        coinTemplate = [CCSprite spriteWithFile:@"textures/coin/coin1.png"];
        [self addChild:coinTemplate z:-10];
        coinTemplate.visible = NO;
        coinTemplate.tag = 0;
        
//        paddle.position = ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, paddle.position.y);
        
        currentSpeed = propellerSpeed * SCALE_Y;
        pipePassedCount = 0;
        timeElapsedSinceLastSpawn = 0;
        currentAlgorithUsedIndex = 0;
        characterDirection = 1;

        algorithmTimeUsedCount = 0;
        algorithmCurrentType = 0;
        pipePassedCount = 0;
        currentCoinIndex = 0;
        
        [self RemoveAllCoins];
        [self InitPipes];
        if(!useCoin)
        {
            [self HideAllCoins];
        }
        [self AnimateHammers];
        [self InitializeThemeColors];
        [self ApplyNewRandomTheme];
        
        [self initAppirater];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        BOOL tutorialAlreadyShown = [prefs boolForKey:@"tutorialAlreadyShown"];
        
        if(!tutorialAlreadyShown)
        {
            [self initTutorial];
            [prefs setBool:YES forKey:@"tutorialAlreadyShown"];
        }
        
        [[SharedData getSharedInstance] playBackground:SOUND_BACK];
        m_btnSound.normalImage = [self soundButtonSprite];
        m_btnSound.selectedImage = [self soundButtonSprite];

        [self createAdmobAds];
	}
	return self;
}

-(void)createAdmobAds
{
#ifdef FreeVersion
    mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    mBannerView.adUnitID = ADMOB_BANNER_ID;
    mBannerView.delegate = nil;
    //adBanner_.frame = CGRectMake(0, winSize.height - 50, winSize.width, 50);
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [mBannerView setRootViewController:[app navController]];
    [[CCDirector sharedDirector].view addSubview:mBannerView];
    
    GADRequest *r = [[GADRequest alloc] init];
    [mBannerView loadRequest:r];
#endif
}

#pragma mark - #yo - initializing sprites
-(void)initLogo
{
    logo = [CCSprite spriteWithFile:@"textures/gui/fp.png"];
    logo.anchorPoint = ccp(0.5f, 0.5f);
    logo.position = ccp((SCREEN_WIDTH) / 2, SCREEN_HEIGHT + (100 * SCALE_Y));
    [self addChild:logo z:10];
}

-(void)initTutorial
{
    tutorial = [CCSprite spriteWithFile:@"textures/instructions.png"];
    [tutorial setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
    [self addChild:tutorial z:11];
}


-(void) initBackground{
//    m_nGamePlayCount = 0;
    
    // background image
    if (IS_IPHONE_5)
    {
        spr_bg = [CCSprite spriteWithFile:@"textures/grounds/bg-568.png"];
    }
    else
    {
        spr_bg = [CCSprite spriteWithFile:@"textures/grounds/bg.png"];
    }
    spr_bg.anchorPoint = ccp(0,0);
    [self addChild:spr_bg z:-1];
    
    
    // menu
    m_btnRate = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_rate.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_rate.png"]
                                                target:self
                                              selector:@selector(onMenuRateAppNow:)];
    
    m_btnPlay = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_play.png"]
                                        selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_play.png"]
                                                target:self
                                              selector:@selector(onMenuPlay:)];
    
    m_btnGameCenter = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_rang.png"]
                                              selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_rang.png"]
                                                      target:self
                                                    selector:@selector(onMenuGameCenter:)];
    
    m_btnSound = [CCMenuItemSprite itemWithNormalSprite:[self soundButtonSprite]
                                            selectedSprite:[self soundButtonSprite]
                                                    target:self
                                                  selector:@selector(onMenuSound:)];
    
    m_btnMore = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_more.png"]
                                           selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_more.png"]
                                                   target:self
                                                 selector:@selector(onMenuMore:)];
    
    m_btnMail = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_mail.png"]
                                                   selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_mail.png"]
                                                           target:self
                                                         selector:@selector(onMenuMail:)];
    
    menuButtonAboutUs = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"textures/gui/b_who_is_booba.png"] selectedSprite:[CCSprite spriteWithFile:@"textures/gui/b_who_is_booba.png"] target:self selector:@selector(showAboutUsPage:)];
    catLogo = [CCSprite spriteWithFile:@"textures/gui/Cat.png"];
    catLogo.anchorPoint = ccp(0.5f, 0.5f);
    catLogo.position = ccp(SCREEN_WIDTH / 2, IS_IPAD ? 331 : 138);
    [self addChild:catLogo z:10];
    
    m_btnPlay.position = ccp(- POS_BUTTON_Y  * SCALE_X, POS_BUTTON_Y * SCALE_Y);
    m_btnRate.position = ccp(SCREEN_WIDTH + POS_BUTTON_Y * SCALE_X , POS_BUTTON_Y * SCALE_Y);
    m_btnGameCenter.position = ccp(POS_BUTTON_Y * 2 * SCALE_X + 15 * SCALE_X, - POS_BUTTON_Y * SCALE_Y);
    m_btnMore.position = ccp(POS_BUTTON_Y * 2 * SCALE_X + 15 * SCALE_X, - POS_BUTTON_Y * SCALE_Y);
    m_btnSound.position = ccp(POS_BUTTON_Y * 2 * SCALE_X + 15 * SCALE_X, - POS_BUTTON_Y * SCALE_Y);
    m_btnMail.position = ccp(POS_BUTTON_Y * 2 * SCALE_X + 15 * SCALE_X, - POS_BUTTON_Y * SCALE_Y);
    
    menuButtonAboutUs.position =ccp(SCREEN_WIDTH / 2 , (POS_BUTTON_Y + 1000) * SCALE_Y);
    
    
    CCMenu* menu = [CCMenu menuWithItems:m_btnPlay, m_btnRate, m_btnGameCenter, m_btnSound, m_btnMore, m_btnMail, menuButtonAboutUs, nil];
    menu.position = CGPointZero;
    if(IS_IPHONE_5)
    {
        [menu setPosition:ccp(menu.position.x, menu.position.y - 35)];
    }
    [self addChild:menu z:15];
    //[self disableMenu];
    
    // add score
    m_HighScore = [SharedData getHighScore];

    m_lblScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", currentScore] fontName:FontName fontSize:font_size];
    m_lblScore.color = ccc3(fontR, fontG, fontB);
    m_lblScore.anchorPoint = ccp(0.5, 0.5);
    m_lblScore.scale = SCALE_X;
    m_lblScore.opacity = 0;
    [self addChild:m_lblScore z:10];
    
    m_lblScoreShadow = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", currentScore] fontName:FontName fontSize:font_size];
    m_lblScoreShadow.color = ccc3(0, 0, 0);
    m_lblScoreShadow.anchorPoint = ccp(0.5, 0.5);
    m_lblScoreShadow.scale = SCALE_X;
    m_lblScoreShadow.opacity = 0;
    [self addChild:m_lblScoreShadow z:9];
    
    m_lblScoreTitle = [CCLabelTTF labelWithString:@"last score" fontName:FontName fontSize:font_size/ 4];
    m_lblScoreTitle.anchorPoint = ccp(0.5, 0.5);
    m_lblScoreTitle.color = ccc3(fontR, fontG, fontB);
    m_lblScoreTitle.scale = SCALE_X;
    m_lblScoreTitle.position = CGPointZero;
    m_lblScoreTitle.opacity = 0;
    [self addChild:m_lblScoreTitle z:10];
    
    m_lblScoreTitleShadow = [CCLabelTTF labelWithString:@"last score" fontName:FontName fontSize:font_size/ 4];
    m_lblScoreTitleShadow.anchorPoint = ccp(0.5, 0.5);
    m_lblScoreTitleShadow.color = ccc3(0, 0, 0);
    m_lblScoreTitleShadow.scale = SCALE_X;
    m_lblScoreTitleShadow.position = CGPointZero;
    m_lblScoreTitleShadow.opacity = 0;
    [self addChild:m_lblScoreTitleShadow z:9];
    
    m_lblHighScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_HighScore] fontName:FontName fontSize:font_size];
    m_lblHighScore.color = ccc3(fontR, fontG, fontB);
    m_lblHighScore.anchorPoint = ccp(0.5, 0.5);
    m_lblHighScore.scale = SCALE_X;
    m_lblHighScore.opacity = 0;
    [self addChild:m_lblHighScore z:10];
    
    m_lblHighScoreTitle= [CCLabelTTF labelWithString:@"best score" fontName:FontName fontSize:font_size/4];
    m_lblHighScoreTitle.anchorPoint = ccp(0.5, 0.5);
    m_lblHighScoreTitle.color = ccc3(fontR, fontG, fontB);
    m_lblHighScoreTitle.position = CGPointZero;
    m_lblHighScoreTitle.scale = SCALE_X;
    m_lblHighScoreTitle.opacity = 0;
    [self addChild:m_lblHighScoreTitle z:10];
    
    m_lblHighScoreTitleShadow= [CCLabelTTF labelWithString:@"best score" fontName:FontName fontSize:font_size/4];
    m_lblHighScoreTitleShadow.anchorPoint = ccp(0.5, 0.5);
    m_lblHighScoreTitleShadow.color = ccc3(0, 0, 0);
    m_lblHighScoreTitleShadow.position = CGPointZero;
    m_lblHighScoreTitleShadow.scale = SCALE_X;
    m_lblHighScoreTitleShadow.opacity = 0;
    [self addChild:m_lblHighScoreTitleShadow z:9];
    
    
    m_lblHighScoreShadow = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_HighScore] fontName:FontName fontSize:font_size];
    m_lblHighScoreShadow.color = ccc3(0, 0, 0);
    m_lblHighScoreShadow.anchorPoint = ccp(0.5, 0.5);
    m_lblHighScoreShadow.scale = SCALE_X;
    m_lblHighScoreShadow.opacity = 0;
    [self addChild:m_lblHighScoreShadow z:9];
    
    // add menu
    [self showBarAnimNonPlay];
}

-(void) showBarAnimNonPlay{
    [self showTitleMenu];
    
    float globalOffset=0;
    
    if ([UIScreen mainScreen].bounds.size.height==568) {
        globalOffset=50;
    }else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            globalOffset=100;
        }else{
            globalOffset=60;
        }
    }
    
    [m_lblScore runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_LEFT.x, POS_SCORE_LEFT.y +globalOffset)]];
    [m_lblScoreShadow runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_LEFT.x + scoreShadowOffset, POS_SCORE_LEFT.y - scoreShadowOffset +globalOffset)]];
    [m_lblScoreTitle runAction:[CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_LEFT.x,POS_SCORE_LEFT.y - m_lblScore.contentSize.width - 7 * SCALE_Y +globalOffset)]];
    [m_lblScoreTitleShadow runAction:[CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_LEFT.x + (1 * SCALE_X),POS_SCORE_LEFT.y - m_lblScore.contentSize.width - 7 * SCALE_Y -(1 * SCALE_Y)+globalOffset)]];
    
    [m_lblHighScore runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_RIGHT.x, POS_SCORE_RIGHT.y - scoreShadowOffset+globalOffset)]];
    [m_lblHighScoreShadow runAction: [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_RIGHT.x + scoreShadowOffset, POS_SCORE_RIGHT.y - scoreShadowOffset +globalOffset)]];
    [m_lblHighScoreTitle runAction:[CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_RIGHT.x,POS_SCORE_RIGHT.y - m_lblScore.contentSize.width - 7 * SCALE_Y +globalOffset)]];
    [m_lblHighScoreTitleShadow runAction:[CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_RIGHT.x + (1 * SCALE_X),POS_SCORE_RIGHT.y - m_lblScore.contentSize.width - 7 * SCALE_Y - (1 * SCALE_Y) +globalOffset)]];
    
    
    m_lblScoreTitle.visible = m_lblScoreTitleShadow.visible = m_lblHighScoreShadow.visible = m_lblHighScoreTitle.visible = m_lblHighScoreTitleShadow.visible = m_lblHighScore.visible = YES;

}


-(void) showTitleMenu
{
    
    if ([BCGameLogic sharedLogic].gameLaunches == 0 || [BCGameLogic sharedLogic].gameLaunches % kNumberOfPlayedGamesForAds==0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showADS) userInfo:nil repeats:NO];
        //[self showADS];
    }
    
    
    [m_btnRate setAnchorPoint:ccp(0.f,0.f)];
    [m_btnGameCenter setAnchorPoint:ccp(0.f,0.f)];
    [m_btnPlay setAnchorPoint:ccp(0.5f,0.5f)];
    [m_btnSound setAnchorPoint:ccp(0.f,0.f)];
    [m_btnMore setAnchorPoint:ccp(0.f,0.f)];
    [m_btnMail setAnchorPoint:ccp(0.f,0.f)];
    [menuButtonAboutUs setAnchorPoint:ccp(0.5f,0.5f)];
    
    
    float offsetForAboutUsButton=0;
    float logoPosition = SCREEN_HEIGHT - logo.boundingBox.size.height - (30 * SCALE_Y);
    float bottoMenuVerticalOffset = 0;
    if (IS_IPHONE_5) {
        offsetForAboutUsButton = -50;
        bottoMenuVerticalOffset = m_btnRate.boundingBox.size.height + 3;
    }else{
        if (IS_IPAD){
            offsetForAboutUsButton = -100;
        }else{
            offsetForAboutUsButton = -50;
        }
    }
    
    [m_btnRate runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH - m_btnRate.boundingBox.size.width, bottoMenuVerticalOffset + m_btnRate.boundingBox.size.height)]];
    
    [m_btnGameCenter runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, bottoMenuVerticalOffset + m_btnGameCenter.boundingBox.size.height)]];
    
    [menuButtonAboutUs runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH / 2 , SCREEN_HEIGHT / 3 + offsetForAboutUsButton)]];
    
    [m_btnPlay runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH / 2, logoPosition - 1.5 * m_btnPlay.boundingBox.size.height)]];
    
    
    [m_btnMore runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, bottoMenuVerticalOffset)]];
    
    [m_btnSound runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, logoPosition + bottoMenuVerticalOffset * 1.1)]];
    
    
    [m_btnMail runAction:[CCMoveTo actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH - m_btnMail.boundingBox.size.width, bottoMenuVerticalOffset)]];
    
    [logo runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.8f position:ccp(SCREEN_WIDTH / 2, logoPosition)],
                     [CCCallFunc actionWithTarget:self selector:@selector(enableMenu)], nil]];
    // show high score
    m_lblHighScore.string = [NSString stringWithFormat:@"%d", m_HighScore];
    //CGPoint highScorePos = ccp(scoreFrame.position.x + 20 * SCALE_X, scoreBestFrame.position.y +  + (1 * SCALE_Y));
    //CGPoint highScoreFramePos = ccp(scoreFrame.position.x, scoreBestFrame.position.y);
    //[m_lblHighScore runAction:[CCMoveTo actionWithDuration:0.4f position:highScorePos]];
    //[scoreBestFrame runAction:[CCMoveTo actionWithDuration:0.4f position:highScoreFramePos]];
    
}

-(void) hideTitleMenu
{
    //[self disableMenu];
    //[text upAnimation];
    id actionMoveTextUp = [CCMoveTo actionWithDuration:0.8f position:ccp(SCREEN_WIDTH / 2, 16 * SCREEN_HEIGHT / 12)];
    [logo runAction:actionMoveTextUp];
    
    
    [m_btnRate runAction:[CCSequence actions:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, -SCREEN_HEIGHT * 0.9f)],
                          [CCCallFunc actionWithTarget:self selector:@selector(readyGame1)], nil]];
    [m_btnGameCenter runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(0, -SCREEN_HEIGHT * 0.9f)]];
    [m_btnPlay runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    [m_btnMore runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    [m_btnSound runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    [m_btnMail runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    
    [menuButtonAboutUs runAction:[CCMoveBy actionWithDuration:TIME_BUTTON_ACTION position:ccp(SCREEN_WIDTH, 0)]];
    
    
}

#pragma  mark Buttons

-(void)showAboutUsPage:(id)sender{
    if (!self.isGameStartedAlready) {
#ifdef FreeVersion
        [mBannerView removeFromSuperview];
        [[RevMobAds session] hideBanner];
#endif
        [[CCDirector sharedDirector] pushScene:[AboutUsLayer scene]];
    }
}

-(void) onMenuPlay:(id)sender{
    //    [self InitializePaddle];
    if (!self.isGameStartedAlready) {
        self.isGameStartedAlready=YES;
        m_nGameMode = MODE_PLAY;
        [self hideTitleMenu];
        [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
    }
}

-(void) onMenuSetting:(id)sender{
    /*if (IS_IPAD) {
        vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController_ipad" bundle:nil];
    }
    else{
        if (IS_IPHONE_5) {
            vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController_568" bundle:nil];
        }
        else{
            vc = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        }
    }
//    [[CCDirector sharedDirector].view addSubview:vc.view];
    id appDelegate = [(AppController*) [UIApplication sharedApplication] delegate];
    [((AppController*)appDelegate).navController presentViewController:vc animated:YES completion:nil];
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];*/
}

-(void) onMenuGameCenter:(id)sender
{
    if (!self.isGameStartedAlready) {
        id appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
        [appDelegate showLeaderboard];
        [[SharedData getSharedInstance] playSoundEffect:EFFECT_BUTTON];
    }
}


-(void)onMenuSound:(id)sender
{
    if ([[SharedData getSharedInstance] isBackgroundMusicPlaying]) {
        [[SharedData getSharedInstance] pauseBackgroud];
    } else {
        [[SharedData getSharedInstance] playBackground:SOUND_BACK];
    }
    
    m_btnSound.normalImage = [self soundButtonSprite];
    m_btnSound.selectedImage = [self soundButtonSprite];
}

-(void)onMenuMore:(id)sender
{
#ifdef FreeVersion
    [[Chartboost sharedChartboost] showMoreApps:CBLocationMainMenu];
#endif
}

-(void)onMenuMail:(id)sender
{
    if (!self.isGameStartedAlready) {
        AppController* appDelegate = (AppController*) [[UIApplication sharedApplication] delegate];
        [appDelegate openMail:nil];
    }
    
}


#pragma mark #yo - Game plays when the play button is pressed then launched readyGame2
#pragma mark GamePlay
-(void) readyGame1{
    [self readyGame2];
    m_lblScore.opacity = 255;
    m_lblScoreTitle.opacity = 255;
    m_lblScoreTitleShadow.opacity = 255;
    m_lblScoreShadow.opacity = 255;
    
    m_lblHighScore.opacity = m_lblHighScoreShadow.opacity = m_lblHighScoreTitle.opacity = m_lblHighScoreTitleShadow.opacity = 255;
    m_lblScore.position = POS_SCORE_HIDDEN;
    m_lblScoreShadow.position = POS_SCORE_HIDDEN;
    m_lblScoreTitle.position = POS_SCORE_HIDDEN;
    m_lblScoreTitleShadow.position = POS_SCORE_HIDDEN;
    m_lblHighScore.position = m_lblHighScoreShadow.position = m_lblHighScoreTitle.position = m_lblHighScoreTitleShadow.position = POS_SCORE_HIDDEN;
}

-(void) readyGame2
{
    m_bActJump = NO;
    m_bActChump = NO;
    if (m_nGameMode == MODE_PLAY)
    {
        [self startGame];
    }
    else
    {
        // Would launch a tutorial mode here
    }
}

-(void) startGame
{
    paddle.opacity =255;
    propeller.opacity=255;
    catLogo.visible = NO;
    //        [self InitializePaddle];
    if(paddle.scaleX < 0)
    {
        paddle.scaleX = -1 * paddle.scaleX;
    }
    currentCharacterSpeedX = 0;
    currentIncline = 0;
    currentInclineAcceleration = characterAccelerationRatioX;
    currentCoinIndex = 0;
    characterPlaying = NO;
    soundElapsed = 0;
    [self ShowInstructions];
    
    
    if(tutorial != nil)
    {
        [tutorial setVisible:NO];
    }
    
    currentScore = 0;
    currentSpeed = propellerSpeed * SCALE_Y;
    pipePassedCount = 0;
    timeElapsedSinceLastSpawn = 0;
    currentAlgorithUsedIndex = 0;
    characterDirection = 1;
    algorithmTimeUsedCount = 0;
    algorithmCurrentType = 0;
    pipePassedCount = 0;
    downIterationCount = 0;
    
    [paddle stopAllActions];
    paddle.position = ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, paddle.position.y);
    
    
    id seq = [CCSequence actionOne:[CCMoveTo actionWithDuration:0.8f position:ccp(SCREEN_WIDTH/2, characterInitialPositionY * SCALE_Y)] two:[CCCallFunc actionWithTarget:self selector:@selector(AnimationIdle)]];
    [paddle runAction:seq];
    //AnimationIdle
    
    [paddle runAction:[CCRotateTo actionWithDuration:0.4f angle:0]];
    //        if(m_nGamePlayCount > 0)
    if ([BCGameLogic sharedLogic].gameLaunches>0) {
        
        [self RemoveAllCoins];
        
        [self RemoveAllPipes];
        [self InitPipes];
        if(!useCoin)
        {
            [self HideAllCoins];
        }
        [self AnimateHammers];
        
        [self RunPropellerAnimation];
        [self AnimationAlive];
        [self ApplyNewRandomTheme];
    }
    
    
    m_nGameMode = MODE_PLAY;
    m_bGamePlaying = YES;
    m_Score = 0;
    m_fReadyTime = TIME_READY + (arc4random() % 5 - 2) * 0.1f;
    m_fEnemyInterval = TIME_ENEMY_INTERVAL;
    m_fCounter = 0.0f;
    
    [m_lblScore runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.5f + TIME_BAR_SCALE],
                           [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:POS_SCORE_TOP],
                           nil]];
    
    [m_lblScoreShadow runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:0.5f + TIME_BAR_SCALE],
                                 [CCMoveTo actionWithDuration:TIME_BAR_SCALE position:ccp(POS_SCORE_TOP.x + scoreShadowOffset, POS_SCORE_TOP.y - scoreShadowOffset)],
                                 nil]];
    
    m_lblScoreTitle.visible = NO;
    m_lblScoreTitleShadow.visible = NO;
    m_lblHighScoreTitle.visible = m_lblHighScoreTitleShadow.visible = m_lblHighScore.visible = m_lblHighScoreShadow.visible = NO;
    
    [self PlayRotorSound];
    
    [self scheduleUpdate];
    //    }
}

-(void)GO
{
    [paddle stopAllActions];
    [self RunPropellerAnimation];
    characterPlaying = YES;
}


#pragma mark ENABLE / DISABLE
-(void) enableMenu{
    m_btnGameCenter.isEnabled = YES;
    m_btnRate.isEnabled = YES;
    m_btnPlay.isEnabled = YES;
    menuButtonAboutUs.isEnabled=YES;
}

-(void) disableMenu{
    m_btnGameCenter.isEnabled = NO;
    m_btnRate.isEnabled = NO;
    m_btnPlay.isEnabled = NO;
    menuButtonAboutUs.isEnabled =NO;
}


// timer
-(void) update:(ccTime)dt
{
    if (m_bGamePlaying)
    {
        timeSpentOnSameDirection += dt;
        if(instructions.visible)
        {
            return;
        }
        if([self CharacterTouchedBounds])
        {
            [self ItemAnimationCrash:nil];
            m_bGamePlaying = NO;
            m_bShowGameOver = NO;
            [[SharedData getSharedInstance] playSoundEffect:EFFECT_EXPLOSION];
            return;
        }
        
        currentInclineAcceleration *= characterAccelerationRatioX;
        if(characterDirection == 1)
        {
            currentIncline += InclineSpeed * dt;
            if(currentInclineAcceleration < 0)
            {
                currentInclineAcceleration *= -1;
            }
        }
        else
        {
            currentIncline -= InclineSpeed * dt;
            if(currentInclineAcceleration > 0)
            {
                currentInclineAcceleration *= -1;
            }
        }
        
        
        if(fabs(currentIncline) > characterMaxIncline)
        {
            if(currentIncline > 0)
            {
                currentIncline = characterMaxIncline + currentCharacterSpeedX;
            }
            else
            {
                currentIncline = -1 * characterMaxIncline - currentCharacterSpeedX;
            }
        }
        ;
        
        
        float incrementX = (timeSpentOnSameDirection * accelerationHorizontalFactor * SCALE_X );
        float finalSpeedX = currentIncline * ( (characterSpeedX * SCALE_X) + incrementX);
        
        
        paddle.rotation = currentIncline;
        paddle.position = ccp(paddle.position.x + (finalSpeedX * dt) , paddle.position.y);
        
        CCSprite *itemMissed = [self PlayerHasCollidedWithPipes];
        if(DEBUG_MODE_ON)
        {
            itemMissed = nil;
        }
        if(itemMissed != nil)
        {
            [self ItemAnimationCrash:itemMissed];
            m_bGamePlaying = NO;
            m_bShowGameOver = NO;
            [[SharedData getSharedInstance] playSoundEffect:EFFECT_EXPLOSION];
            
        }
        else
        {
            if(characterPlaying)
            {
                CCSprite *grabbedCoin = [self CharacterGrabbedCoin];
                if(grabbedCoin != nil)
                {
                    currentScore += 1;
                    grabbedCoin.visible = NO;
                    [[SharedData getSharedInstance] playSoundEffect:SOUND_BONUS];
                }
                
                soundElapsed += dt;
                if(soundElapsed > 4.0f)
                {
                    soundElapsed = 0;
                    [self PlayRotorSound];
                }
                [self BringPipesDown:dt];
                [self RemoveCoinExpired];
                [self RemovePipesExpired];
                
                
                timeElapsedSinceLastSpawn += dt;
                m_fCounter += dt;
                m_Score = m_fCounter;
                if (m_HighScore < currentScore) {
                    m_HighScore = currentScore;
                    m_lblHighScore.string = m_lblHighScoreShadow.string = [NSString stringWithFormat:@"%d", m_HighScore];
                }
                m_lblScore.string = m_lblScoreShadow.string = [NSString stringWithFormat:@"%d", currentScore];
            }
        }
    }
    else
    {
        [self schedule:@selector(onTimeShowGameOver) interval:(float)((SCREEN_WIDTH + 100 * SCALE_X) / SPEED_BLOCK + 0.5f)];
        BOOL flag = NO;
        for (CCSprite* temp in [self children]) {
            if (temp.tag == TAG_ENEMY) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [self onTimeShowGameOver];
        }
    }
    
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(dt, velocityIterations, positionIterations);
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != nil) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            CGPoint pos = myActor.position;
            float ang = -myActor.rotation / 180 * M_PI;
            b->SetTransform(b2Vec2(pos.x / PTM_RATIO, pos.y / PTM_RATIO), ang);
        }
	}

}


-(void) onTimeShowGameOver
{
    if (!m_bShowGameOver)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        m_bShowGameOver = YES;
        [BCGameLogic sharedLogic].gameLaunches++;
        
        [self showBarAnimNonPlay];
        
        [self AnimationDeath];
        [self BringBackgroundUp];
        [self RemoveAllCoins];
        [self StopRotorSound];
        
        self.isGameStartedAlready=NO;
        
        //[self StopHammers];
        [SharedData setHighScore:m_HighScore];
        id appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
        [appDelegate submitScore];
        [self unscheduleUpdate];
        [self unschedule:_cmd];
    }
    else {
        [self unschedule:_cmd];
    }
}

#pragma mark Touch

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bGamePlaying)
    {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInView: [touch view]];
            CGPoint touch_location = [[CCDirector sharedDirector] convertToGL:location];
            if(!touchDown)
            {
                touchDown = YES;
                if(instructions.visible)
                {
                    instructions.visible = NO;
                    timeSpentOnSameDirection = 0;
                    [self GO];
                }
                else
                {
                    currentCharacterSpeedX = 0;
                    characterDirection = characterDirection * -1;
                    paddle.scaleX = -1 * paddle.scaleX;
                    if(paddle.scaleX < 0)
                    {
                        //paddle.position = ccp(paddle.position.x + paddle.contentSize.width/2, paddle.position.y);
                        currentInclineAcceleration = characterAccelerationRatioX * -1;
                        timeSpentOnSameDirection = 0;
                    }
                    else
                    {
                        //paddle.position = ccp(paddle.position.x - paddle.contentSize.width/2, paddle.position.y);
                        currentInclineAcceleration = characterAccelerationRatioX * -1;
                        timeSpentOnSameDirection = 0;
                    }
                    touch_location_initialX = touch_location.x;
                    paddleInitialPosX = paddle.position.x;
                    [[SharedData getSharedInstance] playSoundEffect:EFFECT_JUMP];
                }
            }
        }
    }
    else
    {
#pragma mark #yo tutorial logic
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (m_bGamePlaying && touchDown)
    {
        /*for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInView: [touch view]];
            CGPoint touch_location = [[CCDirector sharedDirector] convertToGL:location];
            float paddlePosX = paddleInitialPosX + (touch_location.x - touch_location_initialX);
            
            paddle.position = ccp( paddlePosX, paddle.position.y);
            //[[SharedData getSharedInstance] playSoundEffect:EFFECT_JUMP];
        }*/
    }

}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchDown = NO;
}

// ads
-(void) showADS{
#ifdef FreeVersion
    [[Chartboost sharedChartboost] showInterstitial:CBLocationGameOver];
    [[RevMobAds session] showFullscreen];
#endif
}

-(void) initPhysics
{
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
//	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	// Define the ground body.
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();
	
	kmGLPopMatrix();
    
    
    /////
    //glColor4f(0, 1.0, 0, 1.0);
    /*glLineWidth(2.0f);
    
    CGRect pathBox = CGRectMake(paddle.position.x - (paddle.contentSize.width/2), paddle.position.y - (paddle.contentSize.height/2), paddle.contentSize.width, paddle.contentSize.height);
    
    //CGRect pathBox = CGRectMake(paddle.position.x - (paddle.contentSize.width/2), paddle.position.y - (paddle.contentSize.height/2), paddle.contentSize.width, paddle.contentSize.height);
    CGPoint verts[4] = {
        ccp(pathBox.origin.x, pathBox.origin.y),
        ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y),
        ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y + pathBox.size.height),
        ccp(pathBox.origin.x, pathBox.origin.y + pathBox.size.height)
    };
    
    ccDrawPoly(verts, 4, YES);*/
    /////
}

-(void) removeAllBodies{
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        b->SetUserData(nil);
        world->DestroyBody(b);
    }
}
-(b2World*) getWorld{
    return world;
}


-(void) dealloc
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    
    [self removeAllBodies];
    delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	delete contactListener;
    contactListener = NULL;
	[super dealloc];
}

-(void) addBody:(CCSprite*)spr{
    CGSize sz = [spr boundingBox].size;
    CGPoint p = spr.position;
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2FixtureDef fixtureDef_bullet;
    b2Body* body = world->CreateBody(&bodyDef);
    
    b2PolygonShape box;
    box.SetAsBox(sz.width / (2 * PTM_RATIO), sz.height / (2 * PTM_RATIO));
    fixtureDef_bullet.shape = &box;
    fixtureDef_bullet.density = 0.1f;
    fixtureDef_bullet.friction = 0.1f;
    fixtureDef_bullet.restitution = 0.1f;
    body->CreateFixture(&fixtureDef_bullet);
    body->SetUserData(spr);
//    spr.opacity = 30;
}


-(void)onMenuRateAppNow:(id)sender
{
    if (!self.isGameStartedAlready) {
        [Appirater setAppId:APPLE_APP_ID];
        [Appirater rateApp];
    }
}


-(void)initAppirater
{
    [Appirater setAppId:APPLE_APP_ID];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

-(CCSprite*)PlayerHasCollidedWithPipes
{
    //CGRect paddleArea = paddle.boundingBox;
    
    for(CCSprite *item in [self children])
    {
        if(item.tag >= 1000)
        {
            
            //CGRect validPaddleArea = CGRectMake(paddle.position.x + (0.2 * paddle.boundingBox.size.width) , paddle.position.y + (0.2 * paddle.boundingBox.size.height), 0.6 * paddle.boundingBox.size.width, 0.6 * paddle.boundingBox.size.height);
            
            
            CGRect validPaddleArea = CGRectMake(paddle.position.x - (0.4 * paddle.boundingBox.size.width) , paddle.position.y - (0.4 * paddle.boundingBox.size.height), 0.8 * paddle.boundingBox.size.width, 0.8 * paddle.boundingBox.size.height);
            
            //CGRect validFallingItemArea = CGRectMake(item.position.x + 0.1 * item.boundingBox.size.width, item.position.y, 0.8 * item.boundingBox.size.width, 0.9 * item.boundingBox.size.height);
            
            /*CGRect itemRect = CGRectMake(item.position.x - item.contentSize.width, item.position.y - item.contentSize.height/2, item.contentSize.width, item.contentSize.height);
            if(CGRectIntersectsRect(validPaddleArea, itemRect))
            {
                return item;
            }*/
            
            if(CGRectIntersectsRect(validPaddleArea, item.boundingBox))
            {
                return item;
            }
            
            CCSprite *hammer = [item.children objectAtIndex:0];
            
            if([self characterCollidedWithSwing:hammer])
            {
                return item;
            }
            
        }
    }
    return nil;
}



-(void)InitializePaddle
{
    //[NSString stringWithFormat:@"%@-idle.png", currentCharacterFileName]
    //paddle = [CCSprite spriteWithFile:@"textures/character/character.png"];
    [propeller removeFromParentAndCleanup:YES];
    [paddle removeFromParentAndCleanup:YES];
    paddle = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", currentCharacterFileName]];
    [self addChild:paddle z:5];
    paddle.tag = -100;
//    paddle.tag = 0;
    paddle.anchorPoint = ccp(0.5f,0.5f);
    [paddle setPosition:ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, ground.boundingBox.size.height/2)];
    [paddle setScale:characterScale];
    paddle.position = ccp(SCREEN_WIDTH / 2 - paddle.boundingBox.size.width / 2, paddle.position.y);
    paddle.opacity =0;
    [self AddPropeller];
}

-(void)initializeInstructions
{
    instructions = [CCSprite spriteWithFile:@"textures/instructions.png"];
    [self addChild:instructions z:9];
    paddle.tag = 0;
    instructions.opacity = 255;
    [instructions setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT/2)];
    instructions.visible = NO;
}

-(void)ShowInstructions
{
    instructions.visible = YES;
}

-(void)ItemAnimationCrash:(CCSprite*)item
{
    //[item stopAllActions];
    [item runAction:[CCBlink actionWithDuration:3.0f blinks:13]];
}


-(void)InitPipes
{
    tmpInc = 0;
    currentHorizontalSpaceBetweenPipes = spaceBetweenLeftAndRightPipes * SCALE_X;
    finalDistanceBetweenSetOfPipes = (spaceBetweenSetOfPipes * SCALE_Y);
    /*if(IS_RETINA)
    {
        currentHorizontalSpaceBetweenPipes *= 2;
    }*/
    
    pipePassedCount = 0;
    CCSprite *pipeSpriteRight, *pipeSpriteLeft;
    for(float i = 0; i < pipesMaxCount; i += 1.0f)
    {
        tmpInc += 10.0f;
        pipeCurrentHorizontalOffsetVariation = [self GetNextPipesOffsetX];
        if(arc4random() % 10 >= 5)
        {
            pipeCurrentHorizontalOffsetVariation = -1 * pipeCurrentHorizontalOffsetVariation;
        }
        
        pipeSpriteLeft = [CCSprite spriteWithFile:@"textures/pipes/wall_horizontal.png"];
        pipeSpriteLeft.anchorPoint = ccp(1.0f, 0.5f);
        [pipeSpriteLeft setScale:pipeScaleSize];
        [self addChild:pipeSpriteLeft z:3];
        pipeSpriteLeft.position = ccp(SCREEN_WIDTH / 2 - currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation, (pipesStartPosY * SCALE_Y) + i * finalDistanceBetweenSetOfPipes);
        pipeSpriteLeft.tag = 1000;
        
        [self AddHammerToPipe:pipeSpriteLeft];
        
        pipeSpriteRight = [CCSprite spriteWithFile:@"textures/pipes/wall_horizontal.png"];
        pipeSpriteRight.anchorPoint = ccp(1.0f, 0.5f);
        [pipeSpriteRight setScale:pipeScaleSize];
        [pipeSpriteRight setScaleX:pipeScaleSize * -1];
        [self addChild:pipeSpriteRight z:3];
        pipeSpriteRight.position = ccp((SCREEN_WIDTH / 2)  + currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation, (pipesStartPosY * SCALE_Y) + i * finalDistanceBetweenSetOfPipes );
        pipeSpriteRight.tag = 1001;
        
        [self AddHammerToPipe:pipeSpriteRight];
        
        [self AddCoinAtPosition:ccp(SCREEN_WIDTH / 2 + pipeCurrentHorizontalOffsetVariation, (pipesStartPosY * SCALE_Y) + i * finalDistanceBetweenSetOfPipes)];
        
        
        pipePassedCount++;
        //lastExpiredPipePosY = pipeSpriteRight.position.y;
    }
    
    
}


-(void)RemovePipesExpired
{
    int markedCount = 0;
    for(CCSprite *item in [self children])
    {
        if(item.tag == 1000)
        {
            if(item.position.y < -200)
            {
                item.tag = -1000;
                markedCount++;
            }
        }
        if(item.tag == 1001)
        {
            if(item.position.y < -200)
            {
                item.tag = -1001;
                markedCount++;
            }
        }
    }
    
    
    int currentMark = 0;
    float posXLeft = 0;
    float posXRight = 0;
    float posY = 0;
    float pipesPassedThisTurn = 0;
    
    for(CCSprite *item in [self children])
    {
        if(item.tag == -1000)
        {
            posY = [self getposYOfHighestPipe] + finalDistanceBetweenSetOfPipes;
            posXLeft = SCREEN_WIDTH / 2 - currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation;
            [item setPosition:ccp(posXLeft, posY)];
            //[item setPosition:ccp(item.position.x, posY )];
            item.tag = 1000;
            pipesPassedThisTurn++;
            
        }
        
        if(item.tag == -1001)
        {
            posXRight = (SCREEN_WIDTH / 2)  + currentHorizontalSpaceBetweenPipes / 2 + pipeCurrentHorizontalOffsetVariation;
            [item setPosition:ccp(posXRight, posY )];
            item.tag = 1001;
            pipesPassedThisTurn++;
            
            
        }
        currentMark++;
        if(pipesPassedThisTurn == 2)
        {
            pipePassedCount++;
            pipesPassedThisTurn = 0;
            
            lastExpiredPipePosX = posXLeft + (posXRight - posXLeft)/2;
            lastExpiredPipePosY = posY;
        }
        
    }
}



-(void)RemoveCoinExpired
{
    for(CCSprite *item in [self children])
    {
        if(item.tag == TAG_COIN)
        {
            if(item.position.y < -300)
            {
                float posY = [self getposYOfHighestPipe];
                if(lastExpiredPipePosX == 0)
                {
                    lastExpiredPipePosX = SCREEN_WIDTH /2;
                }
                item.position = ccp( lastExpiredPipePosX, posY);
                if(useCoin)
                {
                    item.visible = YES;
                }
                else
                {
                    item.visible = NO;
                    item.anchorPoint = ccp(0.5f,0.5f);
                }
            }
        }
    }
}


-(float)getposYOfHighestPipe
{
    float highestPosY = SCREEN_HEIGHT;
    for(CCSprite *item in [self children])
    {
        if(item.tag == 1000)
        {
            if(item.position.y > highestPosY)
            {
                highestPosY = item.position.y;
            }
        }
    }
    return highestPosY;
}

-(void)BringPipesDown:(float)dt
{
    downIterationCount += 1;
    float thisCurrentSpeed =  currentSpeed * dt;

    for(CCSprite *item in [self children])
    {
        if(item.tag >= 1000 || item.tag == TAG_COIN)
        {
            [item setPosition:ccp(item.position.x, item.position.y - thisCurrentSpeed)];
        }
    }
    
    [self MoveBackgroundDownBy:thisCurrentSpeed];
    
}

-(void)ResetPaddleOriginalPosition
{
    
}

-(void)RemoveAllPipes
{
    BOOL itemFound = NO;
    BOOL continuing = YES;
    while (continuing)
    {
        continuing = NO;
        itemFound = NO;
        for(CCSprite *item in [self children])
        {
            if(item.tag == 1000 || item.tag == 1001 || item.tag == -1000 || item.tag == -1001)
            {
                itemFound = YES;
                if([item.children count] > 0)
                {
                    CCNode *nd = [[item children] objectAtIndex:0];
                    [item removeChild:nd cleanup:YES];
                }
                [self removeChild:item cleanup:YES];

                break;
            }
        }
        if(itemFound)
        {
            continuing = YES;
        }
    }
    
}

-(void)AddHammerToPipe:(CCSprite*)pipe
{
    
    CCSprite *swing = [CCSprite spriteWithFile:@"textures/swing/swing.png"];
    swing.anchorPoint = ccp(0.5f, 1.1f);
    [pipe addChild:swing z:9];
    swing.scale = swingScale;
    
    //float posY =  -1 *  pipe.contentSize.height / 3;
    float posY =  0;

    swing.position = ccp( 9.5f * pipe.contentSize.width / 10 + swingOffsetHorizontal * SCALE_X, posY + swingOffsetVertical * SCALE_Y);
    swing.rotation = -35.0f;
    swing.tag = TAG_SWING_LEFT;
    if(pipe.scaleX < 0)
    {
        swing.rotation = 35.0f;
        swing.tag = TAG_SWING_RIGHT;
    }
    
    [self AddCollisionDotsToHammer:swing];
    
    
    
    
}

-(void)AnimateHammers
{
    float secs = SwingDurationInSeconds;
    for(CCSprite *pipe in self.children)
    {
        if(pipe.tag == 1000)
        {
            CCSprite *item = [pipe.children objectAtIndex:0];
            id actionLeft = [CCRotateBy actionWithDuration:secs angle:-70];
            id actionRight = [CCRotateBy actionWithDuration:secs angle:70];
            id seq = [CCSequence actions:actionRight, actionLeft, nil];
            CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:seq];
            [item runAction:repeatingAnimation];
        }
        else if(pipe.tag == 1001)
        {
            CCSprite *item = [pipe.children objectAtIndex:0];
            id actionLeft = [CCRotateBy actionWithDuration:secs angle:-70];
            id actionRight = [CCRotateBy actionWithDuration:secs angle:70];
            id seq = [CCSequence actions:actionLeft,actionRight, nil];
            CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:seq];
            [item runAction:repeatingAnimation];
        }
    }
}

-(void)StopHammers
{
    for(CCSprite *pipe in self.children)
    {
        if(pipe.tag == 1000 || pipe.tag == 1001)
        {
            CCSprite *item = [pipe.children objectAtIndex:0];
            [item stopAllActions];
        }
    }
}


-(void)AddCollisionDotsToHammer:(CCSprite*)hammer
{
    CCSprite *dot1 = [CCSprite spriteWithFile:@"textures/debug/dot.png"];
    [hammer addChild:dot1 z:10];
    dot1.position = ccp(0,0);
    
    CCSprite *dot2 = [CCSprite spriteWithFile:@"textures/debug/dot.png"];
    [hammer addChild:dot2 z:10];
    dot2.position = ccp(hammer.contentSize.width/2,0);
    
    CCSprite *dot3 = [CCSprite spriteWithFile:@"textures/debug/dot.png"];
    [hammer addChild:dot3 z:10];
    dot3.position = ccp(hammer.contentSize.width,0);
    
    CCSprite *dot4 = [CCSprite spriteWithFile:@"textures/debug/dot.png"];
    [hammer addChild:dot4 z:10];
    dot4.position = ccp(hammer.contentSize.width,hammer.contentSize.height / 4);
    
    dot1.visible = dot2.visible = dot3.visible = dot4.visible = DEBUG_MODE_ON;
}

-(bool)characterCollidedWithSwing:(CCSprite*)swing
{
    for(CCSprite *dot in swing.children)
    {
        CGPoint loc = [swing convertToWorldSpace:dot.position];
        if(CGRectContainsPoint(paddle.boundingBox, loc))
        {
            return YES;
        }
    }
    
    return NO;
}

-(bool)PropellerCollidedWith:(CCSprite*)item
{
    
    CGPoint mid = [propeller convertToNodeSpace:ccp(propeller.position.x, propeller.position.y)];
    
    CGPoint left = ccp(mid.x - propeller.contentSize.width / 2, mid.y);
    
    CGPoint right = ccp(mid.x + propeller.contentSize.width / 2, mid.y);

    
    if(CGRectContainsPoint(item.boundingBox, left) || CGRectContainsPoint(item.boundingBox, right) || CGRectContainsPoint(item.boundingBox, mid) )
    {
        return YES;
    }
    
    return NO;
}

-(float)GetNextPipesOffsetX
{
    int offset = arc4random() % (int)(SCREEN_WIDTH / 4 - (10 * SCALE_X));
    
    return offset;
}

-(void)CreateGroundAndClouds
{
    
    midground = [CCSprite spriteWithFile:@"textures/grounds/mid-ground.png"];
    midground.anchorPoint = ccp(0.5f, 0.0f);
    midground.position = ccp(SCREEN_WIDTH/2,0);
    [self addChild:midground z:1];

    // attach clouds and ground to midground
    ground =  [CCSprite spriteWithFile:@"textures/grounds/ground.png"];
    ground.anchorPoint = ccp(0.5f, 0.0f);
    ground.position = ccp(SCREEN_WIDTH/2,0);
    [midground addChild:ground z:2];
    
    
    float minY = midground.contentSize.height;
    for (int i = 0; i < 120; i++)
    {
        int offsetAddX = [self GetNextPipesOffsetX] * 1.2;
        if(arc4random() % 10 >= 5)
        {
            offsetAddX = -1 * offsetAddX;
        }
        CCSprite *cloud = [CCSprite spriteWithFile:@"textures/clouds/cloud.png"];
        cloud.position = ccp(SCREEN_WIDTH/2 + offsetAddX, cloud.contentSize.height + minY + i * (cloud.contentSize.height * 2));
        cloud.tag = TAG_CLOUD;
        [midground addChild:cloud z:0];
    }
    
}

-(void)MoveBackgroundDownBy:(float)pixels
{
    midground.position = ccp(midground.position.x, midground.position.y - pixels);
}

-(void)ResetCurrentTheme
{
    currentThemeIndex = 0;
    [self ChangeThemeToColorWithIndex:currentThemeIndex];
}

-(void)InitializeThemeColors
{
    // grey shade
    ThemeColorsRed[0] = 84; ThemeColorsRedBG[0] = 217;
    ThemeColorsGreen[0] = 97; ThemeColorsGreenBG[0] = 224;
    ThemeColorsBlue[0] = 107; ThemeColorsBlueBG[0] = 229;
    
    
    // grey purplish shade
    ThemeColorsRed[1] = 87; ThemeColorsRedBG[1] = 221;
    ThemeColorsGreen[1] =79; ThemeColorsGreenBG[1] = 215;
    ThemeColorsBlue[1] = 108; ThemeColorsBlueBG[1] = 234;
    
    
    // blue shade
    ThemeColorsRed[2] = 189; ThemeColorsRedBG[2] = 25;
    ThemeColorsGreen[2] =216; ThemeColorsGreenBG[2] = 138;
    ThemeColorsBlue[2] = 195; ThemeColorsBlueBG[2] = 144;
    
    // green shade
    ThemeColorsRed[3] = 249; ThemeColorsRedBG[3] = 35;
    ThemeColorsGreen[3] =254; ThemeColorsGreenBG[3] = 230;
    ThemeColorsBlue[3] = 255; ThemeColorsBlueBG[3] = 134;
    
    
    
    // grey bluish shade
    ThemeColorsRed[4] = 77; ThemeColorsRedBG[4] = 214;
    ThemeColorsGreen[4] = 95; ThemeColorsGreenBG[4] = 225;
    ThemeColorsBlue[4] = 106; ThemeColorsBlueBG[4] = 231;
    
    
    
    // yellow sky - orange shade
    ThemeColorsRed[5] = 252; ThemeColorsRedBG[5] = 252;
    ThemeColorsGreen[5] = 159; ThemeColorsGreenBG[5] = 255;
    ThemeColorsBlue[5] = 53; ThemeColorsBlueBG[5] = 0;
    
    // orange yellow
    ThemeColorsRed[6] = 241; ThemeColorsRedBG[6] = 229;
    ThemeColorsGreen[6] =216; ThemeColorsGreenBG[6] = 79;
    ThemeColorsBlue[6] = 1; ThemeColorsBlueBG[6] = 19;
    
    // blue sky yellow
    ThemeColorsRed[7] = 210; ThemeColorsRedBG[7] = 0;
    ThemeColorsGreen[7] =245; ThemeColorsGreenBG[7] = 213;
    ThemeColorsBlue[7] = 255; ThemeColorsBlueBG[7] = 255;
    
}

-(void)ApplyNewRandomTheme
{
    currentThemeIndex = arc4random() % 8;
    //currentThemeIndex = 5;
    [self ChangeThemeToColorWithIndex:currentThemeIndex];
}

-(void)ChangeThemeToColorWithIndex:(int)idx
{
    if(!changeThemeAuto)
    {
        return;
    }
    for(CCSprite *itm in midground.children)
    {
        if (itm.tag == TAG_CLOUD)
        {
            [itm runAction:[CCTintTo actionWithDuration:0.5f red:ThemeColorsRed[idx] green:ThemeColorsGreen[idx] blue:ThemeColorsBlue[idx]]];
        }
    }
    [spr_bg runAction:[CCTintTo actionWithDuration:0.5f red:ThemeColorsRedBG[idx] green:ThemeColorsGreenBG[idx] blue:ThemeColorsBlueBG[idx]]];
    
}

-(void)AddPropeller
{
    
    propeller = [CCSprite spriteWithFile:@"textures/propeller/propeller-1.png"];
    propeller.anchorPoint = ccp(0.5f, 0);
    propeller.scale = propellerScale;
    propeller.position = ccp(paddle.contentSize.width / 2 + propellerOffsetHorizontal * SCALE_X,paddle.contentSize.height + propellerOffsetVertical * SCALE_Y);
    [paddle addChild:propeller z:10];
    propeller.opacity=0;
    
    [self RunPropellerAnimation];
    

}

-(void)RunPropellerAnimation
{
    NSLog(@"%@ popeller" , propeller);
    [propeller stopAllActions];
    NSMutableArray *frames = [NSMutableArray array];
    CCSpriteFrame *frame1, *frame2, *frame3, *frame4, *frame5, *frame6, *frame7;
    
    CGRect rc = CGRectMake(0, 0, propeller.contentSize.width, propeller.contentSize.height);
    frame1 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-1.png" rect:rc];
    frame2 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-2.png" rect:rc];
    frame3 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-3.png" rect:rc];
    frame4 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-4.png" rect:rc];
    frame5 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-5.png" rect:rc];
    frame6 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-6.png" rect:rc];
    frame7 = [CCSpriteFrame frameWithTextureFilename:@"textures/propeller/propeller-7.png" rect:rc];
    
    [frames addObject:frame1];
    [frames addObject:frame2];
    [frames addObject:frame3];
    [frames addObject:frame4];
    [frames addObject:frame5];
    [frames addObject:frame6];
    [frames addObject:frame7];
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.04f];
    id animateAction = [CCAnimate actionWithAnimation:animation];
    CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:animateAction];
    [propeller runAction:repeatingAnimation];
}

-(void)AnimationIdle
{
    float upDownTime = 1.2f;
    sequenceIdle = [CCSequence actions:[CCMoveBy actionWithDuration:upDownTime position:ccp(0, SCREEN_HEIGHT / 20)], [CCMoveBy actionWithDuration:upDownTime position:ccp(0, -1 * SCREEN_HEIGHT / 20)], nil];
    CCRepeat *repeatingAnimationUpDown = [CCRepeatForever actionWithAction:sequenceIdle];
    [paddle runAction:repeatingAnimationUpDown];
    
}
-(void)AnimationDeath
{
    [paddle stopAllActions];
    [propeller stopAllActions];
    float rotateToVal = 120;
    if(paddle.rotation < 0)
    {
        rotateToVal = -1 * rotateToVal;
    }
    [paddle runAction:[CCRotateBy actionWithDuration:0.32f angle:rotateToVal]];
    
    
    NSMutableArray *frames = [NSMutableArray array];
    CCSpriteFrame *frame1;
    
    CGRect rc = CGRectMake(0, 0, paddle.contentSize.width, paddle.contentSize.height);
    frame1 = [CCSpriteFrame frameWithTextureFilename:[NSString stringWithFormat:@"%@-die.png", currentCharacterFileName] rect:rc];
    [frames addObject:frame1];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
    id animateAction = [CCAnimate actionWithAnimation:animation];
    CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:animateAction];
    [paddle runAction:repeatingAnimation];
}

-(void)AnimationAlive
{
    NSMutableArray *frames = [NSMutableArray array];
    CCSpriteFrame *frame1;
    
    CGRect rc = CGRectMake(0, 0, paddle.contentSize.width, paddle.contentSize.height);
    frame1 = [CCSpriteFrame frameWithTextureFilename:@"textures/character/character.png" rect:rc];
    [frames addObject:frame1];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
    id animateAction = [CCAnimate actionWithAnimation:animation];
    CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:animateAction];
    [paddle runAction:repeatingAnimation];
}

-(void)CharacterGoesToFloor
{
    id seq = [CCSequence actionOne:[CCMoveTo actionWithDuration:0.15f position:ccp(paddle.position.x, ground.boundingBox.size.height)] two:[CCCallFunc actionWithTarget:self selector:@selector(PlayCrashSound)]];
    [paddle runAction:seq];
}

-(void)PlayCrashSound
{
    [[SharedData getSharedInstance] playSoundEffect:EFFECT_EXPLOSION];
}

-(void)BringBackgroundUp
{
    float slowDown = 6.0f;
    float duration = m_fCounter/slowDown;
    if(duration > 1.5f)
    {
        duration = 1.5f;
    }
    
    id act1 = [CCMoveTo actionWithDuration:duration position:ccp(SCREEN_WIDTH/2, 0)];
    id act2 = [CCCallFunc actionWithTarget:self selector:@selector(CharacterGoesToFloor)];
    id seq = [CCSequence actionOne:act1 two:act2];
    [midground runAction:seq];
    
    for(CCSprite *pipe in self.children)
    {
        if(pipe.tag >= 1000 || pipe.tag == TAG_COIN)
        {
           [pipe runAction:[CCMoveTo actionWithDuration:duration position:ccp(pipe.position.x, pipe.position.y + downIterationCount * currentSpeed)]];
        }
    }
}

-(void)AddCoinAtPosition:(CGPoint)pos
{
    //NSLog(@"coins:%d", DebugCoinsCount++);
    CCSprite *coin = [CCSprite spriteWithFile:@"textures/coin/coin1.png"];
    coin.position = ccp(pos.x, pos.y);
    coin.anchorPoint = ccp(0.5f,0.5f);
    coin.tag = TAG_COIN;
    [self addChild:coin z:5];
    
    coins[currentCoinIndex] = coin;
    currentCoinIndex++;
    
    if(!useOnlyTheFirstCoinImage)
    {
        NSString *fileName = @"textures/coin/coin";
        NSMutableArray *frames = [NSMutableArray array];
        CCSpriteFrame *frame1,*frame2,*frame3,*frame4;
        
        CGRect rc = CGRectMake(0, 0, coinTemplate.contentSize.width, coinTemplate.contentSize.height);
        frame1 = [CCSpriteFrame frameWithTextureFilename:[NSString stringWithFormat:@"%@1.png",fileName] rect:rc];
        frame2 = [CCSpriteFrame frameWithTextureFilename:[NSString stringWithFormat:@"%@2.png",fileName] rect:rc];
        frame3 = [CCSpriteFrame frameWithTextureFilename:[NSString stringWithFormat:@"%@3.png",fileName] rect:rc];
        frame4 = [CCSpriteFrame frameWithTextureFilename:[NSString stringWithFormat:@"%@4.png",fileName] rect:rc];
        
        [frames addObject:frame1];[frames addObject:frame2];[frames addObject:frame3];[frames addObject:frame4];
        
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.06f];
        id animateAction = [CCAnimate actionWithAnimation:animation];
        CCRepeat *repeatingAnimation = [CCRepeatForever actionWithAction:animateAction];
        [coin runAction:repeatingAnimation];
    }
}

-(void)RemoveAllCoins
{
    /*for(CCSprite *itm in self.children)
    {
        if(itm.tag == TAG_COIN)
        {
            itm.position = ccp(-1000,-1000);
            [itm stopAllActions];
            itm.visible = NO;
            [self removeChild:itm cleanup:YES];
        }
    }*/
    for(int i = 0; i < pipesMaxCount; i++)
    {
        CCSprite *sp = coins[i];
        [self removeChild:sp cleanup:YES];
    }
    currentCoinIndex = 0;
}

-(void)HideAllCoins
{
    for(int i = 0; i < pipesMaxCount; i++)
    {
        CCSprite *sp = coins[i];
        sp.visible = NO;
    }

}
-(CCSprite*)CharacterGrabbedCoin
{
    for(CCSprite* coin in self.children)
    {
        if(coin.tag == TAG_COIN)
        {
            if(useCoin)
            {
                if(coin.visible)
                {
                    if (coin.position.y < paddle.position.y + coin.boundingBox.size.height)
                    {
                        return coin;
                    }
                }
            }
            else
            {
                if (coin.anchorPoint.x > 0 && coin.position.y < paddle.position.y + coin.boundingBox.size.height)
                {
                    coin.visible = NO;
                    coin.anchorPoint = ccp(-1,0.5f);
                    return coin;
                }
            }
            
        }
    }
    return nil;
}

-(void)PlayRotorSound
{
    if(rotorSound != 0)
    {
        [[SimpleAudioEngine sharedEngine] stopEffect:rotorSound];
    }
    rotorSound = [[SimpleAudioEngine sharedEngine] playEffect:SOUND_ROTOR loop:YES];
}

-(void)StopRotorSound
{
    [[SimpleAudioEngine sharedEngine] stopEffect:rotorSound];
}

-(bool)CharacterTouchedBounds
{
    if(paddle.position.x < paddle.contentSize.width/2 || paddle.position.x > SCREEN_WIDTH - paddle.contentSize.width/2)
    {
        return YES;
    }
    else return NO;
}

- (CCSprite *)soundButtonSprite {
    if ([[SharedData getSharedInstance] isBackgroundMusicPlaying]) {
        return [CCSprite spriteWithFile:@"textures/gui/b_sound_on.png"];
    } else {
        return [CCSprite spriteWithFile:@"textures/gui/b_sound_off.png"];
    }
}

@end