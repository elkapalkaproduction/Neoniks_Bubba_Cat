//
//  MFImageCropper.h
//  Mystie the Fox
//
//  Created by Roman on 20.07.14.
//  Copyright (c) 2014 Roman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MFImageCropper : NSObject

+(float) spriteRatio:(CCSprite *)node;

+(float)spriteRatioWithMenuItem:(CCMenuItemSprite *)node;


@end
