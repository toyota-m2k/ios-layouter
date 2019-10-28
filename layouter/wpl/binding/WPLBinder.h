//
//  WPLBinder.h
//
//  Cell と　ObservableData のバインドを管理するクラス。
//  このクラスを使わなくても、それぞれのインスタンスをばBindingクラスを使って関連づけていけばよいのだが、
//  Viewごとにそれらの構築用のコードを書いて、どこか（Viewクラスのメンバーなど）に保持しなければならず、コード量も少なくなく、保守性、可読性が悪くなる。
//  Cell/ObservableData/Binding は、もう少し柔軟な操作が可能だが、柔軟性を多少犠牲にして（例えばプロパティはすべて文字列の名前をつけてアクセスする、とか）、
//  できるだけ簡潔に利用できるようにすることを目指したクラス。
//
//  Created by toyota-m2k on 2019/08/04.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

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

/**
 * Binding情報を破棄
 */
- (void) dispose;


#pragma mark - bindable properties

/**
 * 登録済みのプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableData型インスタンス（未登録ならnil）
 */
- (id<IWPLObservableData>) propertyForKey:(id)key;

/**
 * Observablega*MutableData型のプロパティを取得
 * @param key   createProperty/createDependentProperty の戻り値
 * @return IWPLObservableMutableData型インスタンス（未登録、または、指定されたプロパティがMutableでなければnil）
 */
- (id<IWPLObservableMutableData>) mutablePropertyForKey:(id)key;

/**
 * 通常の値型（ObservableMutableData型）プロパティを作成して登録
 * @param initialValue 初期値
 * @param key プロパティを識別するキー(nilなら、内部で生成して戻り値に返す）。
 * @return プロパティを識別するキー
 */
- (id) createPropertyWithValue:(id)initialValue withKey:(id) key;

/**
 * 依存型(DelegatedObservableData型）プロパティを生成して登録
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 * @param sourceProc 値を解決するための関数ブロック
 * @param relations このプロパティが依存するプロパティ（のキー）。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(id)relations, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * 上のメソッドの可変長引数部分をva_list型引数で渡せるようにしたメソッド
 */
- (id) createDependentPropertyWithKey:(id)key sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(NSString*) firstRelation dependsOnArgument:(va_list) args;

/**
 * 外部で作成したObservableData型のインスタンスをプロパティとしてバインダーに登録する。
 * @param prop ObservableData型インスタンス
 * @param key プロパティを識別するキー（nilなら内部で生成して戻り値に返す）。
 */
- (id) addProperty:(id<IWPLObservableData>) prop forKey:(id) key;

/**
 * プロパティをバインダーから削除する。
 * @param key   addProperty, createProperty / createDependentProperty などが返した値。
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
                     customActin:(WPLBindingCustomAction)customAction;

/**
 * 特殊なバインドを作成　（SOURCE to VIEWのみ）
 * バインドの内容は、customAction に記述する。
 * （ソースが変更されると、customAction が呼び出されるので、そこでなんでも好きなことをするのだ）
 */
- (id<IWPLBinding>) bindProperty:(id)propKey
                        withCell:(id<IWPLCell>)cell
                    customAction:(WPLBindingCustomAction) customAction;

/**
 * バインドを解除する
 * @param binding   バインディングインスタンス
 */
- (void) unbind:(id<IWPLBinding>) binding;


@end

#if defined(__cplusplus)

class WPLBinderBuilder {
private:
    WPLBinder* _binder;
public:
    WPLBinderBuilder() {
        _binder = [WPLBinder new];
    }
    WPLBinderBuilder(WPLBinder* binder) {
        _binder = binder;
    }
    WPLBinderBuilder(const WPLBinderBuilder& src) {
        _binder = src._binder;
    }
    ~WPLBinderBuilder() {
        _binder = nil;
    }
    
    /**
     * nameという名前のプロパティを作成（初期値 nil）
     */
    WPLBinderBuilder& property(NSString* name) {
        [_binder createPropertyWithValue:nil withKey:name];
        return *this;
    }
    /**
     * nameという名前のプロパティを作成（初期値 int）
     */
    WPLBinderBuilder& property(NSString* name, int initialValue) {
        [_binder createPropertyWithValue:@(initialValue) withKey:name];
        return *this;
    }
    /**
     * nameという名前のプロパティを作成（初期値 long）
     */
    WPLBinderBuilder& property(NSString* name, long initialValue) {
        [_binder createPropertyWithValue:@(initialValue) withKey:name];
        return *this;
    }
    /**
     * nameという名前のプロパティを作成（初期値 CGFloat）
     */
    WPLBinderBuilder& property(NSString* name, CGFloat initialValue) {
        [_binder createPropertyWithValue:@(initialValue) withKey:name];
        return *this;
    }
    /**
     * nameという名前のプロパティを作成（初期値 bool）
     */
    WPLBinderBuilder& property(NSString* name, bool initialValue) {
        [_binder createPropertyWithValue:@(initialValue) withKey:name];
        return *this;
    }
    /**
     * nameという名前のプロパティを作成（初期値 string）
     */
    WPLBinderBuilder& property(NSString* name, NSString* initialValue) {
        [_binder createPropertyWithValue:initialValue withKey:name];
        return *this;
    }

    /**
     * nameという名前の依存型（DelegatedObservableData）プロパティを作成
     *
     * @param name プロパティ名
     * @param sourceProc 値を解決するための関数ブロック
     * @param dependsOn このプロパティが依存するプロパティ名の配列。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
     */
    WPLBinderBuilder& dependentProperty(NSString* name, WPLSourceDelegateProc sourceProc, NSString* dependsOn=nil, ...) {
        va_list args;
        va_start(args, dependsOn);
        [_binder createDependentPropertyWithKey:name sourceProc:sourceProc dependsOn:dependsOn dependsOnArgument:args];
        va_end(args);
        return *this;
    }
    
    /**
     * nameで指定されたプロパティを、cellのvalue にバインドする
     */
    WPLBinderBuilder& bind(NSString* name, id<IWPLCell> cell, WPLBindingMode mode=WPLBindingModeSOURCE_TO_VIEW, WPLBindingCustomAction customAction=nil) {
        [_binder bindProperty:name withValueOfCell:cell bindingMode:mode customActin:customAction];
        return *this;
    }
    
    /**
     * nameで指定されたプロパティを、cellのboolState（visible/enabled/readonly）にバインドする
     */
    WPLBinderBuilder& bind(NSString* name, id<IWPLCell> cell, WPLBoolStateActionType actionType, bool negation=false, WPLBindingCustomAction customAction=nil ) {
        [_binder bindProperty:name withBoolStateOfCell:cell actionType:actionType negation:negation customActin:customAction];
        return *this;
    }

    /**
     * nameで指定されたプロパティを、cellが持つviewのプロパティに直接バインドする。
     * 現在バインド可能なプロパティは、enum WPLPropType で定義されている。
     */
    WPLBinderBuilder& bind(NSString* name, id<IWPLCell> cell, WPLPropType propType, WPLBindingCustomAction customAction=nil ) {
        [_binder bindProperty:name withCell:cell propType:propType customActin:customAction];
        return *this;
    }
    
    /**
     * nameで指定されたプロパティをcellに対してバインドし、その動作をcustomActionで定義する。
     */
    WPLBinderBuilder& bindCustom(NSString* name, id<IWPLCell> cell, WPLBindingCustomAction customAction) {
        [_binder bindProperty:name withCell:cell customAction:customAction];
        return *this;
    }
    
    WPLBinder* build() {
        return _binder;
    }
};

#endif

