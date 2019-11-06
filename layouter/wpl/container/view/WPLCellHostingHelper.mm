//
//  WPLCellHostingHelper.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICKeyValueObserver.h"

@implementation WPLCellHostingHelper {
    UIView* __weak _view;
    bool _layoutReserved;
    bool _disableLayout;
    MICKeyValueObserver* _observer;
    WPLBinder* _binder;
    CGFloat _animationDuration;
}

- (WPLBinder*) binder {
    if(nil==_binder) {
        _binder = [WPLBinder new];
    }
    return _binder;
}

- (instancetype) initWithView:(UIView*) view {
    return [self initWithView:view container:nil];
}

- (instancetype) initWithView:(UIView*) view container:(id<IWPLContainerCell>)container {
    self = [super init];
    if(nil!=self) {
        _view = view;
        _layoutReserved = false;
        _disableLayout = false;
        _observer = nil;
        _containerCell = nil;
        _binder = nil;
        _animationDuration = 0;
        if(nil!=container) {
            self.containerCell = container;
        }
    }
    return self;
}

- (void) attach {
    if(_observer==nil && _view!=nil) {
        [self renderCell];
        _observer = [[MICKeyValueObserver alloc] initWithActor:_view];
        [_observer add:@"frame" listener:self handler:@selector(sizePropertyChanged:target:)];
        [_observer add:@"bounds" listener:self handler:@selector(sizePropertyChanged:target:)];
    }
}

- (void) detach {
    if(_observer!=nil) {
        [_observer dispose];
        _observer = nil;
    }
}

- (void) sizePropertyChanged:(id<IMICKeyValueObserverItem>) info target:(id)target {
    [self reserveRender];
}

- (void)dealloc {
    [self dispose];
}

- (void) dispose {
    [self detach];
    if(_containerCell!=nil) {
        [_containerCell dispose];
        _containerCell = nil;
    }
    if(_binder!=nil) {
        [_binder dispose];
        _binder = nil;
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

static inline CGFloat get_point(bool forHorz, const CGPoint& point) {
    return forHorz ? point.x : point.y;
}

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

static inline void set_origin(bool forHorz, MICRect& rect, CGFloat pos=0) {
    if(forHorz) {
        rect.moveLeft(pos);
    } else {
        rect.moveTop(pos);
    }
}

#pragma mark - Rendering

- (void) enableLayout:(bool)sw {
    _disableLayout = !sw;
    if(sw && _layoutReserved) {
        _layoutReserved = false;
        [self reserveRender];
    }
}

- (void) reserveRender {
    if(!_layoutReserved) {
        _layoutReserved = true;
        if(!_disableLayout) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self->_layoutReserved = false;
                [self renderCell];
            }];
        }
    }
}

/**
 * コンテナ内の再配置処理
 */
- (void) renderCell {
    if(_containerCell==nil) {
        return;
    }
    MICRect viewRect(_view.frame.size);
    if(viewRect.isEmpty()) {
        return;
    }
    MICSize cellSize([_containerCell layoutPrepare:viewRect.size]);
    MICRect cellRect(viewRect);
    [self renderSubForHorz:true  viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    [self renderSubForHorz:false viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    
    [_containerCell layoutCompleted:cellRect];
    MICRect contentRect = _containerCell.view.frame;
    if([_view isKindOfClass:UIScrollView.class]) {
        ((UIScrollView*)_view).contentSize = contentRect.size;
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
        // stretch
        set_origin(forHorz, cellRect, get_point(forHorz, viewRect.origin));
        set_size(forHorz, cellRect, get_size(forHorz,viewRect.size));
        return;
    }
    switch([self align:forHorz]) {
        case WPLCellAlignmentSTART:
            set_size(forHorz, cellRect, get_size(forHorz, cellSize));
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

- (void) alignContainerCellForHorz:(bool)forHorz contentRect:(MICRect&) contentRect viewRect:(const MICRect&) viewRect {
    CGFloat cs = get_size(forHorz, contentRect.size);
    CGFloat vs = get_size(forHorz, viewRect.size);
    if(cs>=vs) {
        set_origin(forHorz, contentRect);
        return;
    }
    
    switch([self align:forHorz]) {
        case WPLCellAlignmentSTART:
            move_rect(forHorz, contentRect, diff_point(forHorz, contentRect.LT(), viewRect.LT()));
            break;
        case WPLCellAlignmentEND:
            move_rect(forHorz, contentRect, diff_point(forHorz, contentRect.RB(), viewRect.RB()));
            break;
        case WPLCellAlignmentCENTER:
            move_rect(forHorz, contentRect, diff_point(forHorz, contentRect.center(), viewRect.center()));
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

- (CGFloat)animationDuration {
    return _animationDuration;
}
- (void)setAnimationDuration:(CGFloat)animationDuration {
    _animationDuration = animationDuration;
}
@end
