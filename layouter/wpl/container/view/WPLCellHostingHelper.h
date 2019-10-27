//
//  WPLCellHostingHelper.h
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"
#import "WPLBinder.h"

@interface WPLCellHostingHelper : NSObject <IWPLContainerCellDelegate>

/**
 * ルートコンテナ
 */
@property (nonatomic) id<IWPLContainerCell> containerCell;

@property (nonatomic,readonly) WPLBinder* binder;

/**
 * コンストラクタ
 */
- (instancetype) initWithView:(UIView*) view;
- (instancetype) initWithView:(UIView*) view container:(id<IWPLContainerCell>)container;

/**
 * View と　HostingHelperを接続（サイズ変更の監視を開始）
 */
- (void) attach;

/**
 * View と　HostingHelperを接続（サイズ変更の監視を終了）
 */
- (void) detach;

/**
 * 後始末
 */
- (void) dispose;

/**
 * コンテナ内の再配置処理
 *  通常は内部セルの変更や、コンテナのサイズ変更を検出して自動的に呼び出されるが、addCellを実行したとき、
 *  配置の更新が実行される前に、子セルが一瞬見えてしまってブサイクなことがあるので、その場合は、addCell後に、明示的にこのメソッドを呼ぶことで回避できる（かも）。
 */
- (void) renderCell;

@end

