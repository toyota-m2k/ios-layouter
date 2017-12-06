//
//  MICUiLayoutView.m
//
//  レイアウター（MICUiLayoutProtocolに準拠するオブジェクト）を内包するスクロールビューの共通実装
//
//  Created by 豊田 光樹 on 2014/10/31.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiLayoutView.h"

@interface MICUiLayoutView () {
    bool _frameObserverEnabled;
}
@end

@implementation MICUiLayoutView

/**
 * サイズゼロで初期化
 */
- (MICUiLayoutView*) init {
    return [self initWithFrame:CGRectZero];
}

/**
 * 初期サイズを与えて初期化
 */
- (MICUiLayoutView*) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        _layouter = nil;
        _strongLayouter = nil;
        _dragSupport = nil;
        _frameObserverEnabled = false;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        // このタイミングでaddObserverすると、なぜかビューを破棄するタイミングで死ぬ。
        // なので、ビューが親ビューにaddSubviewされるタイミングでやることにする。
//        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

/**
 * 親ビューにアタッチされる/デタッチされる→ビューサイズ監視の開始・終了
 */
- (void)didMoveToSuperview {
    if(nil!=self.superview) {
        // アタッチされる
        if(!_frameObserverEnabled) {
            _frameObserverEnabled = true;
            [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
    } else {
        // デタッチされる
        if(_frameObserverEnabled) {
            _frameObserverEnabled = false;
            [self removeObserver:self forKeyPath:@"frame"];
        }
    }
    //NSLog(@"did move to superview: %@", [self.superview description]);
}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    NSLog(@"move to superview:%@", [newSuperview description]);
//}

/**
 * コンテント管理用のレイアウター（弱参照）をセットする。
 * レイアウター自体を、このオブジェクトに保持させる場合は、strongLayouterプロパティを使用する。
 */
- (void)setLayouter:(id<MICUiLayoutProtocol>)layouter {
    _layouter = layouter;
    _layouter.parentView = self;
}

/**
 * コンテント管理用のレイアウター（強参照）をセットする。
 */
- (void)setStrongLayouter:(id<MICUiLayoutProtocol>)layouter {
    _strongLayouter = layouter;
    [self setLayouter:layouter];
}

/**
 * DragSupportインスタンスを作成
 */
- (void) prepareDragSupporter {
    if(nil==_dragSupport) {
        if(nil==_layouter || ![_layouter conformsToProtocol:@protocol(MICUiDraggableLayoutProtocol)] ) {
            [NSException raise:@"MICUiLayoutView.enableScrollSupport" format:@"layouter property is not appropreate."];
        }
        _dragSupport = [[MICUiCellDragSupport alloc] init];
        _dragSupport.baseView = (nil!=_dragOverlayBaseView) ? _dragOverlayBaseView : self;
        ((MICUiCellDragSupport*)_dragSupport).layouter = (id<MICUiDraggableLayoutProtocol>)_layouter;
    }
    return;
}

/**
 * スクロールサポートの有効化
 */
- (void)enableScrollSupport :(BOOL)enable{
    [self prepareDragSupporter];
    [_dragSupport enableScrollSupport:enable];
}

/**
 * 長押し/タップによるカスタマイズの開始・終了を有効化/無効化
 */
- (void) beginCustomizingWithLongPress:(BOOL)longPress
                            endWithTap:(BOOL)tap {
    [self prepareDragSupporter];
    [_dragSupport beginCustomizingWithLongPress:longPress endWithTap:tap];
}

- (void)beginCustomizing {
    [_dragSupport beginCustomizing];
}

- (void)endCustomizing {
    [_dragSupport endCustomizing];
}
/**
 * ビューのサイズ変更監視
 */
- (void)didChangeValueForKey:(NSString *)key {
    if([key isEqualToString:@"frame"] && nil!=_layouter) {
        [_layouter requestRecalcLayout];
        [_layouter updateLayout:false onCompleted:nil];
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if([keyPath isEqualToString:@"frame"] && nil!=_layouter) {
//    }
//}

//- (void)didAddSubview:(UIView *)subview {
//    if(nil!=_layouter && ![_layouter containsChild:subview]) {
//        [_layouter addChild:subview];
//        [_layouter updateLayout:false onCompleted:nil];
//    }
//}
//
//- (void)willRemoveSubview:(UIView *)subview {
//    if(nil!=_layouter && [_layouter containsChild:subview]) {
//        [_layouter removeChild:subview];
//        [_layouter updateLayout:false onCompleted:nil];
//    }
//}

/**
 * 子ビューを追加
 */
- (void)addChild:(UIView *)view {
    [self insertChild:view beforeSibling:nil updateLayout:false withAnimation:false];
}


/**
 * 子ビューを追加
 */
- (void)addChild:(UIView *)view updateLayout:(bool)update withAnimation:(bool)animation{
    [self insertChild:view beforeSibling:nil updateLayout:update withAnimation:animation];
}


/**
 * 子ビューを挿入
 */
- (void)insertChild:(UIView*)view beforeSibling:(UIView*)sibling {
    [self insertChild:view beforeSibling:sibling updateLayout:false withAnimation:false];
}

/**
 * 子ビューを挿入
 */
- (void)insertChild:(UIView*)view beforeSibling:(UIView*)sibling updateLayout:(bool)update withAnimation:(bool)animation {
    if(nil!=_layouter) {
        [_layouter insertChild:view before:sibling];
        if(update) {
            [_layouter updateLayout:animation onCompleted:nil];
        }
    }
}

/**
 * 子ビューを削除
 */
- (void)removeChild:(UIView*)view {
    [self removeChild:view updateLayout:false withAnimation:false];
}

/**
 * 子ビューを削除
 */
- (void)removeChild:(UIView*)view updateLayout:(bool)update withAnimation:(bool)animation {
    if(nil!=_layouter) {
        [_layouter removeChild:view];
        if(update) {
            [_layouter updateLayout:animation onCompleted:nil];
        }
    }
}

/**
 * レイアウトを更新
 */
- (void)updateLayout:(bool)animation {
    if(nil!=_layouter) {
        [_layouter updateLayout:animation onCompleted:nil];
    }
}

/**
 * コンテントの表示に必要な最小矩形を取得する。
 *  （サブクラスでオーバーライドする）
 */
- (CGSize) calcMinSizeOfContents {
    return self.frame.size;
}

@end
