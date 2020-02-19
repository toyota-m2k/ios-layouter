//
//  WPLStackPanelView.mm
//  WP Layouter
//  WP Layouter のルートコンテナとしての機能を持った、WPLStackViewをホスティングするビュークラス
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLStackPanelView.h"
#import "MICVar.h"

@implementation WPLStackPanelView

- (WPLStackPanel*) container {
    let s = self.containerCell;
    return ([s isKindOfClass:WPLStackPanel.class]) ? (WPLStackPanel*)s : nil;
}

- (void) setContainer:(WPLStackPanel*) v {
    self.containerCell = v;
}

+ (instancetype) stackPanelViewWithName:(NSString*) name
                                 params:(WPLStackPanelParams) params {
    return [[self alloc] initWithFrame:MICRect() named:name params:params];
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame named:@"" params:WPLStackPanelParams()];
}

- (instancetype) initWithFrame:(CGRect)frame named:(NSString*) name params:(WPLStackPanelParams)params {
    self = [super initWithFrame:frame container:[WPLStackPanel stackPanelWithName:name params:params]];
    if(nil!=self) {
    }
    return self;
}



@end
