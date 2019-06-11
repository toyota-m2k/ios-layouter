//
//  MICUiDsCustomButton.m
//
//  オーナードローなボタンビューの基底クラス
//
//  Created by @toyota-m2k on 2014/12/15.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#import "MICUiDsCustomButton.h"
#import "MICUiLayout.h"
#import "MICCGContext.h"
#import "MICUiRectUtil.h"
#import "MICUiDsDefaults.h"

@implementation MICUiDsCustomButton

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self){
        _enabled = true;
        _inert = false;

        _borderWidth = MIC_BTN_BORDER_WIDTH;
        _roundRadius = MIC_BTN_ROUND_RADIUS;
        _fontSize = MIC_BTN_FONT_SIZE;
        _contentMargin = MIC_BTN_CONTENT_MARGIN;
        _iconTextMargin = MIC_BTN_ICON_TEXT_MARGIN;
        _textHorzAlignment = MICUiAlignCENTER;
        
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void) setTarget:(id)target action:(SEL)action {
    _targetSelector = [[MICTargetSelector alloc] initWithTarget:target selector:action];
}


#pragma mark - Button State

/**
 * (private) ボタンの状態に合わせて（必要なら）表示を更新
 */
- (void)updateButtonState {
    MICUiViewState state = MICUiViewStateNORMAL;
    if(!_enabled) {
        state = MICUiViewStateDISABLED;
    } else if (_activated) {
        state = MICUiViewStateACTIVATED;
    } else if (_selected) {
        state = MICUiViewStateSELECTED;
    }
    if(_buttonState != state) {
        MICUiViewState oldState = _buttonState;
        _buttonState = state;
        [self setNeedsDisplay];
        if(nil!=_customButtonDelegate) {
            [_customButtonDelegate onCustomButtonStateChangedAt:self from:oldState to:state];
        }
    }
}

/**
 * enabledプロパティ
 */
- (void) setEnabled:(bool)enabled {
    if(_enabled != enabled) {
        _enabled = enabled;
        [self updateButtonState];
    }
}

/**
 * activatedプロパティ
 */
- (void) setActivated:(bool)activated {
    if(_activated != activated) {
        _activated = activated;
        [self updateButtonState];
    }
}

/**
 * selectedプロパティ
 */
- (void) setSelected:(bool)selected {
    if(_selected != selected) {
        _selected = selected;
        [self updateButtonState];
    }
}

#pragma mark - Contents

/**
 * ボタンのラベルを設定
 */
- (void)setText:(NSString *)text {
    if(![_text isEqualToString:text]) {
        _text = text;
        [self setNeedsDisplay];
    }
}

/**
 * ボタンの色情報を設定
 */
- (void)setColorResources:(id<MICUiStatefulResourceProtocol>)resources {
    _colorResources = resources;
    [self setNeedsDisplay];
}

/**
 * ボタンのアイコンを設定
 */
- (void)setIconResources:(id<MICUiStatefulResourceProtocol>)resources {
    _iconResources = resources;
    [self setNeedsDisplay];
}

#pragma mark - タッチ操作

/**
 * タッチ開始
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_enabled || _inert) {
        return;
    }
    UITouch* touch = [touches anyObject];
    if(touch.view == self) {
        self.activated = true;
    }
    
}

/**
 * タッチ操作のキャンセル
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.activated = false;
}

/**
 * タッチ操作終了
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.activated = false;
    
    if(_enabled && !_inert) {
        UITouch* touch = [touches anyObject];
        if(touch.view == self) {
            if(nil!=_customButtonDelegate) {
                [_customButtonDelegate onCustomButtonTapped:self];
            }
            if(nil!=_targetSelector) {
                id me = self;
                [_targetSelector performWithParam:&me];
            }
//            self.selected = !self.selected;
        }
    }
}

#pragma mark - MICUiDraggableCellProtocol

/**
 * カスタマイズモードが開始された
 */
- (void)onBeginCustomizing:(id<MICUiDraggableLayoutProtocol>)layout {
}


/**
 * カスタマイズモードが終了した
 */
- (void)onEndCustomizing:(id<MICUiDraggableLayoutProtocol>)layout {
    _inert = false;     // 安全のため
}

/**
 * ボタンのドラッグが開始された
 */
- (BOOL)onBeginDragging:(id<MICUiDraggableLayoutProtocol>)layout {
    _inert = true;
    self.activated = false;
    return true;
}

/**
 * ボタンのドラッグが終わった
 */
- (void)onEndDragging:(id<MICUiDraggableLayoutProtocol>)layout done:(BOOL)done {
    _inert = false;
}

#pragma mark - 描画

