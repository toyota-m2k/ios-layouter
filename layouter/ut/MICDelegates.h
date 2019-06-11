//
//  MICDelegates.h
//  LayoutDemo
//
//  Created by @toyota-m2k on 2014/12/22.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MICDelegateObject : NSObject

@property (nonatomic,weak,readonly) id delegate;

- (instancetype) initWithObject:(id)delegate;

@end

@interface MICDelegates : NSObject

@property (nonatomic,readonly) int count;

- (instancetype) init;

- (void) add:(id) delegate;
- (void) remove:(id)delegate;
- (void) clean;
- (void) invoke:(void (^)(id delegate))func;

@end
