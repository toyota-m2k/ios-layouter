//
//  MICUiDsSvgIconButton.h
//
//  Created by @toyota-m2k on 2019/03/15.
//  Copyright  2019年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICUiDsCustomButton.h"
#import "MICPathRepository.h"

/**
 * SVG Path をアイコンとして使えるカスタムボタンクラス
 * SVG Path は、オブジェクト作成後、colorResourcesプロパティにセットする。
 *
 * @properties
 *  iconSize            : アイコンの描画サイズ
 *  viewboxSize         : SVGパスのviewboxサイズ（デフォルト：24x24）
 *
 * 以下、MICUiDsCustomButtonから継承
 *  text                : テキスト。nilならアイコンのみ。
 *  borderWidth         : ボーダーの幅 (デフォルト：0)
 *  roundRadius         : ボーダーの cornerRadius （デフォルト：0）
 *  fontSize            : フォントサイズ（デフォルト：12.0）
 *  contentMargin       : ボタン矩形の内側のマージン。xamlでいうところのpadding。（デフォルト：2,2,2,2）
 *  iconTextMargin      : アイコンとテキストのマージン  （デフォルト：2)
 *  textHorzAlignment   : テキストの横方向アラインメント　（デフォルト： MICUiAlignCENTER）
 *
 *  colorResources      :
 *      MICUiStatefulSvgPathNORMAL/ACTIVATED/SELECTED/DISABLED
 *          各ステータスごとにパスを指定（viewbox sizeは揃える必要がある）
 *          MICUiStatefulSvgPathNORMALは必須。それ以外は、指定されていなければ、MICUiStatefulSvgPathNORMALを使用する。
 *      MICUiStatefulSvgColorNORMAL/ACTIVATED/SELECTED/DISABLED
 *          各ステータスごとにパスの塗りつぶし色を指定（strokeはサポートしていない）
 *          ステータスごとの色が設定されていなければ、MICUiStatefulSvgColorNORMALの値を使用し、
 *          MICUiStatefulSvgColorNORMALも指定されていなければ、MICUiStatefulFgColorNORMAL（テキスト色の設定）を使用する。
 *  iconResources       : 使用しない（設定しても無視）
 */

@interface MICUiDsSvgIconButton : MICUiDsCustomButton

@property (nonatomic,readwrite) CGSize iconSize;
@property (nonatomic,readwrite) CGSize viewboxSize;
@property (nonatomic,readwrite) bool stretchIcon;       // true: frame.height に合わせてアイコンを拡大する
                                                        // false: iconSize に従って描画（デフォルト）

/**
 * @param iconSize  描画サイズ
 * @param viewboxSize   SVGパスのviewboxサイズ
 * @param repo  SVG Path Repository
 *              nilを渡すと、このボタンインスタンス専用のリポジトリを作成して使用
 *              有効なリポジトリを渡すと、それを使用するが、作成したパスをReleaseしない。
 */
- (instancetype) initWithFrame:(CGRect) frame
                      iconSize:(CGSize)iconSize
               pathViewboxSize:(CGSize)viewboxSize
               pathRepositiory:(MICPathRepository*) repo ;

@end

