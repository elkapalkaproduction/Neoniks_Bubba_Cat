//
//  BCGameLogic.h
//  FlappyHunt
//
//  Created by Roman on 05.09.14.
//
//

#import <Foundation/Foundation.h>

#define kNumberOfPlayedGamesForAds 3

@interface BCGameLogic : NSObject

+(instancetype) sharedLogic;

@property(nonatomic) int gameLaunches;

@end
