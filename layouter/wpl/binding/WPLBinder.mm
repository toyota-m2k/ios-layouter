//
//  WPLBinder.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/04.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLBinder.h"
#import "WPLValueBinding.h"
#import "WPLBoolStateBinding.h"
#import "WPLPropBinding.h"
#import "WPLNamedValueBinding.h"
#import "WPLCommandBinding.h"
#import "WPLObservableMutableData.h"
#import "WPLDelegatedObservableData.h"
#import "WPLRxObservableData.h"
#import "WPLSubject.h"
#import "MICVar.h"

/**
 * Cell と　ObservableData のバインドを管理するクラス。
 */
@implementation WPLBinder {
    NSMutableDictionary<id,id<IWPLObservableData>> * _properties;
    NSMutableArray<id<IWPLBinding>>* _bindings;
}

/**
 * 初期化
 */
- (instancetype) init {
    self = [super init];
    if(self!=nil) {
        _properties = [NSMutableDictionary dictionary];
        _bindings = [NSMutableArray array];
        _autoDisposeProperties = true;
        _autoDisposeBindings = true;
    }
    return self;
}

/**
 * すべてのプロパティの変更イベントを発行する
 * 初期化後、プロパティの値をビューに反映したいときに利用。
 */
- (void) trigger {
    for(id<IWPLObservableData> x in _properties.allValues) {
        [x valueChanged];
    }
}

/**
 * keyで識別されるプロパティの変更イベントを発行する
 */
- (void) triggerOf:(id)key {
    let x = _properties[key];
    if(nil!=x) {
        [x valueChanged];
    }
}

/**
 * Binding情報を破棄
 */
- (void)dispose {
    if(nil!=_properties) {
        if(self.autoDisposeProperties) {
            for(id key in _properties.allKeys) {
                let prop = [self propertyForKey:key];
                if(nil!=prop) {
                    [prop dispose];
                }
            }
        }
        [_properties removeAllObjects];
        _properties = nil;
    }
    if(nil!=_bindings) {
        if(self.autoDisposeBindings) {
            for(id<IWPLBinding> b in _bindings) {
                [b dispose];
            }
        }
        [_bindings removeAllObjects];
        _bindings = nil;
    }
}

#pragma mark - bindable properties

/**
 * 登録済みのプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableData型インスタンス（未登録ならnil）
 */
- (id<IWPLObservableData>) propertyForKey:(id)key {
    return _properties[key];
}

/**
 * Observablega*MutableData型のプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableMutableData型インスタンス（未登録、または、指定されたプロパティがMutableでなければnil）
 */
- (id<IWPLObservableMutableData>) mutablePropertyForKey:(id)key {
    let r = [self propertyForKey:key];
    if([r conformsToProtocol:@protocol(IWPLObservableMutableData)]) {
        return (id<IWPLObservableMutableData>)r;
    } else {
        return nil;
    }
}

/**
 * WPLSubject型のプロパティを取得
 * @param key   createSubjectWithValue の戻り値
 * @return IWPLObservableMutableData型インスタンス（未登録、または、WPLSubjectでなければnil）
 */
- (WPLSubject*) subjectForKey:(id)key {
    let r = [self mutablePropertyForKey:key];
    if([r isKindOfClass:WPLSubject.class]) {
        return r;
    } else {
        return nil;
    }
}

/**
 * 通常の値型（ObservableMutableData型）プロパティを作成して登録
 * @param initialValue 初期値
 * @param key プロパティを識別するキー(nilなら、内部で生成して戻り値に返す）。
 * @return プロパティを識別するキー
 */
- (id) createPropertyWithValue:(id)initialValue withKey:(id) key {
    let ov = [WPLObservableMutableData new];
    ov.value = initialValue;
    return [self addProperty:ov forKey:key];
}

/**
 * イベント発行用 ObservableMutableData である、WPLSubjectを作成
 * 取得は、propertyForKey, mutablePropertyForKey でよいが、WPLSubjectを取得する専用メソッド subjectForKey も使える。
 */
- (id) createSubjectWithValue:(id)initialValue withKey:(id) key {
    let s = [WPLSubject new];
    s.value = initialValue;
    return [self addProperty:s forKey:key];
}

/**
 * Rx map / select(.net) 相当の値変換を行うObservableプロパティを生成
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param src 変換元データ
 * @param fn  変換関数  id convert(id s)
 */
