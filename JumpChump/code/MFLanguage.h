//
//  MFLanguage.h
//  Mystie the Fox
//
//  Created by Roman on 20.07.14.
//  Copyright (c) 2014 Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFLanguage : NSObject

+(instancetype) sharedLanguage;

@property (strong,nonatomic) NSString *language;

@end
