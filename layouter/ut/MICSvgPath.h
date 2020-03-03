//
//  MICSvgPath.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/03/11.
//  Copyright  2019年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * SVG パス文字列の解析＋解析結果の保持を行うクラス
 *
 * <svg>タグの d 属性（xamlでいうと<Path>タグの data属性、Androidのdrawableでいうと、vector内のpath タグのpathData属性）から　CGPathを生成して保持する。
 *
 * CGContextに描画するなら、stroke/fill/draw（fill+stroke)を利用する。
 * CGPathを取り出して利用するなら、CGPathプロパティを使う（CGPathの生存期間は、MICSvgPathオブジェクトと一致：CGPathReleaseは不要）か、
 * detachCGPathメソッドで取り出して（この場合、CGPathReleaseの呼び出しが必要）使用する。
 */
@interface MICSvgPath : NSObject

/**
 * このオブジェクトが保持しているCGPathを参照する
 * 管理主体はMICSvgPathに残るので、勝手にCGPathRelease()してはいけない。
 */
@property (nonatomic,readonly) CGPathRef cgpath;

/**
 * このオブジェクトが保持しているCGPathをオブジェクトから切り離して取得する。
 * 管理主体は呼び出し元に移るので、不要になれば、CGPathRelease()すること。
 * このメソッド呼び出し移行、このオブジェクトに対する描画命令などは無効となる。
 */
- (CGPathRef) detachCGPath;

/**
 * パスの構築に使用したパス命令文字列　（SVGの d 属性）
 */
@property (nonatomic,readonly) NSString* pathString;

/**
 * パス文字列とviewboxサイズから、MICSvgPathオブジェクトを生成する。
 */
+ (instancetype) pathWithViewboxSize:(CGSize)size pathString:(NSString*)pathString;

/**
 * 色を指定して、CGContext上の dstRectに描画する。
 */
- (void) draw:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor stroke:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth;

/**
 * 色を指定して、CGContext上の dstRectに描画する。
 * （反転対応版）
 */
- (void) draw:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor stroke:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth mirrorX:(bool)mirrorX mirrorY:(bool)mirrorY;

/**
 * 色を指定して、CGContext上の dstRectに塗る。
 */
- (void) fill:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor;

/**
 * 色を指定して、CGContext上の dstRectに線を描く。
 */
- (void) stroke:(CGContextRef) rctx dstRect:(CGRect) dstRect strokeColor:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth;


+ (NSArray*) parseParams:(NSString*) paramString;

@end
