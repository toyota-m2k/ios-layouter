//
//  WPLFrameScrollView.mm
//
//  Created by toyota-m2k on 2020/02/03.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLFrameScrollView.h"
#import "MICVar.h"

@implementation WPLFrameScrollView

- (WPLFrame*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLFrame.class]) ? (WPLFrame*)s : nil;
}

- (void) setContainer:(WPLFrame*) v {
    self.containerCell = v;
}

+ (WPLFrameScrollView *)frameViewWithName:(NSString *)name params:(WPLCellParams)params {
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
