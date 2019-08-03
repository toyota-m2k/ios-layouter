//
//  MICTargetSelector.m
//  target と selector をまとめて保持する、ありそうでなさそうなクラス（あったらごめん）
//  TargetをSelectするためのユーティリティのような名前で申し訳ない、作ってから気づいたんよ。
//
//  使い方
//  MICTargetSelector* ts = [[MICTargetSelector initWithTarget:someTarget selector:@selector(hogeAction)];
//  ...
//  [ts beginCall];
//  [ts addArgument:&hoge];
//  [ts addArgument:&fuga];
//  [ts endCall];
//
//  Created by @toyota-m2k on 2016/01/26.
//  Copyright  2016年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICTargetSelector.h"

@implementation MICTargetSelector {
    NSInvocation* _invocation;
    NSInteger _argIndex;
}

- (instancetype)init {
    return [self initWithTarget:nil selector:nil];
}

/**
 * @param   target      ターゲット（weak参照で保持する。strong参照にしたければ、strongTargetプロパティを使え）
 */
- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    self = [super init];
    if(nil!=self) {
        self.target = target;
        self.selector = selector;
        _invocation = nil;
    }
    return self;
}

+ (instancetype) targetSelector:(id)target selector:(SEL)selector {
    return [[MICTargetSelector alloc] initWithTarget:target selector:selector];
}

/**
 * ターゲットを弱参照で保持する
 */
- (void) setTarget:(id)target {
    _target = target;
    _strongTarget = nil;
}

/**
 * ターゲットを強参照で保持する
 */
- (void) setStrongTarget:(id)strongTarget {
    _target = strongTarget;
    _strongTarget = strongTarget;
}

+ (NSInvocation*) createInvocationForTarget:(id)target andSelector:(SEL)selector {
    if(nil==target) {
        return nil;
    }
    NSMethodSignature* sig = [target methodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.selector = selector;
    invocation.target = target;
    return invocation;
}

+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector {
    if(nil==target||nil==selector) {
        return nil;
    }
    NSInvocation* iv = [MICTargetSelector createInvocationForTarget:target andSelector:selector];
    [iv invoke];
    return iv;
}

+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector withObjectParam:(id)obj {
    if(nil==target||nil==selector) {
        return nil;
    }
    NSInvocation* iv = [MICTargetSelector createInvocationForTarget:target andSelector:selector];
    [iv setArgument:&obj atIndex:2];
    [iv invoke];
    return iv;
}

+ (NSInvocation*) invoke:(id)target andSelector:(SEL)selector withParam:(void*)argPtr {
    if(nil==target||nil==selector) {
        return nil;
    }
    NSInvocation* iv = [MICTargetSelector createInvocationForTarget:target andSelector:selector];
    [iv setArgument:argPtr atIndex:2];
    [iv invoke];
    return iv;
}

+ (NSInvocation*) invokeArgs:(id)target andSelector:(SEL)selector, ...NS_REQUIRES_NIL_TERMINATION {
    if(nil==target||nil==selector) {
        return nil;
    }
    va_list args;
    va_start(args, selector);
    
    NSInvocation* iv = [MICTargetSelector createInvocationForTarget:target andSelector:selector];
    NSInteger index = 2;
    void* arg;
    while(nil!=(arg = va_arg(args, void*))) {
        [iv setArgument:arg atIndex:index];
        index++;
    }
    [iv invoke];
    va_end(args);
    return iv;
}

+ (NSInvocation*) invokeArgs:(id)target andSelector:(SEL)selector afterDelay:(double)delay, ...NS_REQUIRES_NIL_TERMINATION {
    if(nil==target||nil==selector) {
        return nil;
    }
    va_list args;
    va_start(args, delay);
    
    NSInvocation* iv = [MICTargetSelector createInvocationForTarget:target andSelector:selector];
    NSInteger index = 2;
    void* arg;
    while(nil!=(arg = va_arg(args, void*))) {
        [iv setArgument:arg atIndex:index];
        index++;
    }
    [iv retainArguments];
    [iv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
    va_end(args);
    return iv;
}

/**
 * セレクタ呼び出し用のNSInvocationオブジェクトを生成
 *  こまかくなんかやりたい場合用・・・通常は、beginCall/addArgument/endCallを使う想定。
 */
- (NSInvocation*) createInvocation{
    if(nil==self.target||nil==self.selector) {
        return nil;
    }
    return [MICTargetSelector createInvocationForTarget:self.target andSelector:self.selector];
}

/**
 * 呼び出しのための準備開始
 */
- (void) beginCall {
    _invocation = [self createInvocation];
    _argIndex = 2;      // 引数は２から始まるらしい
}

/**
 * 引数を追加
 * @param   argPtr      引数として渡す値のポインタである点に注意。参照先変数は、呼び出し終了まで生きていなければならないはず。
 */
- (void) addArgument:(void*)argPtr {
    if(nil!=_invocation) {
        [_invocation setArgument:argPtr atIndex:_argIndex];
        _argIndex++;
    }
}

/**
 * 呼び出しを実行
 */
- (void) endCall {
    if(nil!=_invocation) {
        [_invocation invoke];
        _invocation = nil;
    }
}

- (void) endCallGetResult:(void*)result {
    if(nil!=_invocation) {
        [_invocation invoke];
        if(nil!=result){
            [_invocation getReturnValue:result];
        }
        _invocation = nil;
    }
}

- (void) perform {
    [self.class invoke:_target andSelector:_selector];
}

- (void)performGetResult:(void *)result {
    NSInvocation* iv = [self.class invoke:_target andSelector:_selector];
    if(nil!=iv){
        [iv getReturnValue:result];
    }
}

// １引数で実行
- (void) performWithParam:(void*)argPtr {
    [self beginCall];
    [self addArgument:argPtr];
    [self endCall];
}


- (void) performWithParam:(void*)argPtr getResult:(void*)result {
    [self beginCall];
    [self addArgument:argPtr];
    [self endCallGetResult:result];
}


@end
