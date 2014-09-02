//
//  IntroLayer.m
//  JumpChump
//
//  Created by admin on 3/22/14.
//  Copyright __MyCompanyName__ 2014. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "HelloWorldLayer.h"
#import "GamePlayLaer.h"
#import "MFLanguage.h"
#import "MFImageCropper.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
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
    
    NSString *logoName=@"";
    if ([[MFLanguage sharedLanguage].language isEqualToString:@"ru"]) {
        logoName=@"logo_rus-hd.png";
    }else {
        logoName=@"logo_eng-hd.png";
    }
    
//	if( UI_USER_INTERFACE_IDIOM() ==IUserInterfaceIdiomPhone ) {
    background = [CCSprite spriteWithFile:logoName ];
    float ratio = [MFImageCropper spriteRatio:background];
    background.scaleX= size.width/background.contentSize.width;
    background.scaleY=background.contentSize.width*background.scaleX *ratio /background.contentSize.height;
//		background.rotation = 90;
//	} else {
//		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
//	}
	background.position = ccp(size.width/2, size.height/2);
    
     CCFadeTo *fadeIn = [CCFadeIn actionWithDuration:1];
    
    background.opacity=0;

	[self addChild: background];
    
    [background runAction:fadeIn];
	

	[self scheduleOnce:@selector(makeTransition:) delay:2];
}

-(void) makeTransition:(ccTime)dt
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GamePlayLaer scene] withColor:ccWHITE]];
}
@end
