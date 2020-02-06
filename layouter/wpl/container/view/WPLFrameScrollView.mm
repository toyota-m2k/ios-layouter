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
    let view = [WPLFrameScrollView new];
    view.containerCell = [WPLFrame frameWithName:name params:params];
    return view;
}
@end
