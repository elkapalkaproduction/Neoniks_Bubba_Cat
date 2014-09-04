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
	CCScene *scene = [CCScene node];
	
    AboutUsLayer *layer = [AboutUsLayer node];
	
	[scene addChild: layer];
	
	return scene;
}

//
-(void) onEnter
{
	[super onEnter];
    
	CGSize size = [[CCDirector sharedDirector] winSize];
    
	CCSprite *background;
    
    
    
    NSString *backgroundName=@"";
    NSString *siteImageName= @"";
    if ([[MFLanguage sharedLanguage].language isEqualToString:@"ru"]) {
        siteImageName=@"site-rus.png";
        if ([UIScreen mainScreen].bounds.size.height==568) {
            backgroundName=@"about-rus-iphone5hd.png";
        }else{
            backgroundName=@"about-rus.png";
        }
    }else {
        siteImageName=@"site-eng.png";
        if ([UIScreen mainScreen].bounds.size.height==568) {
            backgroundName=@"about-eng-iphone5hd.png";
        }else{
            backgroundName=@"about-eng.png";
        }
    }
    
    
    
    
    background = [CCSprite spriteWithFile:backgroundName ];
    float ratio = [MFImageCropper spriteRatio:background];
    background.scaleX= size.width/background.contentSize.width;
    background.scaleY=background.contentSize.width*background.scaleX *ratio /background.contentSize.height;
	background.position = ccp(size.width/2, size.height/2);
    
    
	[self addChild: background];
    
    CCMenuItemSprite *closeButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                            selectedSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                                    target:self
                                                                  selector:@selector(close:)];
    
    
    CCMenuItemSprite *closeAreaButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                            selectedSprite:[CCSprite spriteWithFile:@"control_x.png"]
                                                                    target:self
                                                                  selector:@selector(close:)];
    
    
    
    CCMenuItemSprite *siteButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:siteImageName]
                                                            selectedSprite:[CCSprite spriteWithFile:siteImageName]
                                                                    target:self
                                                                  selector:@selector(openURL:)];
    
    
    float closeButtonOffsetX=0;
    float closeButtonOffsetY=0;
    float siteButtonOffsetX=0;
    float siteButtonOffsetY=0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] !=UIUserInterfaceIdiomPad) {
        closeButton.scale=0.6;
        siteButton.scale=0.6;
        closeButtonOffsetX = 5;
        closeButtonOffsetY= 5;
        if ([UIScreen mainScreen].bounds.size.height==568) {
            siteButtonOffsetX =10;
            siteButtonOffsetY =5;
        }else{
            siteButtonOffsetX =5;
            siteButtonOffsetY =25;
        }
    }else{
        closeButtonOffsetX = 10;
        closeButtonOffsetY= 10;
        siteButtonOffsetX =40;
        siteButtonOffsetY =15;
    }
    
    closeAreaButton.scale=2;
    closeAreaButton.position =ccp(SCREEN_WIDTH - closeAreaButton.boundingBox.size.width/2, SCREEN_HEIGHT - closeAreaButton.boundingBox.size.height/2);
    closeAreaButton.opacity=0;
    closeButton.position=ccp(SCREEN_WIDTH - closeButton.boundingBox.size.width/2 -closeButtonOffsetX, SCREEN_HEIGHT - closeButton.boundingBox.size.height/2 -closeButtonOffsetY);
    
    siteButton.position=ccp(SCREEN_WIDTH - siteButton.boundingBox.size.width/2 -siteButtonOffsetX, SCREEN_HEIGHT/2 -siteButtonOffsetY);

    
    
    closeButton.isEnabled=YES;
    siteButton.isEnabled=YES;
    
    
    
    
    CCMenu* menu = [CCMenu menuWithItems:closeButton, closeAreaButton, siteButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];

	
    
}
-(void)close:(id)sender{
    [[CCDirector sharedDirector] pushScene:[GamePlayLaer scene]];
}

-(void)openURL:(id)sender{
    if ([[MFLanguage sharedLanguage].language isEqualToString:@"ru"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.neoniki.com"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.neoniks.com"]];
    }
    
}

//-(CCSprite*) createSpriteRectangleWithSize:(CGSize)size
//
//{
//    CCSprite *sprite = [CCSprite node];
//    
//    GLubyte *buffer = malloc(sizeof(GLubyte)*4);
//    
//    for (int i=0;i<4;i++) {buffer=255;}
//    
//    CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:size];
//    
//    [sprite setTexture:tex];
//    
//    [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    free(buffer);
//    
//    return sprite;
//    
//}




@end
