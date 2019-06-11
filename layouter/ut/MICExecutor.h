//
//  MICExecutor.h
//  Anytime
//
//  Created by @toyota-m2k on 2018/12/01.
//  Copyright  2018年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MICAsync.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _micExecutorType {
    MICExecutorOPRATION_QUEUE,
    MICExecutorGCD_GLOBAL,
    MICExecutorGCD_PRIVATE,
    MICExecutorRAW,
} MICExecutorType;

@interface MICExecutorFactory : NSObject

+ (MICBackgroundExecutor) executor:(MICExecutorType)type;
+ (MICBackgroundExecutor) executor;

@end

NS_ASSUME_NONNULL_END