/**
 * 背景を描画する
 *  背景の描画方法を変更する場合は、サブクラスでオーバーライド
 *  デフォルトでは、
 *  - 画像を使用
 *  - 背景色、ボーダー色を指定した矩形または、角丸矩形で描画
 *  の２種類をサポート
 */
- (void)eraseBackground:(CGContextRef)rctx rect:(CGRect)rect {
    MICCGContext ctx(rctx, false);
    UIImage* bgImage = [_colorResources resourceOf:MICUiResTypeBGIMAGE forState:_buttonState];
    
    if(nil!=bgImage) {
        [bgImage drawInRect:rect];
    }
    else {
        UIColor* colorBg = [_colorResources resourceOf:MICUiResTypeBGCOLOR forState:_buttonState fallbackState:MICUiViewStateNORMAL];
        UIColor* colorBorder = [_colorResources resourceOf:MICUiResTypeBORDERCOLOR forState:_buttonState fallbackState:MICUiViewStateNORMAL];
        if (_roundRadius>0) {
            UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_roundRadius];
            if(nil!=colorBg) {
                ctx.setFillColor(colorBg);
                [path fill];
            }
            if(nil!=colorBorder && _borderWidth>0) {
                ctx.setStrokeColor(colorBorder);
                [path stroke];
            }
        } else {
            if(nil!=colorBg) {
                ctx.setFillColor(colorBg);
                ctx.fillRect(rect);
            }
            if(nil!=colorBorder && _borderWidth>0) {
                ctx.setStrokeColor(colorBorder);
                ctx.strokeRect(rect, _borderWidth);
            }
        }
    }
}

/**
 * 描画領域を取得する。
 * テキスト、または、アイコンの描画位置を変更する場合は、サブクラスでオーバーライドする。デフォルトの実装は、
 * - 左端にアイコン、その右にiconTextMarginをあけてテキストを表示する。
 * - アイコンだけ、または、テキストだけのときは、それぞれセンタリングする。
 */
- (void)getContentRect:(UIImage*)icon iconRect:(CGRect*)prcIcon textRect:(CGRect*)prcText {
    MICRect rcBounds = self.bounds;
    MICRect rcContent = rcBounds;
    rcContent.deflate(_contentMargin);
    
    *prcText = CGRectNull;
    *prcIcon = CGRectNull;
    if(nil!=icon) {
        MICRect rcIcon(rcContent.origin, icon.size);
        if(rcIcon.height()>rcBounds.height()) {
            // アイコンが大きい→要縮小
            CGFloat r = rcContent.height() / rcIcon.height();
            rcIcon.setY(rcBounds.y());
            rcIcon.size.width *= r;
            rcIcon.size.height *= r;
        } else {
            // アイコンが小さい→縦方向センタリング
            rcIcon.moveToVCenterOfOuterRect(rcContent);
        }
        if(nil==_text) {
            // only icon --> アイコンを横方向にセンタリング
            rcIcon.moveToHCenterOfOuterRect(rcContent);
        } else {
            // text & icon
            MICRect rcText = rcContent;
            rcText.setLeft( rcIcon.right()+_iconTextMargin);
            *prcText = rcText;
        }
        *prcIcon = rcIcon;
    } else {
        if( nil!=_text) {
            // only text
            *prcText = rcContent;
        }
    }
}

/**
 * ラベル描画用フォントを取得する
 *  デフォルトの実装では、boldSystemFont を使用。これを変更する場合はサブクラスでオーバーライドする。
 */
- (UIFont*)getFont {
    return [UIFont boldSystemFontOfSize:self.fontSize];
}

- (NSDictionary*) getTextAttributes:(NSTextAlignment)halign {
    UIColor* colorFg = [_colorResources resourceOf:MICUiResTypeFGCOLOR forState:_buttonState fallbackState:MICUiViewStateNORMAL];
    if(nil==colorFg) {
        return nil;
    }
    UIFont* font = [self getFont];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = halign;
    NSDictionary *attr = @{
                           NSForegroundColorAttributeName: colorFg,
                           NSFontAttributeName: font,
                           NSParagraphStyleAttributeName: style
                           };
    return attr;
}

/**
 * テキストを描画する。
 *  通常はオーバーライド不要。drawContentをオーバーライドする場合に、テキスト出力のユーティリティとして利用する。
 */
- (void)drawText:(CGContextRef)rctx rect:(CGRect)rect halign:(NSTextAlignment)halign valign:(MICUiAlign)valign {
    if(nil==self.text) {
        return;
    }
    
    NSDictionary *attr = [self getTextAttributes:halign];
    CGSize size = [self.text sizeWithAttributes:attr];
    MICRect rcText = rect;
    switch(valign) {
        case MICUiAlignBOTTOM:
            rcText = rcText.partialBottomRect(size.height);
            break;
        case MICUiAlignCENTER:
            rcText.size.height = size.height;
            rcText.moveToVCenterOfOuterRect(rect);
            break;
        case MICUiAlignTOP:
        default:
            break;
            
    }
    
    [self.text drawInRect:rcText withAttributes:attr];
    
}

