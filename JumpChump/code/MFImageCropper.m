//
//  MFImageCropper.m
//  Mystie the Fox
//
//  Created by Roman on 20.07.14.
//  Copyright (c) 2014 Roman. All rights reserved.
//

#import "MFImageCropper.h"

@implementation MFImageCropper

+(float)spriteRatio:(CCSprite *)node{
    float ratio=0;
//    ratio = node.size.height / node.size.width;
    ratio = node.contentSize.height/ node.contentSize.width;
    return ratio;
}


@end
