//
//  MICTargetSelector.h
//  ios-layouter
//
//  Created by 豊田 光樹 on 2016/01/26.
//  Copyright  2016年 M.TOYOTA Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MICTargetSelector : NSObject

@property (nonatomic,weak) id target;
@property (nonatomic) id strongTarget;
@property (nonatomic) SEL selector;

- (instancetype)init;
- (instancetype)initWithTarget:(id)target selector:(SEL)selector;

// 公開しているが多分使わない
- (NSInvocation*) createInvocation;

// 引数をセットして呼び出す
- (void) beginCall;
- (void) addArgument:(void*)argPtr;
- (void) endCall;
- (void) endCallGetResult:(void*)result;

// 引数なしで実行
- (void) perform;
- (void) performGetResult:(void*)result;

// １引数で実行
- (void) performWithParam:(void*)argPtr;
- (void) performWithParam:(void*)argPtr getResult:(void*)result;


// あったら使えるかもしれないので外部にも公開
+ (NSInvocation*) createInvocationForTarget:(id)target andSelector:(SEL)selector;

// 単純な呼び出し用
+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector;
+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector withObjectParam:(id)obj;
+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector withParam:(void*)argPtr;

@end
