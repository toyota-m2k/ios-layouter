//
//  MICKeyValueObserver.m
//  NSKeyValueObserverRegistration に対するオブザーバー登録／解除をいい具合にする
//
//  Created by @toyota-m2k on 2017/11/02.
//  Copyright  2017年 @toyota-m2k. All rights reserved.
//

#import "MICKeyValueObserver.h"
#import "MICTargetSelector.h"
#import "MICVar.h"

#pragma mark - Observer Item class

@interface MICObserverItem : NSObject<IMICKeyValueObserverItem>
@property (nonatomic) MICTargetSelector* action;
@property (nonatomic) NSString* key;
@property (nonatomic) MICObserverActionProc proc;
@end

/**
 * 個々のオブザーバーの情報を保持するクラス（非公開）
 */
@implementation MICObserverItem {
}
@synthesize change=_change, context=_context;

/**
 * 登録
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 * handlerの型
 *  - (void) handler:(id<IMICKeyValueObserverItem>) info target:(id)target;
 */
- (instancetype) initForKey:(NSString*)key listener:(id)listener handler:(SEL)handler {
    self = [super init];
    if(nil!=self) {
        self.action = [[MICTargetSelector alloc] initWithTarget:listener selector:handler];
        self.key = key;
        self.proc = nil;
    }
    return self;
}

- (instancetype) initForKey:(NSString*)key action:(MICObserverActionProc)action {
    self = [super init];
    if(nil!=self) {
        self.action = nil;
        self.key = key;
        self.proc = action;
    }
    return self;
}

/**
 * イベントハンドラ呼び出し
 *
 * @param key       キー（＝監視するプロパティ名）     ... チェック用
 * @param target    プロパティ監視の対象オブジェクト    ... チェック用
 * @param change    observeValueForKeyPathに渡された引数
 * @param context   observeValueForKeyPathに渡された引数
 *
 */
- (void) invoke:(NSString*)key target:(id)target change:(NSDictionary *)change context:(void*)context {
    if(![self.key isEqualToString:key]) {
        return;
    }
    _change = change;
    _context = context;
    
    
    if(self.proc!=nil) {
        self.proc(self, target);
    } else {
        id me = self;
        [self.action beginCall];
        [self.action addArgument:&me];
        [self.action addArgument:&target];
        [self.action endCall];
    }
}

- (void) dispose {
    self.proc = nil;
    self.action = nil;
}

@end

#pragma mark - Observer manager class

/**
 * オブザーバーをまとめて管理するクラス
 */
@implementation MICKeyValueObserver {
    NSMutableDictionary<NSString*,MICObserverItem*> *mDic;      // オブザーバー登録用マップ
    __weak id mActor;            // オブザーバーの胴元・・・observeValueForKeyPathを実装するクラスのオブジェクト
}

/**
 * 初期化
 * @param actor  observeValueForKeyPathメソッドを実装するオブジェクト
 */
- (instancetype)initWithActor:(id)actor {
    self = [super init];
    if(nil!=self) {
        mDic = [[NSMutableDictionary alloc] init];
        mActor = actor;
    }
    return self;
}

- (void) addItem:(MICObserverItem*)item forKey:key options:(NSKeyValueObservingOptions)options context:(void *)context{
    let entry = [mDic valueForKey:key];
    if(nil==entry) {
        [mActor addObserver:self forKeyPath:key options:options context:context];
    } else {
        [entry dispose];
    }
    [mDic setObject:item forKey:key];
}

/**
 * オブザーバーを追加（オプションやコンテキストを個別に指定する版）
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 * @param options   オブザーバー登録時のオプション
 * @param context   オブザーバー登録時に渡すコンテキスト(nil可)
 * handlerの型
 *  - (void) handler:(id<IMICKeyValueObserverItem>) info target:(id)target;
 */
- (void) add:(NSString*)key listener:(id)listener handler:(SEL)handler options:(NSKeyValueObservingOptions)options context:(void*)context {
    [self addItem:[[MICObserverItem alloc] initForKey:key listener:listener handler:handler] forKey:key options:options context:context];
}

/**
 * オブザーバーを追加
 * （options = NSKeyValueObservingOptionNew, context=nil）
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 * handlerの型
 *  - (void) handler:(id<IMICKeyValueObserverItem>) info target:(id)target;
 */
- (void) add:(NSString*)key listener:(id)listener handler:(SEL)handler {
    [self add:key listener:listener handler:handler options:NSKeyValueObservingOptionNew context:nil];
}

/**
 * オブザーバーを追加 (ブロック型リスナーを使用するバージョン）
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   action      リスナー
 * @param   options     NSKeyValueObservingOptions
 * @param   context     handlerに渡す任意の値
 */
- (void)add:(NSString *)key action:(MICObserverActionProc)action options:(NSKeyValueObservingOptions)options context:(void *)context {
    [self addItem:[[MICObserverItem alloc] initForKey:key action:action] forKey:key options:options context:context];
}

/**
 * オブザーバーを追加 (ブロック型リスナーを使用するバージョン）
 *
 * @param   key         監視対象のプロパティ名　(@"frame", @"contentSize"など）
 * @param   action      リスナー
 */
- (void)add:(NSString *)key action:(MICObserverActionProc)action {
    [self add:key action:action options:NSKeyValueObservingOptionNew context:nil];
}

/**
 * オブザーバーを１つずつ削除
 * @param key       キー（＝監視するプロパティ名）
 */
- (void) remove:(NSString*)key {
    id entry = [mDic objectForKey:key];
    if(nil!=entry) {
        [mDic removeObjectForKey:key];
        [entry dispose];
        [mActor removeObserver:self forKeyPath:key];
    }
}

/**
 * オブザーバーをすべて削除
 */
- (void) removeAll {
    for(id key in mDic.keyEnumerator) {
        id entry = [mDic objectForKey:key];
        [entry dispose];
        [mActor removeObserver:self forKeyPath:key];
    }
    [mDic removeAllObjects];
}

/**
 * インスタンスを破棄
 */
- (void) dispose {
    [self removeAll];
    mActor = nil;
}

/**
 * Valueが変更されたときにシステムによって呼び出されるメソッド
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id entry = [mDic objectForKey:keyPath];
    if(nil!=entry) {
        if([entry isKindOfClass:MICObserverItem.class]) {
            MICObserverItem* item = (MICObserverItem*)entry;
            [item invoke:keyPath target:object change:change context:context];
        } else if( [entry isKindOfClass:NSMutableArray.class]){
            NSMutableArray* ary = (NSMutableArray*)entry;
            for(MICObserverItem* item in ary) {
                [item invoke:keyPath target:object change:change context:context];
            }
        }
    }
}

#pragma mark

@end
