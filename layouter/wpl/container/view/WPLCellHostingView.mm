//
//  WPLCellHostingView.m
//  WP Layouter
//
//  Created by toyota-m2k on 2019/08/08.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCellHostingView.h"
#import "WPLCellHostingHelper.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"

#if true

@implementation WPLCellHostingView {
    WPLCellHostingHelper* _hosting;
}

- (instancetype)initWithFrame:(CGRect)frame container:(id<IWPLContainerCell>) containerCell {
    self = [super initWithFrame:frame];
    if (self) {
        _hosting = [[WPLCellHostingHelper alloc] initWithView:self container:containerCell];
    }
    return self;
}

/**
 * 初期化 (UIViewの初期化のオーバーライド）
 *  --> 別途、containerCell を設定すること
 */
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame container:nil];
}

- (instancetype)init {
    return [self initWithFrame:MICRect::zero()];
}

/**
 * ビューが親ビューにアタッチ/デタッチされるタイミングでサイズ監視の開始/停止を行う
 */
- (void)didMoveToSuperview {
    if(nil!=self.superview) {
        [_hosting attach];
    } else {
        [_hosting detach];
    }
}

/**
 * containerCellプロパティ (setter)
 * コンテナーセルをアタッチする。
 */
- (void)setContainerCell:(id<IWPLContainerCell>)containerCell {
    _hosting.containerCell = containerCell;
}

- (id<IWPLContainerCell>) containerCell {
    return _hosting.containerCell;
}

- (WPLBinder *)binder {
    return _hosting.binder;
}

@end

#else
/**
 * セルをホスティングするビュー
 * WPLContainerCell (Grid/StackPanel)を直接操作するのは、リサイズ時の再配置などの実装が結構、面倒なので、
 * それらの厄介事を、このビューで吸収してあげようという試み。
 */
@implementation WPLCellHostingView {
    bool _layoutReserved;
}

/**
 * 初期化 (UIViewの初期化と同じ）
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _containerCell = nil;
        _layoutReserved = false;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:MICRect::zero()];
}

#pragma mark - Properties

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
//        _containerCell.view.translatesAutoresizingMaskIntoConstraints = true;
        [self addSubview:_containerCell.view];
        [self reserveRender];
    }
}

/**
 * ビューのサイズ変更を横取りして、コンテナの再配置を実行する。
 */
- (void)setFrame:(CGRect)frame {
    MICRect org(self.frame);
    [super setFrame:frame];
    if(org!=frame) {
        [self reserveRender];
    }
}

/**
 * frameだけではビューサイズの変更を検知できないので、boundsもチェックする。
 * AutoResizingMask を使う場合は、frameしか呼ばれないし、
 * AutoLayout(constraints)を使う場合は、boundsしか呼ばれなかった。いろいろ謎。
 */
- (void)setBounds:(CGRect)bounds {
    MICRect org(self.bounds);
    [super setBounds:bounds];
    if(org!=bounds) {
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
    MICRect viewRect(self.bounds);
    if(viewRect.isEmpty()) {
        return;
    }
    MICSize cellSize([_containerCell layoutPrepare:viewRect.size]);
    MICRect cellRect(viewRect);
    [self renderSubForHorz:true  viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    [self renderSubForHorz:false viewRect:viewRect cellSize:cellSize cellRect:cellRect];
    
    [_containerCell layoutCompleted:cellRect];
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

#endif

