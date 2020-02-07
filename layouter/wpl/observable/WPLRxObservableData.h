//
//  WPLRxObservableData.h
//
//  Rxオペレーターの簡単なやつだけ対応するクラス
//
//  Created by @toyota-m2k on 2020/02/06.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "WPLObservableData.h"

@interface WPLRxObservableData : WPLObservableData

/**
 * Rx map / select(.net) 相当の値変換を行うObservableプロパティを生成
 * @param sx  変換元データ
 * @param fn  変換関数  id convert(id s)
 */
+ (id<IWPLObservableData>) select:(id<IWPLObservableData>)sx func:(WPLRx1Proc)fn;
+ (id<IWPLObservableData>) map:(id<IWPLObservableData>)sx func:(WPLRx1Proc)fn;      // identical to "select"

/**
 * Rx combineLatest に相当。２系列のデータソースから、新しいObservableを生成。
 * @param sx    ソース１
 * @param sy    ソース２
 * @param fn    変換関数　id convert(id s1, id s2)
 */
+ (id<IWPLObservableData>) combineLatest:(id<IWPLObservableData>)sx with:(id<IWPLObservableData>)sy func:(WPLRx2Proc)fn;

/**
 * Rx where に相当。データソースから条件にあうデータだけを取り出す。
 * @param sx    ソース
 * @param fn    フィルター関数(trueを返した値だけが有効になる)　bool filter(id s)
 */
+ (id<IWPLObservableData>) where:(id<IWPLObservableData>)sx func:(WPLRx1BoolProc)fn;

/**
 * Rx merge に相当。２系列のデータソースを単純にマージ
 * @param sx  ソース１
 * @param sy  ソース２
 */
+ (id<IWPLObservableData>) merge:(id<IWPLObservableData>)sx with:(id<IWPLObservableData>) sy;

/**
 * Rx scan 相当の値変換を行うObservableプロパティを生成
 * @param sx   変換元データ
 * @param fn    変換関数　id convert(id previous, id current)
 */
+ (id<IWPLObservableData>) scan:(id<IWPLObservableData>)sx func:(WPLRx2Proc)fn;

@end

