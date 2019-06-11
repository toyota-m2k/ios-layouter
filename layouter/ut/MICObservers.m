//
//  MICObservers.m
//  NSKeyValueObserverRegistration に対するオブザーバー登録／解除をいい具合にする
//
//  Created by @toyota-m2k on 2017/11/02.
//  Copyright  2017年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICObservers.h"
#import "MICTargetSelector.h"

#pragma mark - Observer Item class

@interface MICObserverItem : NSObject
@property (nonatomic) MICTargetSelector* action;
@property (nonatomic) NSString* key;
@property (nonatomic, weak) id target;
@end

/**
 * 個々のオブザーバーの情報を保持するクラス（非公開）
 */
@implementation MICObserverItem {
}

/**
 * 登録
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param target    プロパティ監視の対象オブジェクト
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 *                  　(void) handler:(id)target change:(NSDictionary *)change context:(void*)context
 */
- (instancetype) initForKey:(NSString*)key to:(id)target listener:(id)listener handler:(SEL)handler {
    self = [super init];
    if(nil!=self) {
        self.action = [[MICTargetSelector alloc] initWithTarget:listener selector:handler];
        self.key = key;
        self.target = target;
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
    if(![self.key isEqualToString:key] || self.target != target ) {
        return;
    }
    [self.action beginCall];
    [self.action addArgument:&target];
    [self.action addArgument:&change];
    [self.action addArgument:&context];
    [self.action endCall];
}
@end

#pragma mark - Observer manager class

/**
 * オブザーバーをまとめて管理するクラス
 */
@implementation MICObservers {
    NSMutableDictionary *mDic;      // オブザーバー登録用マップ
    __weak id mObserver;            // オブザーバーの胴元・・・observeValueForKeyPathを実装するクラスのオブジェクト
}

/**
 * 初期化
 * @param observer  observeValueForKeyPathメソッドを実装するオブジェクト
 */
- (instancetype)initWithObserver:(id)observer {
    self = [super init];
    if(nil!=self) {
        mDic = [[NSMutableDictionary alloc] init];
        mObserver = observer;
    }
    return self;
}

/**
 * オブザーバーを追加
 * （options = NSKeyValueObservingOptionNew, context=nil）
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param target    プロパティ監視の対象オブジェクト
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 *                  　(void) handler:(id)target change:(NSDictionary *)change context:(void*)context
 */
- (void) add:(NSString*)key to:(id)target listener:(id)listener handler:(SEL)handler {
    [self add:key to:target listener:listener handler:handler options:NSKeyValueObservingOptionNew context:nil];
}


/**
 * オブザーバーを追加（オプションやコンテキストを個別に指定する版）
 *
 * @param key       キー（＝監視するプロパティ名）
 * @param target    プロパティ監視の対象オブジェクト
 * @param listener  プロパティ変更イベントを受け取るオブジェクト
 * @param handler   イベントハンドラー
 *                  　(void) handler:(id)target change:(NSDictionary *)change context:(void*)context
 * @param options   オブザーバー登録時のオプション
 * @param context   オブザーバー登録時に渡すコンテキスト(nil可)
 */
- (void) add:(NSString*)key to:(id)target listener:(id)listener handler:(SEL)handler options:(NSKeyValueObservingOptions)options context:(void*)context {
    id entry = [mDic valueForKey:key];
    MICObserverItem* item = [[MICObserverItem alloc] initForKey:key to:target listener:listener handler:handler];
    if(nil!=entry) {
        if([entry isKindOfClass:MICObserverItem.class]) {
            NSMutableArray* ary = [[NSArray init] alloc];
            [ary addObject:entry];
            [ary addObject:item];
        } else if([entry isKindOfClass:NSMutableArray.class]) {
            [(NSMutableArray*)entry addObject:item];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"unkonwn entry type."];
        }
    } else {
        [mDic setValue:item forKey:key];
    }
    [target addObserver:mObserver forKeyPath:key options:options context:context];
}

/**
 * オブザーバーを１つずつ削除
 * @param key       キー（＝監視するプロパティ名）
 * @param target    プロパティ監視の対象オブジェクト
 */
- (void) remove:(NSString*)key from:(id)target {
    id entry = [mDic valueForKey:key];
    if(nil!=entry) {
        if([entry isKindOfClass:MICObserverItem.class]) {
            [mDic removeObjectForKey:key];
            [target removeObserver:mObserver forKeyPath:key];
        } else if([entry isKindOfClass:NSMutableArray.class]) {
            NSMutableArray* ary = (NSMutableArray*)entry;
            for(NSInteger i=ary.count-1 ; i>=0 ; i--) {
                MICObserverItem* item = [ary objectAtIndex:i];
                if(item.target == target) {
                    [ary removeObjectAtIndex:i];
                    [target removeObserver:mObserver forKeyPath:key];
                }
                if(ary.count==1) {
                    [mDic setObject:[ary objectAtIndex:0] forKey:key];
                }
                else if(ary.count==0) {
                    [mDic removeObjectForKey:key];
                }
            }
        }
    }
}

/**
 * オブザーバーをすべて削除
 */
- (void) removeAll {
    for(id key in mDic.keyEnumerator) {
        id entry = [mDic objectForKey:key];
        if([entry isKindOfClass:MICObserverItem.class]) {
            MICObserverItem* item = (MICObserverItem*)entry;
            [item.target removeObserver:mObserver forKeyPath:item.key];
        } else if( [entry isKindOfClass:NSMutableArray.class]){
            NSMutableArray* ary = (NSMutableArray*)entry;
            for(MICObserverItem* item in ary) {
                [item.target removeObserver:mObserver forKeyPath:item.key];
            }
        }
    }
    [mDic removeAllObjects];
}

/**
 * インスタンスを破棄
 */
- (void) dispose {
    [self removeAll];
    mObserver = nil;
}

/**
 * 実行
 * mObserverのobserveValueForKeyPathメソッドから呼び出す
 */
- (void) observe:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context {
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
