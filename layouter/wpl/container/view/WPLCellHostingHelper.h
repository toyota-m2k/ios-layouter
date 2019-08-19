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

@end

