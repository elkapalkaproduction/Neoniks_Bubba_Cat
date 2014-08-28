//
//  GamePlayLaer.h
//  JumpChump
//
//  Created by admin on 3/22/14.
//
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "AnimatedText.h"
//#import "BackgroundLayer.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "GADBannerView.h"



#define BANNER_TYPE kBanner_Portrait_Bottom

const int pipesMaxCount = 20;

typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}CocosBannerType;


@interface GamePlayLaer : CCLayer{

    CGSize      sz_jump;
    CCSprite * spr_bg;
    
    CCSprite *logo;
    CCSprite *pipe_v_left_up, *pipe_v_left_down;
    CCSprite *pipe_v_right_up, *pipe_v_right_down;
    CCSprite *pipe_v_mid_up, *pipe_v_mid_down;
    CCSprite *pipe_h_left, *pipe_h_right;
    
    CCSprite *mainCharacter;
    CCSprite *bonusLeftUp, *bonusLeftDown, *bonusMidUp, *bonusMidDown, *bonusMidRightUp, *bonusMidRightDown, *bonusRightUp, *bonusRightDown;
    
    float timeElapsedSinceLastSpawn;
    int lastBonusRespawnSpot;
        
    BOOL bonusLeftUpShown, bonusLeftDownShown, bonusMidUpShown, bonusMidDownShown, bonusMidRightUpShown, bonusMidRightDownShown, bonusRightUpShown, bonusRightDownShown;
    
    CCSprite *scorePlusOne;
    CCSprite *enemy;
    
    
    CCSprite *tutorial;
    //AnimatedText* text;
    int         m_nTutorialTouch;
    BOOL        m_bActJump;
    BOOL        m_bActChump;
    int         m_HighScore;
    float         m_Score;
    float       m_fEnemyInterval;
    float       m_fCounter;
    float       m_fReadyTime;
    BOOL        m_bShowGameOver;
    
    CCMenuItemSprite*   m_btnRate;
    CCMenuItemSprite*   m_btnPlay;
    CCMenuItemSprite*   m_btnGameCenter;
    CCMenuItemSprite*   m_btnFacebook;
    CCMenuItemSprite*   m_btnTwitter;
    CCMenuItemSprite*   m_btnMail;
    
    CCLabelTTF*         m_lblHighScore;
    CCLabelTTF*         m_lblScore;
    CCLabelTTF*         m_lblScoreShadow;
    CCLabelTTF*         m_lblScoreTitle;
    CCLabelTTF*         m_lblScoreTitleShadow;
    CCLabelTTF*         m_lblHighScoreTitle;
    CCLabelTTF*         m_lblHighScoreTitleShadow;
    CCLabelTTF*         m_lblHighScoreShadow;
    int                 m_nGamePlayCount;
    int                 m_nGameMode;

    BOOL                m_bGamePlaying;
    
    
    b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    b2Body* groundBody;
    b2ContactListener* contactListener;
    
    
    GADBannerView *mBannerView; //
    CocosBannerType mBannerType; //
    float on_x, on_y, off_x, off_y; //
    

    float currentFallSpeed;
    
    CCSprite *paddle; //controlled by player
    float touch_location_initialX;
    float paddleInitialPosX;
    BOOL touchDown;
    CCSprite *instructions;
    BOOL preparingNextWave;
    BOOL freezeWave;
    int waveCount;
    
    //CCSprite *roadPartLeft;
    //CCSprite *roadPartRight;
    
    
    float pipeCurrentHorizontalOffsetVariation;
    
    int pipePassedCount;
    float currentHorizontalSpaceBetweenPipes;
    float currentSpeed;
    
    int algorithmTimeUsedCount;
    int algorithmCurrentType;
    float currentAlgorithUsedIndex;
    float factor;
    
    float finalDistanceBetweenSetOfPipes;
    float tmpInc;
    CGMutablePathRef path;
    CCSprite *ground;
    CCSprite *midground;
    
    
    
    float ThemeColorsRed[9];
    float ThemeColorsGreen[9];
    float ThemeColorsBlue[9];
    float ThemeColorsRedBG[9];
    float ThemeColorsGreenBG[9];
    float ThemeColorsBlueBG[9];
    
    int currentThemeIndex;
    CCSprite *propeller;
    float downIterationCount;
    CCSprite *coinTemplate;
    int currentScore;
    
    int DebugCoinsCount;
    //ALuint rotorSound;
    GLuint rotorSound;
    bool characterPlaying;
    
    CCSprite *coins[pipesMaxCount];
    int currentCoinIndex;
    float lastExpiredPipePosX;
    float lastExpiredPipePosY;
    
    float currentCharacterSpeedX;
    float characterDirection;
    float currentIncline;
    float currentInclineAcceleration;
    
    CCSequence *sequenceIdle;
    float timeSpentOnSameDirection;
    
    NSString *currentCharacterFileName;
}

//@property (strong, nonatomic)     BackgroundLayer* back_layer;


+(CCScene *) scene;

@end
