//
//  WPLObservableMutableData.h
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/02.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLObservableData.h"

/**
 * 最も一般的な監視可能オブジェクト
 */
@interface WPLObservableMutableData: WPLObservableData<IWPLObservableMutableData>

- (void) setIntValue:(NSInteger)v;
- (void) setBoolValue:(bool)v;
- (void) setFloatValue:(CGFloat) v;
- (void) setStringValue:(NSString*)v;

@end

