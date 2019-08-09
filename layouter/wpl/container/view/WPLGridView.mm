//
//  WPLGridView.m
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/09.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLGridView.h"
#import "MICVar.h"

@implementation WPLGridView

- (WPLGrid*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLGrid.class]) ? (WPLGrid*)s : nil;
}

- (void) setContainer:(WPLGrid*) v {
    self.containerCell = v;
}

+ (WPLGridView *) gridViewWithName:(NSString *)name
                            params:(WPLGridParams)params {
    let view = [WPLGridView new];
    view.container = [WPLGrid gridWithName:name params:params];
    return view;
}

@end
