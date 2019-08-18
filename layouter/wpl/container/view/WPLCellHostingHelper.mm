//
//  WPLCellHostingHelper.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/18.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICKeyValueObserver.h"

@implementation WPLCellHostingHelper {
    UIView* __weak _view;
    bool _layoutReserved;
    MICKeyValueObserver* _observer;
}

- (instancetype) initWithView:(UIView*) view {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _layoutReserved = false;
        _observer = [[MICKeyValueObserver alloc] initWithActor:view];
        [_observer add:@"frame" listener:self handler:@selector(sizePropertyChanged:target:)];
        [_observer add:@"bounds" listener:self handler:@selector(sizePropertyChanged:target:)];
    }
    return self;
}

- (void) sizePropertyChanged:(id<IMICKeyValueObserverItem>) info target:(id)target {
    [self reserveRender];
}

- (void)dealloc {
    [self dispose];
}

- (void) dispose {
    if(nil!=_observer) {
        [_observer dispose];
        _observer = nil;
    }
}

/**
 * containerCellプロパティ (setter)
 * コンテナーセルをアタッチする。
 */
- (void)setContainerCell:(id<IWPLContainerCell>)containerCell {
    if(nil!=_containerCell) {
        [_containerCell dispose];
        [_containerCell.view removeFromSuperview];
        _containerCell = nil;
    }
    if(containerCell!=nil) {
        _containerCell = containerCell;
        _containerCell.containerDelegate = self;
        [_view addSubview:_containerCell.view];
        [self reserveRender];
    }
}

#pragma mark - Rendering Utilities

/**
 * 指定方向のアラインメントを取得
 */
- (WPLCellAlignment) align:(bool)forHorz {
    return (forHorz) ? _containerCell.hAlignment : _containerCell.vAlignment;
}

/**
 * 指定方向のサイズを取得
 */
static inline CGFloat get_size(bool forHorz, const CGSize& size) {
    return forHorz ? size.width : size.height;
}

/**
 * 指定方向のサイズを設定
 */
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

/**
 * ２点間の指定方向の距離を取得
 */
static inline CGFloat diff_point(bool forHorz, const CGPoint& p1, const CGPoint& p2) {
    return forHorz ? p2.x - p1.x : p2.y - p1.y;
}

/**
 * 指定方向に、点を移動
 */
static inline void move_rect(bool forHorz, MICRect& rect, CGFloat diff) {
    if(forHorz) {
        rect.move(diff, 0);
    } else {
        rect.move(0, diff);
    }
}

#pragma mark - Rendering

- (void) reserveRender {
    if(!_layoutReserved) {
        _layoutReserved = true;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self renderCell];
        }];
    }
}

/**
 * コンテナ内の再配置処理
 */
- (void) renderCell {
    _layoutReserved = false;
    if(_containerCell==nil) {
        return;
    }
    MICRect viewRect(_view.bounds);
    if(viewRect.isEmpty()) {
        return;
    }
    MICSize cellSize([_containerCell layoutPrepare:viewRect.size]);
    MICRect cellRect(viewRect);
    [self renderSubForHorz:true  viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    [self renderSubForHorz:false viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    
    [_containerCell layoutCompleted:cellRect];
    if([_view isKindOfClass:UIScrollView.class]) {
        ((UIScrollView*)_view).contentSize = _containerCell.view.frame.size;
    }
}

/**
 * 横・縦方向それぞれについて配置を計算する
 */
- (void) renderSubForHorz:(bool)forHorz
                 viewRect:(const MICRect&) viewRect
                 cellSize:(const MICSize&) cellSize
                 cellRect:(MICRect&)cellRect {
    if(get_size(forHorz, _containerCell.requestViewSize)<0) {
        return; // stretch
    }
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
        default:
            break;
    }
}

#pragma mark - IWPLContainerCellDelegate i/f

/**
 * コンテナ内の子セルからの再配置要求を受け取る
 * IWPLContainerCellDelegate
 */
- (void)onChildCellModified:(id<IWPLCell>)cell {
    [self reserveRender];
}


@end
