//
//  AnimatedText.h
//  JumpChump
//
//  Created by admin on 3/22/14.
//
//

#import "CCNode.h"
#import "cocos2d.h"

@interface AnimatedText : CCNode{
}

@property (nonatomic, retain) NSMutableArray* arr_letters;
@property (nonatomic, assign) float total_length;
@property (nonatomic, assign) float total_time;
@property (nonatomic, assign) BOOL action_flag;

-(id) initWithString:(NSString*) str;
-(void) dropAnimation;
-(void) upAnimation;

@end
