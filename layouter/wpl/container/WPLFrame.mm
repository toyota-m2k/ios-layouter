//
//  WPLFrame.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/08.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLFrame.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"



@implementation WPLFrame {
    MICSize _cachedSize;
}

- (void) innerLayout:(const MICSize&)fixedSize {
    MICSize cellSize;
    for(id<IWPLCell>cell in self.cells) {
        MICSize size;
        if(cell.visibility!=WPLVisibilityCOLLAPSED) {
            size = [cell calcMinSizeForRegulatingWidth:fixedSize.width andRegulatingHeight:fixedSize.height];
            cellSize.width = MAX(cellSize.width, size.width);
            cellSize.height = MAX(cellSize.height, size.height);
        }
        [cell layoutResolvedAt:MICPoint::zero() inSize:size];
    }
    _cachedSize = MICSize( fixedSize.width==0  ? cellSize.width  : fixedSize.width,
                           fixedSize.height==0 ? cellSize.height : fixedSize.height);
    self.needsLayoutChildren = false;
}

- (CGSize)layout {
    if(self.needsLayoutChildren) {
        [self innerLayout:self.requestViewSize];
    }
    // Viweの位置はそのままで、サイズだけ変更する
    if (MICSize(_cachedSize) != self.view.frame.size) {
        self.view.frame = MICRect(self.view.frame.origin, _cachedSize);
    }
    self.needsLayout = false;
    return _cachedSize+self.margin;
}

- (CGSize)calcMinSizeForRegulatingWidth:(CGFloat)regulatingWidth andRegulatingHeight:(CGFloat)regulatingHeight {
    if(self.needsLayoutChildren) {
        MICSize fixSize( (self.requestViewSize.width>0) ? self.requestViewSize.width : regulatingWidth,
                        (self.requestViewSize.height>0) ? self.requestViewSize.height : regulatingHeight );
        [self innerLayout:fixSize];
    }
    return _cachedSize+self.margin;
}

- (void)layoutResolvedAt:(CGPoint)point inSize:(CGSize)size {
    self.needsLayout = false;
    if(self.visibility==WPLVisibilityCOLLAPSED) {
        return;
    }
    MICSize viewSize = MICSize(size)-self.margin;
    if(  (self.hAlignment==WPLCellAlignmentSTRETCH && viewSize.width==_cachedSize.width && self.requestViewSize.width == 0)
       ||(self.vAlignment==WPLCellAlignmentSTRETCH && viewSize.height==_cachedSize.height && self.requestViewSize.height == 0) ) {
        // STRETCH の場合に、与えられたサイズを使って配置を再計算する
        [self innerLayout:viewSize];
    }
}

@end
