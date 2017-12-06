//
//  MICUiDragView.m
//
//  Viewのドラッグ＆ドロップ中のイベントをハンドリングするオーバレイビュー
//
//  Created by 豊田 光樹 on 2014/10/24.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "MICUiDragView.h"

@interface MICUiDragView () {
}
@end

@implementation MICUiDragView

- (MICUiDragView*) init {
    return [self initWithFrame:CGRectZero];
}

- (MICUiDragView*) initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if( nil!=self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _touchBeginningPos = CGPointZero;
        _firstTouch = false;
    }
    return self;
}

- (MICUiDragView*) initOnParentView:(UIView*)parent {
    self = [self initWithFrame:parent.frame];
    if( nil!=self) {
        [parent addSubview:self];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"DDView: touchesBegin.");
    _firstTouch = true;
    UITouch* touch = [touches anyObject];
    _touchBeginningPos = [touch locationInView:self];
}


@end
