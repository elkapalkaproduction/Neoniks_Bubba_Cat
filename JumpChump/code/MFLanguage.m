//
//  MFLanguage.m
//  Mystie the Fox
//
//  Created by Roman on 20.07.14.
//  Copyright (c) 2014 Roman. All rights reserved.
//

#import "MFLanguage.h"

@implementation MFLanguage

+(instancetype) sharedLanguage{
    
    static MFLanguage *sharedLanguage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLanguage = [[self alloc] init];
    });
    return sharedLanguage;
    
}

-(instancetype) init{
    if (self==[super init]) {
        [self chooseLanguage];
    }
    return self;
}

-(void)chooseLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    // paste other languages
    if ([language isEqualToString:@"ru"]) {
        self.language = @"ru";
    }else{
        self.language=@"en";
    }
}

@end
