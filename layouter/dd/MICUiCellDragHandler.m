//
//  MICUiCellDragHandler.m
//
//  MICUiCellDragSupport/MICUiCellDragSupportEx 共通のイベントハンドラ実装
//
//  Created by 豊田 光樹 on 2014/11/07.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//
#import "MICUiLayout.h"
#import "MICUiCellDragHandler.h"

/**
 * MICUiCellDragSupport/MICUiCellDragSupportEx でD&Dイベントをハンドリングするためのクラス
 */
@implementation MICUiCellDragHandler {
    __weak id<MICUiDragSupporter> _owner;
    UIPanGestureRecognizer* _panGesture;
    UITapGestureRecognizer* _tapGesture;
    UILongPressGestureRecognizer* _longpressGesture;
}

/**
 * 初期化
 */
- (MICUiCellDragHandler*) initWithOwner:(id<MICUiDragSupporter>)owner {
    self = [super init];
    if(nil!=self) {
        _owner = owner;
        _panGesture = nil;
        _tapGesture = nil;
        _longpressGesture = nil;
    }
    return self;
}

- (void) enableLongPressRecognizer:(BOOL)longPress
                  andTapRecognizer:(BOOL)tap {
    if(tap) {
        if(nil==_tapGesture) {
            _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        }
    } else {
        _tapGesture = nil;
    }
    
    if(longPress) {
        if(nil==_longpressGesture) {
            _longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        }
    } else {
        _longpressGesture = nil;
    }
}

/**
 * (PRIVATE) 長押しイベントのハンドラ
 */
- (void)onLongPress:(UILongPressGestureRecognizer*) sender {
    if(sender.state == UIGestureRecognizerStateBegan) {
        if( !_owner.isCustomizing ) {
            [_owner beginCustomizing];
        }
    }
    [_owner doDrag:sender];
}

/**
 * (PRIVATE) タップイベントのハンドラ
 */
- (void)onTap:(UITapGestureRecognizer*)sender{
    if( !_owner.isCustomizing ) {
        
        // for Debug
        //        CGPoint point = [sender locationInView:_containerView];
        //        MICUiGridCell* cell = [_layouter hitTestAt:point.x and:point.y];
        //        if( nil==cell) {
        //            NSLog(@"No cell at (%f, %f)", point.x, point.y);
        //        } else {
        //            cell.view.alpha = cell.view.alpha < 0.9 ? 1.0 : 0.5;
        //        }
        
        
        return;
    }
    [_owner endCustomizing];
}

/**
 * (PRIVATE) パン（ドラッグ）イベントのハンドラ
 */
- (void)onDrag:(UIPanGestureRecognizer*)sender{
//    NSLog(@"onDrag:sender.view=%@", sender.view.description);
    [_owner doDrag:sender];
}

- (void) setGesture:(bool)enable gesture:(UIGestureRecognizer*)gesture onView:(UIView*)view {
    if(nil!=gesture && nil!=view) {
        if(enable) {
            [view addGestureRecognizer:gesture];
        } else {
            [view removeGestureRecognizer:gesture];
        }
    }
}

- (void)setTapGesture:(bool)enable onView:(UIView*)view {
    [self setGesture:enable gesture:_tapGesture onView:view];
}

- (void)setLongPressGesture:(bool)enable onView:(UIView*)view {
    [self setGesture:enable gesture:_longpressGesture onView:view];
}

- (void)setPanGesture:(bool)enable onView:(UIView*)view {
    if(enable && nil==_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
    }
    [self setGesture:enable gesture:_panGesture onView:view];
}

@end


