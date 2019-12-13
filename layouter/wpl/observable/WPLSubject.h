//
//  WPLSubject.h
//
//  Created by Mitsuki Toyota on 2019/12/11.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLObservableMutableData.h"

@interface WPLSubject : WPLObservableMutableData

/**
 * next() 的なやつ
 * （値をセットして）valueChangedイベントを発行する。
 */
- (void) trigger;
- (void) trigger:(id)value;


@end

