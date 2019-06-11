//
//  MICUiRelativeLayout.h
//
//  親ビューまたは、兄弟ビューとの相対位置によってビューの配置を決定するレイアウタークラス
//  (AndroidのRelativeLayout風）
//
//  Created by @toyota-m2k on 2014/11/26.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiBaseLayout.h"

//------------------------------------------------------------------------------------------
#pragma mark - 定数

/**
 * Viewの各辺をどこにアタッチするか（位置決めの基準点を指定）
 */
typedef enum _micUiRelativeLayoutAttach {
    MICUiRelativeLayoutAttachFREE,          ///< 自由端（自動的に調整される）
    MICUiRelativeLayoutAttachPARENT,        ///< 親（RelativeLayout）に対する相対位置で指定
    MICUiRelativeLayoutAttachADJACENT,      ///< 兄弟Viewの向かい合う辺からの距離で指定
    MICUiRelativeLayoutAttachFITTO,         ///< 兄弟Viewの対応する辺からの距離で指定
    MICUiRelativeLayoutAttachCENTEROF,      ///< 親、または、兄弟Viewに対する中央揃え(向かい合う両辺に対して同時にセットすること）
} MICUiRelativeLayoutAttach;

/**
 * Viewの縦・横サイズを決定する方法
 */
typedef enum _micUiRelativeLayoutScaling {
    MICUiRelativeLayoutScalingFREE,         ///< 自由サイズ（自動的に調整される）
    MICUiRelativeLayoutScalingFIXED,        ///< 固定値
    MICUiRelativeLayoutScalingNOSIZE,       ///< Viewのサイズを変更しない
    MICUiRelativeLayoutScalingRELATIVE,     ///< 親または兄弟Viewに対する相対サイズ
} MICUiRelativeLayoutScaling;

/**
 * D&D操作による配置ルール（ddRuleプロパティ）用ビットフラグ
 */
#define MICUiRelativeLayoutDDRuleFREE       0   ///< どこにでも配置可能
#define MICUiRelativeLayoutDDRuleVACATE     1   ///<（できるだけ）子ビューが重ならないように配置
#define MICUiRelativeLayoutDDRuleINBOUNDS   2   ///<（できるだけ）layoutのコンテント領域からはみ出さないように配置


//------------------------------------------------------------------------------------------
#pragma mark - Attach情報

/**
 * Viewの各辺のアタッチ方法を指定するための情報クラス
 */
@interface MICUiRelativeLayoutAttachInfo : NSObject

@property (nonatomic,weak) UIView* attachTo;                ///< Attach先（nilなら親）
@property (nonatomic) MICUiRelativeLayoutAttach attach;     ///< Attach方法
@property (nonatomic) CGFloat value;                        ///< 距離（AttachFREE, CENTEROFの場合は無視）

/**
 * 自由端（反対側の辺の位置とサイズから自動的に決定される）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachFree;

/**
 * 親（RelativeLayout）にアタッチ
 *  @param distance 親の各辺からの距離（負値を与えると、親枠の外側になる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachParent:(CGFloat)distance;

/**
 * 兄弟の隣接する辺にアタッチ
 *  @param sibling  隣のView
 *  @param distance ２つのViewの隣り合う辺の距離（負値を与えるとViewが重なる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachAdjacent:(UIView*)sibling inDistance:(CGFloat)distance;

/**
 * 兄弟の対応する辺にアタッチ（右揃え、左揃えなど）
 *  @param sibling  基準とするView
 *  @param distance 基準Viewの基準辺からの距離（正値なら基準ビューの内側、負値なら基準ビューの外側になる）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachFitTo:(UIView*)sibling inDistance:(CGFloat)distance;

/**
 * 親(RelativeLayout)に対する中央揃え
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachCenter;

/**
 * 兄弟に対する中央揃え
 *  @param sibling  基準とするView（このビューに対する中央揃えで配置）
 */
+ (MICUiRelativeLayoutAttachInfo*) newAttachCenterOfView:(UIView*)sibling;



/**
 * 自由端（反対側の辺の位置とサイズから自動的に決定される）
 */
- (void) setAttachFree;

/**
 * 親（RelativeLayout）にアタッチ
 *  @param distance 親の各辺からの距離（負値を与えると、親枠の外側になる）
 */
- (void) setAttachParent:(CGFloat)distance;

/**
 * 兄弟の隣接する辺にアタッチ
 *  @param sibling  隣のView
 *  @param distance ２つのViewの隣り合う辺の距離（負値を与えるとViewが重なる）
 */
- (void) setAttachAdjacent:(UIView*)sibling inDistance:(CGFloat)distance;

/**
 * 兄弟の対応する辺にアタッチ（右揃え、左揃えなど）
 *  @param sibling  基準とするView
 *  @param distance 基準Viewの基準辺からの距離（正値なら基準ビューの内側、負値なら基準ビューの外側になる）
 */
- (void) setAttachFitTo:(UIView*)sibling inDistance:(CGFloat)distance;

/**
 * 親(RelativeLayout)に対する中央揃え
 */
- (void) setAttachCenter;

/**
 * 兄弟に対する中央揃え
 *  @param sibling  基準とするView（このビューに対する中央揃えで配置）
 */
- (void) setAttachCenterOfView:(UIView*)sibling;

