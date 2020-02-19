//
//  WPLGridView.m
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLGridをホスティングするビュークラス
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
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
    return [[self alloc] initWithFrame:MICRect() named:name params:params];
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame named:@"" params:WPLGridParams()];
}

- (instancetype) initWithFrame:(CGRect)frame named:(NSString*) name params:(WPLGridParams)params {
    self = [super initWithFrame:frame container:[WPLGrid gridWithName:name params:params]];
    if(nil!=self) {
    }
    return self;
}


@end