- (id) createPropertyWithKey:(id)key map:(id<IWPLObservableData>)src func:(WPLRx1Proc) fn {
    let s = [WPLRxObservableData map:src func:fn];
    return [self addProperty:s forKey:key];
}

/**
 * Rx combineLatest に相当。２系列のデータソースから、新しいObservableを生成。
 * @param key   プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param src   ソース１
 * @param src2  ソース２
 * @param fn    変換関数　id convert(id s1, id s2)
 */
- (id) createPropertyWithKey:(id)key combineLatest:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2 func:(WPLRx2Proc) fn {
    let s = [WPLRxObservableData combineLatest:src with:src2 func:fn];
    return [self addProperty:s forKey:key];
}

- (id) createPropertyWithKey:(id)key combineLatest:(NSArray<id<IWPLObservableData>>*)sources func:(WPLRxNProc) fn {
    let s = [WPLRxObservableData combineLatest:sources func:fn];
    return [self addProperty:s forKey:key];
}

/**
 * Rx where に相当。２系列のデータソースを単純にマージ
 * @param key   プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param src   ソース
 * @param fn    フィルター関数(trueを返した値だけが有効になる)　bool filter(id s)
 */
- (id) createPropertyWithKey:(id)key where:(id<IWPLObservableData>)src func:(WPLRx1BoolProc) fn {
    let s = [WPLRxObservableData where:src func:fn];
    return [self addProperty:s forKey:key];
}

/**
 * Rx merge に相当。２系列のデータソースを単純にマージ
 * @param key   プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param src   ソース１
 * @param src2  ソース２
 */
- (id) createPropertyWithKey:(id)key merge:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2 {
    let s = [WPLRxObservableData merge:src with:src2];
    return [self addProperty:s forKey:key];
}
/**
 * Rx scan 相当の値変換を行うObservableプロパティを生成
 * @param key   プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param src   変換元データ
 * @param fn    変換関数　id convert(id previous, id current)
*/
- (id) createPropertyWithKey:(id)key scan:(id<IWPLObservableData>)src func:(WPLRx2Proc) fn {
    let s = [WPLRxObservableData scan:src func:fn];
    return [self addProperty:s forKey:key];
}

/**
 * 依存型(DelegatedObservableData型）プロパティを生成して登録
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param sourceProc 値を解決するための関数ブロック
 * @param relations このプロパティが依存するプロパティ（のキー）。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(id)relations, ... {
    va_list args;
    va_start(args, relations);
    id r = [self createDependentPropertyWithKey:key sourceProc:sourceProc dependsOn:relations dependsOnArgument:args];
    va_end(args);
    return r;
}

/**
 * 上のメソッドの可変長引数部分をva_list型引数で渡せるようにしたメソッド
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(NSString*) firstRelation dependsOnArgument:(va_list) args {
    let ov = [WPLDelegatedObservableData newDataWithSourceBlock:sourceProc];
    id rel = firstRelation;
    while(rel!=nil) {
        let ovr = _properties[rel];
        if(ovr!=nil) {
            [ovr addRelation:ov];
        }
        rel = va_arg(args, id);
    }
    return [self addProperty:ov forKey:key];
}

/**
 * 外部で作成したObservableData型のインスタンスをプロパティとしてバインダーに登録する。
 * @param prop ObservableData型インスタンス
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 */
- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key {
    if(key==nil) {
        key = prop;
    }
    [_properties setObject:prop forKey:key];
    return key;
}

/**
 * プロパティをバインダーから削除する。
 * @param key   addProperty, createProperty / createDependentProperty などが返した値。
 */
- (void) removeProperty:(id)key {
    if(self.autoDisposeProperties) {
        let prop = [self propertyForKey:key];
        if(nil!=prop){
            [prop dispose];
        }
    }
    [_properties removeObjectForKey:key];
}

#pragma mark - binding properties with cells

/**
 * 外部で作成したバインディングインスタンスを登録する。
 * @param binding   バインディングインスタンス
 */
- (void) addBinding:(id<IWPLBinding>) binding {
    [_bindings addObject:binding];
}