@end


//------------------------------------------------------------------------------------------
#pragma mark - Scaling情報

/**
 * Viewの縦・横サイズを決定する方法を指定するための情報クラス
 */
@interface MICUiRelativeLayoutScalingInfo : NSObject

@property (nonatomic) UIView* referTo;                      ///< スケーリングの参照先
@property (nonatomic) MICUiRelativeLayoutScaling scaling;   ///< スケーリング方法
@property (nonatomic) CGFloat value;                        ///< 距離（AttachFREE, CENTEROFの場合は無視）

/**
 * 可変幅
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingFree;

/**
 * サイズ変更なし
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingNoSize;

/**
 * 固定サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingFixed:(CGFloat)size;

/**
 * 親（RelativeLayout）相対サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingRelative:(CGFloat)ratio;

/**
 * 兄弟View相対サイズ
 */
+ (MICUiRelativeLayoutScalingInfo*) newScalingRelativeToView:(UIView*)sibling inRatio:(CGFloat)ratio;

- (void) setScalingFree;
- (void) setScalingNoSize;
- (void) setScalingFixed:(CGFloat)size;
- (void) setScalingRelative:(CGFloat)ratio;
- (void) setScalingRelativeToView:(UIView*)sibling inRatio:(CGFloat)ratio;


@end

//------------------------------------------------------------------------------------------
#pragma mark - レイアウト情報

/**
 * 完全なレイアウト指定情報クラス
 */
@interface MICUiRelativeLayoutInfo : NSObject

@property (nonatomic) MICUiRelativeLayoutAttachInfo* top;
@property (nonatomic) MICUiRelativeLayoutAttachInfo* bottom;
@property (nonatomic) MICUiRelativeLayoutAttachInfo* left;
@property (nonatomic) MICUiRelativeLayoutAttachInfo* right;
@property (nonatomic) MICUiRelativeLayoutScalingInfo* horz;
@property (nonatomic) MICUiRelativeLayoutScalingInfo* vert;

+ (instancetype) layoutHorz:(MICUiRelativeLayoutScalingInfo*)horz
                       left:(MICUiRelativeLayoutAttachInfo*)left
                      right:(MICUiRelativeLayoutAttachInfo*)right
                       vert:(MICUiRelativeLayoutScalingInfo*)vert
                        top:(MICUiRelativeLayoutAttachInfo*)top
                     bottom:(MICUiRelativeLayoutAttachInfo*)bottom;

/**
 * 初期化（あとで、すべてのレイアウト情報をセットしてください。）
 */
- (instancetype) init;

/**
 * レイアウト情報を与えて初期化
 */
- (instancetype) initWithHorz:(MICUiRelativeLayoutScalingInfo*)horz
                         left:(MICUiRelativeLayoutAttachInfo*)left
                        right:(MICUiRelativeLayoutAttachInfo*)right
                         vert:(MICUiRelativeLayoutScalingInfo*)vert
                          top:(MICUiRelativeLayoutAttachInfo*)top
                       bottom:(MICUiRelativeLayoutAttachInfo*)bottom;

/**
 * 横方向のレイアウト情報を設定
 */
- (void) setHorzParam:(MICUiRelativeLayoutScalingInfo*)horz
                 left:(MICUiRelativeLayoutAttachInfo*)left
                right:(MICUiRelativeLayoutAttachInfo*)right;

/**
 * 縦方向のレイアウト情報を設定
 */
- (void) setVertParam:(MICUiRelativeLayoutScalingInfo*)vert
                  top:(MICUiRelativeLayoutAttachInfo*)top
               bottom:(MICUiRelativeLayoutAttachInfo*)bottom;

@end

//------------------------------------------------------------------------------------------
#pragma mark - 相対レイアウターセル情報クラス

/**
 * 相対レイアウト内のセル情報クラス
 */
@interface MICUiRelativeCell : MICUiLayoutCell

@property (nonatomic) MICUiRelativeLayoutInfo* layoutInfo;      ///< 配置情報

@end

//------------------------------------------------------------------------------------------
#pragma mark - 相対レイアウター

/**
 * 相対レイアウトクラス
 */
@interface MICUiRelativeLayout : MICUiBaseLayout {
    
}

/**
 * レイアウター全体のサイズ（マージンは含まない）
 * 他のレイアウター(Grid/Stack）と違って、まず全体のサイズを決めて、その内部にパーツを配置する。
 */
@property CGSize overallSize;

/**
 * DD操作でドロップを許可するグリッドの指定（ゼロならグリッド無効）
 */
@property unsigned int ddGridX;
@property unsigned int ddGridY;

/**
 * D&D操作による配置ルール
 *  MICUiRelativeLayoutDDRuleXXXXの組み合わせ
 */
@property int ddRule;

/**
 * 子ビューを追加
 */
- (void) addChild:(UIView *)view andInfo:(MICUiRelativeLayoutInfo*)info;

/**
 * 子ビューを挿入
 */
- (void) insertChild:(UIView *)view beforeSibling:(UIView*)sibling andInfo:(MICUiRelativeLayoutInfo*)info;

/**
 * 子ビューのレイアウト情報を取得
 */
- (MICUiRelativeLayoutInfo*) layoutInfoOfView:(UIView*)view;

@end
