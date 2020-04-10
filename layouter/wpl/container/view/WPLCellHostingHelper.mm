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
#import "MICTargetSelector.h"

enum Orientation {
    VERT=0,
    HORZ=1,
};

@implementation WPLCellHostingHelper {
    UIView* __weak _view;
    bool _layoutReserved;
    bool _disableLayout;
    MICKeyValueObserver* _observer;
    WPLBinder* _binder;
    CGFloat _animationDuration;
    MICTargetSelector* _layoutCompletionListener;
    WPLRenderingMode _renderingMode;
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
        _layoutCompletionListener = nil;
        _renderingMode = WPLRenderingNORMAL;
        if(nil!=container) {
            self.containerCell = container;
        }
    }
    return self;
}

/**
 * レンダリング完了通知を受け取るためのリスナー
 */
- (void) setLayoutCompletionEventListener:(id)target action:(SEL)action {
    if(target==nil||action==nil) {
        _layoutCompletionListener = nil;
    } else {
        _layoutCompletionListener = [MICTargetSelector targetSelector:target selector:action];
    }
}

- (void) attach {
    if(_observer==nil && _view!=nil) {
        [self renderCell:WPLRenderingSIZING];
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
    // サイズが変わったら、すべてのコンテナの配置を再計算する必要がある、
    [_containerCell invalidateAllLayout];
    [self reserveRender:WPLRenderingSIZING];
}

- (void)dealloc {
    [self dispose];
}

- (void) dispose {
    [self detach];
    _layoutCompletionListener = nil;
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
        [self reserveRender:WPLRenderingSIZING];
    }
}

#pragma mark - Rendering Utilities

/**
 * 指定方向のアラインメントを取得
 */
- (WPLCellAlignment) align:(Orientation) o {
    return (o==HORZ) ? _containerCell.hAlignment : _containerCell.vAlignment;
}

/**
 * 指定方向のサイズを取得
 */
static inline CGFloat get_size(Orientation o, const CGSize& size) {
    return o==HORZ ? size.width : size.height;
}

/**
 * 指定方向のサイズを設定
 */
static inline void set_size(Orientation o, MICRect& rect, CGFloat v) {
    if(o==HORZ) {
        rect.setWidth(v);
    } else {
        rect.setHeight(v);
    }
}

static inline CGFloat get_point(Orientation o, const CGPoint& point) {
    return o==HORZ ? point.x : point.y;
}

/**
 * ２点間の指定方向の距離を取得
 */
static inline CGFloat diff_point(Orientation o, const CGPoint& p1, const CGPoint& p2) {
    return o==HORZ ? p2.x - p1.x : p2.y - p1.y;
}

/**
 * 指定方向に、点を移動
 */
static inline void move_rect(Orientation o, MICRect& rect, CGFloat diff) {
    if(o==HORZ) {
        rect.move(diff, 0);
    } else {
        rect.move(0, diff);
    }
}

static inline void set_origin(Orientation o, MICRect& rect, CGFloat pos=0) {
    if(o==HORZ) {
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
        [self reserveRender:_renderingMode];
    }
}

- (void) reserveRender:(WPLRenderingMode)mode {
    if(!_layoutReserved) {
        _layoutReserved = true;
        _renderingMode = MAX(mode,_renderingMode);
        if(!_disableLayout) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self->_layoutReserved = false;
                let mode = self->_renderingMode;
                self->_renderingMode = WPLRenderingNORMAL;
                [self renderCell:mode];
            }];
        }
    }
}

//#define USE_ORG_LAYOUT_SYSTEM
/**
 * コンテナ内の再配置処理
 */