/**
 * セルの値とプロパティのバインディングを作成して登録
 * @param propKey   バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell      バインドするセル
 * @param bindingMode   VIEW_TO_SOURCE_WITH_INIT | VIEW_TO_SOURCE | SOURCE_TO_VIEW | TWOWAY
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                 withValueOfCell:(id<IWPLCellSupportValue>)cell
                     bindingMode:(WPLBindingMode)bindingMode
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLValueBinding alloc] initWithCell:cell source:prop bindingMode:bindingMode customAction:customAction];
    [self addBinding:binding];
    return binding;
}

/**
 * セルの状態(Bool型）とBool型プロパティのバインディングを作成して登録
 * @param propKey       バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell          バインドするセル
 * @param actionType    Cellの何とバインドするか？
 * @param negation      trueにすると、bool値を反転する
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                        negation:(bool) negation
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLBoolStateBinding alloc] initWithCell:cell
                                                     source:prop
                                               customAction:customAction
                                                 actionType:actionType
                                                   negation:negation];
    [self addBinding:binding];
    return binding;
}

/**
 * セルの状態(Bool型）と任意のプロパティの比較結果とのバインディングを作成して登録
 * @param propKey        バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell           バインドするセル
 * @param actionType     Cellの何とバインドするか？
 * @param referenceValue 比較対象値
 * @param equals         == / !=
 * @param customAction   プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                  referenceValue:(id)referenceValue
                          equals:(bool)equals
                    customAction:(WPLBindingCustomAction)customAction {

    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLBoolStateBinding alloc] initWithCell:cell
                                                     source:prop
                                               customAction:customAction
                                                 actionType:actionType
                                             referenceValue:referenceValue
                                                     equals:equals
                                           compareAsBoolean:false];
    [self addBinding:binding];
    return binding;
}


/**
 * セルの値とプロパティのバインディングを作成して登録
 * @param propKey   バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell      バインドするセル
 * @param propType  view のどのプロパティとバインドするか？
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 * @return 作成された binding インスタンス
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                        withCell:(id<IWPLCell>)cell
                        propType:(WPLPropType)propType
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLPropBinding alloc] initWithCell:cell source:prop propType:propType customAction:customAction];
    [self addBinding:binding];
    return binding;
}

- (id<IWPLBinding>) bindProperty:(id)propKey
                        withCell:(id<IWPLCellSupportNamedValue>)cell
                    andValueName:(NSString*) valueName
                     bindingMode:(WPLBindingMode)bindingMode
                     customActin:(WPLBindingCustomAction)customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLNamedValueBinding alloc] initWithCell:cell valueName:valueName source:prop bindingMode:bindingMode customAction:customAction];
    [self addBinding:binding];
    return binding;
}

/**
 * 特殊なバインドを作成　（SOURCE to VIEWのみ）
 * バインドの内容は、customAction に記述する。
 * （ソースが変更されると、customAction が呼び出されるので、そこでなんでも好きなことをするのだ）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                        withCell:(id<IWPLCell>)cell
                    customAction:(WPLBindingCustomAction) customAction {
    let prop = [self propertyForKey:propKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [propKey description]);
        return nil;
    }
    let binding = [[WPLGenericBinding alloc] initWithCell:cell source:prop bindingMode:WPLBindingModeSOURCE_TO_VIEW customAction:customAction];
    [self addBinding:binding];
    return binding;
}

/**
 * コマンド（ボタンタップなど）とプロパティ（通常はWPLSubject）とのバインド（WPLCommandBinding)を生成する。
 */
- (id<IWPLBinding>) bindCommand:(id)subjectKey
                       withCell:(id<IWPLCellSupportCommand>)cell
                   customAction:(WPLBindingCustomAction) customAction {
    let prop = [self propertyForKey:subjectKey];
    if(nil==prop) {
        NSAssert1(false, @"no property %@", [subjectKey description]);
        return nil;
    }
    if(![prop isKindOfClass:WPLSubject.class]) {
        NSLog(@"[WARN] WPLBinder.bindCommand: property is not WPLSubject.");
    }
    let binding = [[WPLCommandBinding alloc] initWithCell:cell source:prop customAction:customAction];
    [self addBinding:binding];
    return binding;
}


/**
 * バインドを解除する
 * @param binding   バインディングインスタンス
 */
- (void) unbind:(id<IWPLBinding>) binding {
    NSInteger i = [_bindings indexOfObject:binding];
    if(i != NSNotFound) {
        if(self.autoDisposeBindings) {
            [binding dispose];
        }
        [_bindings removeObjectAtIndex:i];
    }
}

@end

