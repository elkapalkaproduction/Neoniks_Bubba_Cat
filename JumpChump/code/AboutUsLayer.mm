//
//  AboutUsLayer.m
//  FlappyHunt
//
//  Created by Roman on 03.09.14.
//
//

#import "AboutUsLayer.h"
#import "MFLanguage.h"
#import "MFImageCropper.h"
#import "global.h"
#import "GamePlayLaer.h"

@implementation AboutUsLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    AboutUsLayer *layer = [AboutUsLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(void) onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
    
	CCSprite *background;
    
    
    
    NSString *backgroundName=@"";
    if ([[MFLanguage sharedLanguage].language isEqualToString:@"ru"]) {
        if ([UIScreen mainScreen].bounds.size.height==568) {
            backgroundName=@"about-rus-iphone5hd.png";
        }else{
            backgroundName=@"about-rus.png";
        }
    }else {
        if ([UIScreen mainScreen].bounds.size.height==568) {
            backgroundName=@"about-eng-iphone5hd.png";
        }else{
            backgroundName=@"about-eng.png";
        }
    }
    
    
    
    
   /* if ([UIScreen mainScreen].bounds.size.height==568) {
        offsetForPlayButton = 40 +m_btnRate.boundingBox.size.height/2;
        offsetForAboutUsButton = 10;
    }else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            offsetForAboutUsButton = 60;
        }else{
            offsetForAboutUsButton = 10;
        }
        offsetForPlayButton =m_btnRate.boundingBox.size.height/2;
    }*/
    
    //	if( UI_USER_INTERFACE_IDIOM() ==IUserInterfaceIdiomPhone ) {
    background = [CCSprite spriteWithFile:backgroundName ];
    float ratio = [MFImageCropper spriteRatio:background];
    background.scaleX= size.width/background.contentSize.width;
    background.scaleY=background.contentSize.width*background.scaleX *ratio /background.contentSize.height;
    //		background.rotation = 90;
    //	} else {
    //		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
    //	}
	background.position = ccp(size.width/2, size.height/2);
    
//    CCFadeTo *fadeIn = [CCFadeIn actionWithDuration:1];
    
	[self addChild: background];
    
    CCMenuItemSprite *closeButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                            selectedSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                                    target:self
                                                                  selector:@selector(close:)];
    closeButton.position=ccp(SCREEN_WIDTH - closeButton.boundingBox.size.width/2 -5, SCREEN_HEIGHT - closeButton.boundingBox.size.height/2 -5);
    closeButton.isEnabled=YES;
    CCMenu* menu = [CCMenu menuWithItems:closeButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
//    [self addChild:closeButton];
    
//    [background runAction:fadeIn];
	
    
}
-(void)close:(id)sender{
    [[CCDirector sharedDirector] pushScene:[GamePlayLaer scene]];
}


-(void) makeTransition:(ccTime)dt
{
//	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GamePlayLaer scene] withColor:ccWHITE]];
}

@end
