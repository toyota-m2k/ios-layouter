//
//  WPLObservableData.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/02.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLObservableDef.h"

/**
 * IWPLObservableData の基本実装 (abstract)
 * このクラスを直接使用することはない。
 *  --> WPLObservableMutableData, WPLDelegatedObservableData
 */
@interface WPLObservableData : NSObject<IWPLObservableData>
@end

