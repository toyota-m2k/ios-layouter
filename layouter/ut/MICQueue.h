//
//  MICQueue.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2018/11/21.
//  Copyright  2018年 @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MICQueue : NSObject

- (void) enque:(id)v;
- (id) deque;
- (NSInteger) count;
- (void) removeAll;

@end

NS_ASSUME_NONNULL_END