/**
 * 状態依存のアイコンを取得
 *   iconResourcesが指定されていれば、それから取得、指定されていなければ、colorResourcesから取得する。
 */
- (UIImage*) getIconForState:(MICUiViewState)state {
    if(nil!=_iconResources) {
        return [_iconResources resourceOf:MICUiResTypeICON forState:state fallbackState:MICUiViewStateNORMAL];
    } else {
        return [_colorResources resourceOf:MICUiResTypeICON forState:state fallbackState:MICUiViewStateNORMAL];
    }
}

/**
 * アイコンを描画する
 */
- (void) drawIcon:(CGContextRef)rctx icon:(UIImage*)icon rect:(CGRect)rect {
    if(nil!=icon) {
        [icon drawInRect:rect];
    }
}

/**
 * ボタンのコンテント（アイコンとテキスト）を描画する。
 * - 背景（塗りとボーダー）の描画方法を変更する場合はeraseBackgroundをオーバーライド
 * - アイコンとテキストの位置を変える→　getContentRect をオーバーライド
 * - テキストのフォントを変える→　getFontをオーバーライド
 * これ以外（例えば、アイコンを２つ使うとか、テキストを二段にするとか）のカスタマイズを行う場合には、このメソッドをオーバーライドする。
 */
- (void)drawContent:(CGContextRef)rctx rect:(CGRect)rect {
    MICCGContext ctx(rctx, false);
    
    // アイコン/テキストの描画１を取得
    UIImage* icon = [self getIconForState:_buttonState];
    MICRect rcIcon, rcText;
    [self getContentRect:icon iconRect:&rcIcon textRect:&rcText];
   
    NSTextAlignment halign;
    switch(_textHorzAlignment) {
        case MICUiAlignRIGHT:
            halign = NSTextAlignmentRight;
            break;
        case MICUiAlignLEFT:
            halign = NSTextAlignmentLeft;
            break;
        case MICUiAlignCENTER:
            halign = NSTextAlignmentCenter;
            break;
    }

    // アイコンを描画
    [self drawIcon:rctx icon:icon rect:rcIcon];
    
    // テキストを描画
    [self drawText:rctx rect:rcText halign:halign valign:MICUiAlignCENTER];
    
}

/**
 * ボタンの描画
 *  通常、このメソッドはオーバーライドせず、描画をカスタマイズする場合は、eraseBackground, getContentRect, getFontをオーバーライドする。
 *  背景と前景の描画を区別できないようなケース（どんなケースかは思いつかない）にのみ、このメソッドをオーバーライドする。
 */
- (void)drawRect:(CGRect)rect {
    MICCGContext ctx;
    if(_turnOver) {
        ctx.rotate(MIC_RADIAN(180), MICRect(self.bounds).center());
    }
    [self eraseBackground:ctx rect:rect];
    [self drawContent:ctx rect:rect];
}

/**
 * コンテントを表示するための最小ボタンサイズを計算する。
 * @param  height   タブの高さ（0なら、高さも計算する）
 * @return ボタンサイズ（contentMarginを含む）
 */
- (CGSize) calcPlausibleButtonSizeFotHeight:(CGFloat)height forState:(MICUiViewState)state {
    UIImage* icon = [self getIconForState:state];

    MICEdgeInsets margin(_contentMargin);
    CGFloat contentHeight = (height>0) ? height-margin.dh() : 0;
    CGFloat spacing = 0;
    MICSize iconSize, textSize;
    NSTextAlignment halign = NSTextAlignmentCenter;
    if(nil!=icon) {
        iconSize = icon.size;
        if(contentHeight>0) {
            if(icon.size.height>contentHeight) {
                // 要縮小
                CGFloat r = contentHeight / icon.size.height;
                iconSize.width *= r;
            }
            iconSize.height = contentHeight;
        }
        if(nil!=_text) {
            spacing = _iconTextMargin;
            halign = NSTextAlignmentLeft;
        }
    }
    
    if(nil!=_text) {
        NSDictionary *attr = [self getTextAttributes:halign];
        textSize = [self.text sizeWithAttributes:attr];
    }
    return MICSize(iconSize.width + spacing + textSize.width + margin.dw(), MAX(iconSize.height, textSize.height+margin.dh()));
}

//- (void)layoutSubviews {
//    [self setNeedsDisplay];
//}

/**
 * リサイズ時に再描画する
 * これをやらないと、アイコンや文字が拡大／縮小されて表示される。
 * layoutSubviewsのタイミングでやっても同じ結果になるようだが、こちらのほうが回数が少ないみたい。
 */
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}
@end
