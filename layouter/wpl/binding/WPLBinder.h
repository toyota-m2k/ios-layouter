//
//  WPLBinder.h
//
//  Cell と　ObservableData のバインドを管理するクラス。
//  このクラスを使わなくても、それぞれのインスタンスをばBindingクラスを使って関連づけていけばよいのだが、
//  Viewごとにそれらの構築用のコードを書いて、どこか（Viewクラスのメンバーなど）に保持しなければならず、コード量も少なくなく、保守性、可読性が悪くなる。
//  そこで、それらを管理するBinderクラスを作成して、できるだけ少ない呼び出しで、バインディングを構築できるようにしたい。
//
//  Created by Mitsuki Toyota on 2019/08/04.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPLBindingDef.h"


@interface WPLBinder : NSObject

#pragma mark - control auto-disposing behavier

/**
 * dispose 時に、登録されている　binding に対して dispose を呼ぶか？
 * default: true
 */
@property (nonatomic) bool autoDisposeBindings;
/**
 * dispose 時に、登録されている　property (ObservableData) に対して dispose を呼ぶか？
 * default: true
 */
@property (nonatomic) bool autoDisposeProperties;

#pragma mark - bindable properties

/**
 * 登録済みのプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableData型インスタンス（未登録ならnil）
 */
- (id<IWPLObservableData>) property:(id)key;

/**
 * 通常の値型（ObservableMutableData型）プロパティを作成して登録
 * @param initialValue 初期値
 * @param key プロパティを識別するキー(nilなら、内部で生成して戻り値に返す）。
 * @return プロパティを識別するキー
 */
- (id) createPropertyWithValue:(id)initialValue withKey:(id) key;

/**
 * Binding情報を破棄
 */
- (void) dispose;

/**
 * 参照型(DelegatedObservableData型）プロパティを生成して登録
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param sourceProc 値を解決するための関数ブロック
 * @param relations このプロパティが依存するプロパティ（のキー）。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(id)relations, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * 外部で作成したObservableData型のインスタンスをプロパティとしてバインダーに登録する。
 * @param prop ObservableData型インスタンス
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 */
- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key;

/**
 * プロパティをバインダーから削除する。
 */
- (void) removeProperty:(id)key;

#pragma mark - binding properties with cells

/**
 * 外部で作成したバインディングインスタンスを登録する。
 * @param binding   バインディングインスタンス
 */
- (void) addBinding:(id<IWPLBinding>) binding;

/**
 * セルの値とプロパティのバインディングを作成して登録
 * @param propKey   バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell      バインドするセル
 * @param bindingMode   VIEW_TO_SOURCE_WITH_INIT | VIEW_TO_SOURCE | SOURCE_TO_VIEW | TWOWAY
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 * @return 作成された binding インスタンス
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                 withValueOfCell:(id<IWPLCell>)cell
                     bindingMode:(WPLBindingMode)bindingMode
                     customActin:(WPLBindingCustomAction)customAction;

/**
 * セルの状態(Bool型）とプロパティのバインディングを作成して登録
 * @param propKey       バインドするプロパティを識別するキー（必ず登録済みのものを指定）
 * @param cell          バインドするセル
 * @param actionType    Cellの何とバインドするか？
 * @param negation      trueにすると、bool値を反転する
 * @param customAction  プロパティ、または、セルの値が変更されたときのコールバック関数（nil可）
 * @return 作成された binding インスタンス
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
             withBoolStateOfCell:(id<IWPLCell>)cell
                      actionType:(WPLBoolStateActionType) actionType
                        negation:(bool) negation
                     customActin:(WPLBindingCustomAction)customAction;

/**
 * バインドを解除する
 * @param binding   バインディングインスタンス
 */
- (void) unbind:(id<IWPLBinding>) binding;


@end

#if defined(__cplusplus)

#if 0
class CWPLObservableDataBuilder {
private:
    id<IWPLObservableData> _od;

public:
    CWPLObservableDataBuilder(id initialValue=nil) {
        _od = [WPLObservableMutableData new];
        if(nil!=initialValue) {
            ((WPLObservableMutableData*)_od).value = initialValue;
        }
    }
    
    CWPLObservableDataBuilder(WPLSourceDelegateProc proc) {
        _od = [WPLDelegatedObservableData newDataWithSourceBlock:proc];
    }
    
    CWPLObservableDataBuilder(id target, SEL sel) {
        _od = [WPLDelegatedObservableData newDataWithSourceTarget:target selector:sel];
    }

    CWPLObservableDataBuilder(const CWPLObservableDataBuilder& src) {
        _od = src._od;
    }
    virtual ~CWPLObservableDataBuilder() {
        _od = nil;
    }
    
    CWPLObservableDataBuilder& addValueChangeListener( id target, SEL selector ) {
        [_od addValueChangedListener:target selector:selector];
        return *this;
    }
    
    CWPLObservableDataBuilder& addRelation(id<IWPLObservableData> rel) {
        [_od addRelation:rel];
        return *this;
    }
    
    id<IWPLObservableData> create() {
        id r = _id;
        _id = nil;
        return r;
    }
    
    void abort() {
        if(nil!=_od) {
            [_od dispose];
            _od = nil;
        }
    }
};

#endif			

#endif

