//
//  MICUiDragView.h
//
//  Viewのドラッグ＆ドロップ中のイベントをハンドリングするオーバレイビュー
//
//  Created by 豊田 光樹 on 2014/10/24.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICUiDragView : UIView
@property (nonatomic) CGPoint touchBeginningPos;
@property (nonatomic) bool firstTouch;
@end