- (void) renderCell:(WPLRenderingMode)mode {
    if(_containerCell==nil) {
        return;
    }
    MICRect viewRect(_view.frame.size);
    if(viewRect.isEmpty()) {
        return;
    }
    
#ifndef USE_ORG_LAYOUT_SYSTEM
    MICRect frameRect(_view.bounds);
    [_containerCell beginRendering:mode];
    if([_view isKindOfClass:UIScrollView.class]) {
        MICSize contentSize([_containerCell calcCellWidth:frameRect.width()],[_containerCell calcCellHeight:frameRect.height()]);
        contentSize.width = MAX(contentSize.width, frameRect.width());
        contentSize.height = MAX(contentSize.height, frameRect.height());
        ((UIScrollView*)_view).contentSize = contentSize;
        [_containerCell endRenderingInRect:MICRect(contentSize)];
    } else {
        [_containerCell calcCellWidth:frameRect.width()];
        [_containerCell calcCellHeight:frameRect.height()];
        [_containerCell endRenderingInRect:frameRect];
    }
#else
    MICSize cellSize([_containerCell layoutPrepare:viewRect.size]);
    MICRect cellRect(viewRect);
    [self renderSub:HORZ  viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    [self renderSub:VERT viewRect:viewRect cellSize:cellSize cellRect:cellRect];
  
    [_containerCell layoutCompleted:cellRect];
    MICRect contentRect = _containerCell.view.frame;
    if([_view isKindOfClass:UIScrollView.class]) {
        ((UIScrollView*)_view).contentSize = contentRect.size;
    }
#endif

    if(nil!=_layoutCompletionListener) {
        id p = _view;
        [_layoutCompletionListener performWithParam:&p];
    }
}

/**
 * 横・縦方向それぞれについて配置を計算する
 */
- (void) renderSub:(Orientation) orientation
                 viewRect:(const MICRect&) viewRect
                 cellSize:(const MICSize&) cellSize
                 cellRect:(MICRect&)cellRect {
    if(get_size(orientation, _containerCell.requestViewSize)<0) {
        // stretch
        set_origin(orientation, cellRect, get_point(orientation, viewRect.origin));
        set_size(orientation, cellRect, get_size(orientation,viewRect.size));
        return;
    }
    switch([self align:orientation]) {
        case WPLCellAlignmentSTART:
            set_size(orientation, cellRect, get_size(orientation, cellSize));
            break;
        case WPLCellAlignmentEND:
            set_size(orientation, cellRect, get_size(orientation, cellSize));
            move_rect(orientation, cellRect, diff_point(orientation, cellRect.RB(), viewRect.RB()));
            break;
        case WPLCellAlignmentCENTER:
            set_size(orientation, cellRect, get_size(orientation, cellSize));
            move_rect(orientation, cellRect, diff_point(orientation, cellRect.center(), viewRect.center()));
            break;
        default:
            break;
    }
}

//- (void) alignContainerCellForHorz:(Orientation)orientation contentRect:(MICRect&) contentRect viewRect:(const MICRect&) viewRect {
//    CGFloat cs = get_size(orientation, contentRect.size);
//    CGFloat vs = get_size(orientation, viewRect.size);
//    if(cs>=vs) {
//        set_origin(orientation, contentRect);
//        return;
//    }
//
//    switch([self align:orientation]) {
//        case WPLCellAlignmentSTART:
//            move_rect(orientation, contentRect, diff_point(orientation, contentRect.LT(), viewRect.LT()));
//            break;
//        case WPLCellAlignmentEND:
//            move_rect(orientation, contentRect, diff_point(orientation, contentRect.RB(), viewRect.RB()));
//            break;
//        case WPLCellAlignmentCENTER:
//            move_rect(orientation, contentRect, diff_point(orientation, contentRect.center(), viewRect.center()));
//            break;
//        default:
//            break;
//    }
//}
//
#pragma mark - IWPLContainerCellDelegate i/f

/**
 * コンテナ内の子セルからの再配置要求を受け取る
 * IWPLContainerCellDelegate
 */
- (void)onChildCellModified:(id<IWPLCell>)cell {
    [self reserveRender:WPLRenderingNORMAL];
}

- (CGFloat)animationDuration {
    return _animationDuration;
}
- (void)setAnimationDuration:(CGFloat)animationDuration {
    _animationDuration = animationDuration;
}
@end
