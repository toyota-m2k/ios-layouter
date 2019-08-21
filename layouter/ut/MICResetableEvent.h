//
//  MICResetableEvent.h
//  Anytime
//
//  Created by @toyota-m2k on 2018/11/06.
//  Copyright  2018年 @toyota-m2k Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMICWaitable
- (void) waitOne;
- (bool) waitOneFor:(dispatch_time_t) ms;
@end

@interface MICAutoResetEvent : NSObject<IMICWaitable>

- (instancetype) initSignaled:(bool)signaled;
+ (instancetype) create:(bool) initialSignaled;

- (void) set;
- (void) waitOne;
- (bool) waitOneFor:(dispatch_time_t) ms;

@end

@interface MICManualResetEvent : NSObject<IMICWaitable>

- (instancetype) initSignaled:(bool)signaled;
+ (instancetype) create:(bool) initialSignaled;

- (void) set;
- (void) reset;
- (void) waitOne;
- (bool) waitOneFor:(dispatch_time_t) ms;
@end

