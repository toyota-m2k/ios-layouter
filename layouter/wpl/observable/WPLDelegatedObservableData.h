//
//  WPLDelegatedObservableData.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLObservableData.h"

/**
 * 外部の値にデリゲートする監視可能データオブジェクト
 * valueChanged は、デリゲート供給オブジェクトからキックする。
 * WPLObservableMutableDataImpl の relations に登録することで、複数のデータソースにバインドして使うことができる。
 */
@interface WPLDelegatedObservableData : WPLObservableData<IWPLDelegatedDataSource>

+ (instancetype) newDataWithSourceBlock:(WPLSourceDelegateProc)proc;

+ (instancetype) newDataWithSourceTarget:(id)target selector:(SEL)selector;

+ (instancetype) newDataWithSourceTargetSelector:(MICTargetSelector*) ts;

@end
