//
//  WPLObserver.h
//
//  Created by toyota-m2k on 2020/04/14.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLObservableDef.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IWPLObserver <IWPLDisposable>

@property (nonatomic,nonnull,readonly) id<IWPLObservableData> source;

@end

@interface WPLObserver : NSObject<IWPLObserver>

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithSource:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> source)) callback;

+ (instancetype) asObserver:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> source)) callback;

@end

@interface WPLWeakObserver : NSObject<IWPLDisposable>

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithSource:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> source)) callback;

+ (instancetype) asObserver:(id<IWPLObservableData>)source onNext:(void (^)(id<IWPLObservableData> source)) callback;

@end

NS_ASSUME_NONNULL_END
