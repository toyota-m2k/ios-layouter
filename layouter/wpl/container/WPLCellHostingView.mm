//
//  WPLCellHostingView.m
//  WP Layout
//
//  Created by Mitsuki Toyota on 2019/08/08.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCellHostingView.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

/**
 * セルをホスティングするビュー
 */
@implementation WPLCellHostingView {
    bool _needsLayout;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _containerCell = nil;
        _needsLayout = true;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:MICRect::zero()];
}

- (void)setContainerCell:(id<IWPLContainerCell>)containerCell {
    if(nil!=_containerCell) {
        [_containerCell dispose];
        [_containerCell.view removeFromSuperview];
        _containerCell = nil;
    }
    if(containerCell!=nil) {
        _needsLayout = true;
        _containerCell = containerCell;
        _containerCell.containerDelegate = self;
        [self addSubview:_containerCell.view];
        [self renderCell];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self renderCell];
}

- (void) renderCell {
    if(_containerCell==nil) {
        return;
    }
    MICRect viewRect(self.bounds);
    if(viewRect.isEmpty()) {
        return;
    }
//    MICSize reqSize(_containerCell.requestViewSize);
//    if(_containerCell.hAlignment==WPLCellAlignmentSTRETCH) {
//        reqSize.width = viewRect.width();
//    }
//    if(_containerCell.vAlignment==WPLCellAlignmentSTRETCH) {
//        reqSize.height = viewRect.height();
//    }
//    _containerCell.requestViewSize = reqSize;
    
//    if(!_needsLayout && _containerCell.hAlignment==WPLCellAlignmentSTART && _containerCell.vAlignment==WPLCellAlignmentSTART) {
//        return;
//    }

    MICSize cellSize([_containerCell calcMinSizeForRegulatingWidth:viewRect.width()
                                               andRegulatingHeight:viewRect.height()]);
    MICRect cellRect(viewRect);
    [self renderSub:true  viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    [self renderSub:false viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    
    [_containerCell layoutResolvedAt:cellRect.origin inSize:cellRect.size];
    _needsLayout = false;
}

- (WPLCellAlignment) align:(bool)forHorz {
    return (forHorz) ? _containerCell.hAlignment : _containerCell.vAlignment;
}

static inline CGFloat get_size(bool forHorz, const CGSize& size) {
    return forHorz ? size.width : size.height;
}

static inline void set_size(bool forHorz, MICRect& rect, CGFloat v) {
    if(forHorz) {
        rect.setWidth(v);
    } else {
        rect.setHeight(v);
    }
}

//static inline CGFloat get_point(bool forHorz, const CGPoint& point) {
//    return forHorz ? point.x : point.y;
//}

static inline CGFloat diff_point(bool forHorz, const CGPoint& p1, const CGPoint& p2) {
    return forHorz ? p2.x - p1.x : p2.y - p1.y;
}

static inline void move_rect(bool forHorz, MICRect& rect, CGFloat diff) {
    if(forHorz) {
        rect.move(diff, 0);
    } else {
        rect.move(0, diff);
    }
}


- (void) renderSub:(bool)forHorz
          viewRect:(const MICRect&) viewRect
          cellSize:(const MICSize&) cellSize
          cellRect:(MICRect&)cellRect {
    switch([self align:forHorz]) {
        case WPLCellAlignmentSTART:
            cellRect.setWidth(get_size(forHorz, cellSize));
            break;
        case WPLCellAlignmentEND:
            set_size(forHorz, cellRect, get_size(forHorz, cellSize));
            move_rect(forHorz, cellRect, diff_point(forHorz, cellRect.RB(), viewRect.RB()));
            break;
        case WPLCellAlignmentCENTER:
            set_size(forHorz, cellRect, get_size(forHorz, cellSize));
            move_rect(forHorz, cellRect, diff_point(forHorz, cellRect.center(), viewRect.center()));
            break;
        case WPLCellAlignmentSTRETCH:
        default:
            break;
    }
}

- (void)onChildCellModified:(id<IWPLCell>)cell {
    _needsLayout = true;
    [self renderCell];
}


@end
