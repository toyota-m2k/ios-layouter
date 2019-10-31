//
//  WPLGridScrollView.m
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLGridをホスティングするスクロールビュークラス
//
//  Created by toyota-m2k on 2019/08/19.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLGridScrollView.h"
#import "MICVar.h"

@implementation WPLGridScrollView

- (WPLGrid*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLGrid.class]) ? (WPLGrid*)s : nil;
}

- (void) setContainer:(WPLGrid*) v {
    self.containerCell = v;
}

- (void) reformWithParams:(const WPLGridParams&) params updateCell:(WPLUpdateCellPosition) updateCellPosition {
    self.containerCell = [self.container reformWithParams:params updateCell:updateCellPosition];
}

+ (instancetype) gridViewWithName:(NSString *)name
                            params:(WPLGridParams)params {
    let view = [WPLGridScrollView new];
    view.container = [WPLGrid gridWithName:name params:params];
    return view;
}

@end
