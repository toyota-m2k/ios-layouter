//
//  WPLObservableData.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLObservableDef.h"

/**
 * IWPLObservableData の基本実装 (abstract)
 * このクラスを直接使用することはない。
 *  --> WPLObservableMutableData, WPLDelegatedObservableData
 */
@interface WPLObservableData : NSObject<IWPLObservableData>
@end

