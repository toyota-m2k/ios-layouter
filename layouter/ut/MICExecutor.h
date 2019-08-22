//
//  MICExecutor.h
//
//  iOSには、サブスレッドを起動する方法が少なくとも３種類あって、どれを使うか迷うよね。優柔不断なので、とりあえず選べるようにしてみた。
//  どれを使うにしても、統一された　i/f (MICBackgroundExecutor) で利用できるので、ファクトリーの引数で、簡単に差し替え可能。
//
//  Created by @toyota-m2k on 2018/12/01.
//  Copyright  2018年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MICAsync.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _micExecutorType {
    MICExecutorOPRATION_QUEUE,          // NSOperationQueue
    MICExecutorGCD_GLOBAL,              // dispatch_get_global_queue
    MICExecutorGCD_PRIVATE,             // dispatch_queue_create
    MICExecutorRAW,                     // NSThread
} MICExecutorType;

@interface MICExecutorFactory : NSObject

+ (MICBackgroundExecutor) executor:(MICExecutorType)type;
+ (MICBackgroundExecutor) executor;

@end

NS_ASSUME_NONNULL_END
