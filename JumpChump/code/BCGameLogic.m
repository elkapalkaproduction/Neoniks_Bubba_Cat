//
//  BCGameLogic.m
//  FlappyHunt
//
//  Created by Roman on 05.09.14.
//
//

#import "BCGameLogic.h"

@implementation BCGameLogic

+(instancetype) sharedLogic{
    
    static BCGameLogic *sharedLogic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogic = [[self alloc] init];
    });
    return sharedLogic;
    
}

-(instancetype) init{
    if (self==[super init]) {
        self.gameLaunches=0;
    }
    return self;
}


@end
