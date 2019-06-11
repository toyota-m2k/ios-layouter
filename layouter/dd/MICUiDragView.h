//
//  MICUiDragView.h
//
//  Viewのドラッグ＆ドロップ中のイベントをハンドリングするオーバレイビュー
//
//  Created by @toyota-m2k on 2014/10/24.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICUiDragView : UIView
@property (nonatomic) CGPoint touchBeginningPos;
@property (nonatomic) bool firstTouch;
@end
