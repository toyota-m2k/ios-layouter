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


+ (instancetype)frameViewWithName:(NSString *)name params:(WPLCellParams)params {
    return [[self alloc] initWithFrame:MICRect() named:name params:params];
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame named:@"" params:WPLCellParams()];
}

- (instancetype) initWithFrame:(CGRect)frame named:(NSString*) name params:(WPLCellParams)params {
    self = [super initWithFrame:frame container:[WPLFrame frameWithName:name params:params]];
    if(nil!=self) {
    }
    return self;
}

@end
