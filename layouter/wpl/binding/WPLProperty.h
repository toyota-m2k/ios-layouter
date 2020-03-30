//
//  WPLProperty.h
//
//  Created by @toyota-m2k on 2020/03/25.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLObservableDef.h"
#import "WPLSubject.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * WPLBinder / WPLBinderBuilder とセットで使える名前付きプロパティクラス
 *
 * バインドするプロパティが少数なら、WPLBinderBuilder の propertyメソッドで名前付きプロパティを構築すればよいが、
 * プロパティ数が多い場合や、ViewModelクラスを作るような場合には、プロパティが個別のインスタンスになっていた方が便利な場合がある。
 * WPLPropertyクラスは、まず、そのファクトリメソッドで、個々のプロパティインスタンスを作成しておいて、
 * WPLBinderBuilder.property(WPLProperty*) メソッドで、バインダーに追加して使う。
 */

@interface WPLProperty : NSObject

@property (nonatomic,readonly) id<IWPLObservableData> data;
@property (nonatomic,readonly) NSString* name;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

/**
 * 基本的な初期化
 */
- (instancetype) initAsName:(NSString*)name andData:(nullable id<IWPLObservableData>)data;

/**
 * リスナーなどの解放
 */
- (void) dispose;

/**
 * 依存型(DelegatedObservableData型）プロパティを生成して登録
 * @param name プロパティを識別する名前。
 * @param sourceProc 値を解決するための関数ブロック
 * @param relations このプロパティが依存するプロパティ（のキー）。。。このメソッドが呼び出される時点で解決できなければ、指定は無効となるので、定義順序に注意。
 */
+ (instancetype) delegatedDataAsName:(NSString*)name sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(WPLProperty*)relations, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * 上のメソッドの可変長引数部分をva_list型引数で渡せるようにしたメソッド
 */
+ (instancetype) delegatedDataAsName:(NSString*)name sourceProc:(WPLSourceDelegateProc)sourceProc dependsOn:(WPLProperty*) firstRelation dependsOnArgument:(va_list) args;

/**
 * Rx map / select(.net) 相当の値変換を行うObservableプロパティを生成
 * @param name プロパティを識別する名前。
 * @param src 変換元データ
 * @param fn  変換関数  id convert(id s)
 */
+ (instancetype) selectAsName:(NSString *)name src:(id<IWPLObservableData>)src func:(WPLRx1Proc)fn;
+ (instancetype) mapAsName:(NSString*)name src:(id<IWPLObservableData>)src func:(WPLRx1Proc) fn;
/**
 * Rx combineLatest に相当。２系列のデータソースから、新しいObservableを生成。
 * @param name プロパティを識別する名前。
 * @param src   ソース１
 * @param src2  ソース２
 * @param fn    変換関数　id convert(id s1, id s2)
 */
+ (instancetype) combineLatestAsName:(NSString*)name src:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2 func:(WPLRx2Proc) fn;

/**
 * ３つ以上のobservableをcombineする
 */
+ (instancetype) combineLatestAsName:(NSString *)name sources:(NSArray<id<IWPLObservableData>>*)sources func:(WPLRxNProc)fn;


/**
 * Rx where に相当。２系列のデータソースを単純にマージ
 * @param name プロパティを識別する名前。
 * @param src   ソース
 * @param fn    フィルター関数(trueを返した値だけが有効になる)　bool filter(id s)
 */
+ (instancetype) whereAsName:(NSString*)name src:(id<IWPLObservableData>)src func:(WPLRx1BoolProc) fn;

/**
 * Rx merge に相当。２系列のデータソースを単純にマージ
 * @param name プロパティを識別する名前。
 * @param src   ソース１
 * @param src2  ソース２
 */
+ (instancetype) mergeAsName:(NSString*)name src:(id<IWPLObservableData>)src with:(id<IWPLObservableData>)src2;

/**
 * Rx scan 相当の値変換を行うObservableプロパティを生成
 * @param name プロパティを識別する名前。
 * @param src   変換元データ
 * @param fn    変換関数　id convert(id previous, id current)
*/
+ (instancetype) scanAsName:(NSString*)name src:(id<IWPLObservableData>)src func:(WPLRx2Proc) fn;

@end

@interface WPLMutableProperty : WPLProperty

@property (nonatomic,readonly) id<IWPLObservableMutableData> mutableData;

/**
 * 通常の値型（ObservableMutableData型）プロパティを作成して登録
 * @param initialValue 初期値
 * @param name プロパティを識別する名前。
 * @return プロパティを識別するキー
 */
+ (instancetype) dataAsName:(NSString*) name initialValue:(nullable id)initialValue;

@end

@interface WPLCommand : WPLMutableProperty

@property (nonatomic,readonly) WPLSubject* subject;

- (id) subscribe:(id)target action:(SEL)action;

- (void) unsubscribe:(id)key;


/**
 * イベント発行用 ObservableMutableData である、WPLSubjectを作成
 * 取得は、propertyForKey, mutablePropertyForKey でよいが、WPLSubjectを取得する専用メソッド subjectForKey も使える。
 */
+ (instancetype) commandAsName:(NSString*) name initialValue:(nullable id)initialValue;


@end

NS_ASSUME_NONNULL_END
