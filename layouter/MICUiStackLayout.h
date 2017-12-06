//
//  MICStackLayout.h
//
//  ビューを縦または横方向に並べて配置するスタック型レイアウタークラス
//  （WindowsのStackPanel / AndroidのLinearLayoutのイメージ）
//
//  Created by 豊田 光樹 on 2014/10/23.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MICUiBaseLayout.h"

//--------------------------------------------------------------------------------------
#pragma mark - スタックレイアウター用デリゲート
/**
 * セルサイズ取得用コールバックデリゲート
 */
@protocol MICUiStackLayoutGetCellSizeDelegate <NSObject>
/**
 * ビューのサイズを取得
 * AccordionCellViewのように、子ビュー側の要求で、セルサイズが動的に変化するような場合に、セルサイズを問い合わせるために呼び出される。
 */
- (CGSize) getCellSizeForLayout:(UIView*)view;
@end

//--------------------------------------------------------------------------------------
#pragma mark - スタックレイアウター
/**
 * スタックレウアウタークラスの宣言
 */
@interface MICUiStackLayout : MICUiBaseLayout {
    
}

@property (nonatomic) CGFloat cellSpacing;                  ///< アイテム間の間隔
@property (nonatomic) MICUiOrientation orientation;         ///< セルの配置方向
@property (nonatomic,weak) id<MICUiStackLayoutGetCellSizeDelegate> getCellSizeDelegate;

/**
 * セルのアラインメント
 *
 * MICUiAlignExFILL を指定すると、セルビューのサイズが自動的に変更される。
 * 後から、cellAlignmentの値を変更することは可能だが、一度変更されたセルビューサイズは元に戻らないので注意。
 */
@property (nonatomic) MICUiAlignEx cellAlignment;

/**
 * レイアウターの固定長方向サイズ
 *
 * 固定長方向（伸長方向と直角方向）のサイズを指定する場合は、ここに正値を入れる。（マージンを含まない正味の値を指定）
 * 設定しない（もしくは、負値を入れる）と、最大サイズのセルに合わせてレンダリングされる。
 */
@property (nonatomic) CGFloat fixedSideSize;

/**
 *　正値を設定すると、伸長方向のサイズがこのサイズになるよう均等にセルがリサイズされる
 */
@property (nonatomic) CGFloat fitGrowingSideSize;

#if 0 // MICUiLayoutProtocolで宣言されているので不要
/**
 *　親ビュー（nil可）
 *
 *　レイアウターの子ビュー管理は、本来、親ビューの子ビュー管理とは独立しており、親ビューに子ビューを追加したからといって、
 *  必ずしも、レイアウターに登録する必要はない。しかし、実装の簡便性の観点から、子ビューを親ビューとレイアウターに同時に追加したいケースもあり得るので、
 *  その場合は、予め、このプロパティに親ビューを登録しておく。
 *
 *  （このプロパティが、nilなら、add/insert/removeChildのときに、親ビューとの接続関係を変更しないので、別途親ビューへの登録・削除が必要。）
 */
@property (nonatomic,weak) UIView* parentView;              ///< 親ビュー（nil可：nilなら、add/insert/removeChildのときに、親ビューとの接続関係を変更しない）
#endif

//--------------------------------------------------------------------------------------------
#pragma mark - 初期化

/**
 * レイアウターの初期化
 */
- (id) init;

/**
 * 方向とアラインメントを与えて初期化
 */
- (id) initWithOrientation:(MICUiOrientation)orientation alignment:(MICUiAlignEx) align;

- (void) addSpacer:(CGFloat)size;

@end
