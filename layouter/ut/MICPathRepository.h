//
//  MICPathRepository.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/03/12.
//  Copyright  2019年 @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MICSvgPath.h"

@interface MICPathRepository : NSObject

+ (instancetype) instance;

+ (instancetype) localInstance;

- (MICSvgPath*) getPath:(NSString*)pathString viewboxSize:(CGSize)size;
- (void) releasePath:(MICSvgPath*)path;

// 強制的な全クリア
- (void) dispose;

@end
