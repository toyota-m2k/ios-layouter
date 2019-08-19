//
//  WPLFrameView.m
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLFrameをホスティングするビュークラス
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLFrameView.h"
#import "MICVar.h"

@implementation WPLFrameView

- (WPLFrame*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLFrame.class]) ? (WPLFrame*)s : nil;
}

- (void) setContainer:(WPLFrame*) v {
    self.containerCell = v;
}


+ (WPLFrameView *)frameViewWithName:(NSString *)name params:(WPLCellParams)params {
    let view = [WPLFrameView new];
    view.containerCell = [WPLFrame frameWithName:name params:params];
    return view;
}

@end
