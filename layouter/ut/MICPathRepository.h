//
//  MICPathRepository.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/03/12.
//  Copyright  2019年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MICSvgPath.h"

@interface MICPathRepository : NSObject

+ (instancetype) instance;

- (MICSvgPath*) getPath:(NSString*)pathString viewboxSize:(CGSize)size;
- (void) releasePath:(MICSvgPath*)path;

@end
