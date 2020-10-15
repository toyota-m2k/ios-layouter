//
//  MICUiDsSvgIconButton.m
//
//  Created by @toyota-m2k on 2019/03/15.
//  Copyright  2019年 @toyota-m2k. All rights reserved.
//

#import "MICUiDsSvgIconButton.h"
#import "MICSvgPath.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICPathRepository.h"

@implementation MICUiDsSvgIconButton {
    MICPathRepository* _pathRepo;
    MICPathRepository* _localPathRepo;
}

- (MICPathRepository*) pathRepository {
    return _pathRepo;
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame iconSize:MICSize(24,24) pathViewboxSize:MICSize(24,24) pathRepositiory:nil];
}

- (instancetype) initWithFrame:(CGRect) frame iconSize:(CGSize)iconSize pathViewboxSize:(CGSize)viewboxSize pathRepositiory:(MICPathRepository*) repo {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        self.backgroundColor = UIColor.clearColor;
        _viewboxSize = viewboxSize;
        _iconSize = iconSize;
        _stretchIcon = false;
        _localPathRepo = nil;
        if(nil==repo) {
            _localPathRepo = [MICPathRepository localInstance];
            repo = _localPathRepo;
        }
        _pathRepo = repo;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(nil==newSuperview) {
        [self dispose];
    }
}

- (void) dispose {
    if(_localPathRepo!=nil) {
        [_localPathRepo dispose];
    }
}

- (void) dealloc {
    [self dispose];
}

- (MICSvgPath*) getSvgPathForState:(MICUiViewState)state {
    NSString* path = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_PATH];
    if(path==nil) {
        return nil;
    }
    return [_pathRepo getPath:path viewboxSize:_viewboxSize];
}

//- (UIColor*) getIconColorForState:(MICUiViewState)state {
//    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_COLOR];
//    if(nil==color) {
//        color = [self resource:self.colorResources onStateForType:MICUiResTypeFGCOLOR];
//    }
//    return color;
//}

- (UIColor*) getFgColor:(MICUiViewState) state {
    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeFGCOLOR];
    return color;
}
- (UIColor*) currentFgColor {
    return [self getFgColor:self.buttonState];
}

- (UIColor*) getSvgColor:(MICUiViewState)state {
    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_COLOR];
    return color;
}

- (UIColor*) getSvgStrokeColor:(MICUiViewState)state {
    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_STROKE_COLOR];
    return color;
}

- (CGFloat) getSvgStrokeWidth:(MICUiViewState)state {
    id v = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_STROKE_WIDTH];
    return v==nil ? 0 : [v floatValue];
}


- (MICSvgPath*) currentSvgPath {
    return [self getSvgPathForState:self.buttonState];
}

- (UIColor*) currentSvgColor {
    return [self getSvgColor:self.buttonState];
}

- (UIColor*) currentSvgStrokeColor {
    return [self getSvgStrokeColor:self.buttonState];
}

- (CGFloat) currentSvgStrokeWidth {
    return [self getSvgStrokeWidth:self.buttonState];
}
//- (UIColor*) currentIconColor {
//    return [self getIconColorForState:self.buttonState];
//}

//- (CGRect) calcIconRect {
//    MICRect rcContent(self.bounds);
//    MICSize iconSize(_iconSize);
//    if(_stretchIcon) {
//        CGFloat h = MAX(rcContent.height(), 0);
//        h = MAX(h-MICEdgeInsets(self.contentMargin).dh(), 0);
//        iconSize = MICSize(h);
//    }
//    MICRect rc(iconSize);
//    MICPoint center(rcContent.left()+self.contentMargin.left+iconSize.width/2, rcContent.center().y);
//    rc.moveCenter(center);
//    return rc;
//}

//- (CGSize) calcPlausibleButtonSizeFotHeight:(CGFloat)height forState:(MICUiViewState)state {
//    MICEdgeInsets margin(self.contentMargin);
//    CGFloat spacing = 0;
//    MICSize textSize;
//    NSTextAlignment halign = NSTextAlignmentCenter;
//    
//    if(nil!=self.text) {
//        spacing = self.iconTextMargin;
//        halign = NSTextAlignmentLeft;
//    }
//    
//    if(nil!=self.text) {
//        NSDictionary *attr = [self getTextAttributes:halign];
//        textSize = [self.text sizeWithAttributes:attr];
//    }
//    return MICSize(_iconSize.width + spacing + textSize.width + margin.dw(), MAX(_iconSize.height, textSize.height+margin.dh()));
//}
//
//- (void)sizeToFit {
//    self.frame = MICRect(self.frame.origin, [self calcPlausibleButtonSizeFotHeight:0 forState:MICUiViewStateNORMAL]);
//}

/**
 * icon（UIImage)の代わりに、SvgPathを扱うように、getContentRect をオーバーライド
 * 親クラスのgetContentRectとの違い：
 *  - icon引数は無視（nilが渡ってくる）
 *  - アイコンなし（テキストのみ）のパターンは存在しない前提（SvgIconButtonを使う意味がないので）
 *  - コンストラクタで指定されたアイコンサイズよりビューが大きい時、拡大描画可能(stretchIconプロパティがtrueの場合のみ）
 */
- (void)getContentRect:(UIImage*)icon iconRect:(CGRect*)prcIcon textRect:(CGRect*)prcText {
    MICRect rcBounds = self.bounds;
    MICRect rcContent = rcBounds;
    rcContent.deflate(self.contentMargin);
    
    *prcText = CGRectNull;
    *prcIcon = CGRectNull;

    MICRect rcIcon(rcContent.origin, self.iconSize);
    if(rcIcon.height()>rcBounds.height()) {
        // アイコンが大きい→要縮小
        CGFloat r = rcContent.height() / rcIcon.height();
        rcIcon.size.width *= r;
        rcIcon.size.height = rcContent.height();
    } else {
        // アイコンが小さい
        if(_stretchIcon) {
            // アイコンを拡大
            CGFloat r = rcContent.height() / rcIcon.height();
            rcIcon.size.width *= r;
            rcIcon.size.height = rcContent.height();
        } else {
            // 拡大しない場合は縦方向センタリング
            rcIcon.moveToVCenterOfOuterRect(rcContent);
        }
    }
    if(nil==self.text) {
        // only icon --> アイコンを横方向にセンタリング
        rcIcon.moveToHCenterOfOuterRect(rcContent);
    } else {
        // text & icon
        MICRect rcText = rcContent;
        rcText.setLeft( rcIcon.right()+self.iconTextMargin);
        *prcText = rcText;
    }
    *prcIcon = rcIcon;
}

- (void)drawIcon:(CGContextRef)rctx icon:(UIImage *)icon rect:(CGRect)rect {
    let svgBgPath = self.currentSvgBgPath;
    if(nil!=svgBgPath) {
        let fillColor = self.currentSvgBgColor;
        let strokeColor = self.currentSvgBgStrokeColor;
        let strokeWidth = self.currentSvgBgStrokeWidth;
        [svgBgPath draw:rctx dstRect:[self getIconBgRect:rect] fillColor:fillColor stroke:strokeColor strokeWidth:strokeWidth];
    }
    let svgPath = self.currentSvgPath;
    if(nil!=svgPath) {
        var fillColor = self.currentSvgColor;
        if(fillColor==nil) {
            fillColor = self.currentFgColor;
        }
        let strokeColor = self.currentSvgStrokeColor;
        let strokeWidth = self.currentSvgStrokeWidth;
        [svgPath draw:rctx dstRect:[self getIconFgRect:rect] fillColor:fillColor stroke:strokeColor strokeWidth:strokeWidth];
    }
}

/**
 * 現時点で、MICUiDsSvgIconButton で、状態によってアイコンが変化する、というような使い方は考慮していない。
 */
- (CGSize) iconSizeForState:(MICUiViewState)state {
    return self.iconSize;
}

#pragma - mark Background SVG ... SVGの重ね合わせ対応

- (CGRect) getIconFgRect:(CGRect) iconRect {
    return iconRect;
}

- (CGRect) getIconBgRect:(CGRect) iconRect {
    let r = 1.0/24.0;
    return iconRect - MICEdgeInsets(r*iconRect.size.width, r*iconRect.size.height);
}

- (MICSvgPath*) getSvgBgPathForState:(MICUiViewState)state {
    NSString* path = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_BGPATH];
    if(path==nil) {
        return nil;
    }
    return [_pathRepo getPath:path viewboxSize:_viewboxSize];
}

- (UIColor*) getSvgBgColorForState:(MICUiViewState)state {
    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_BGCOLOR];
    return color;
}

- (UIColor*) getSvgBgStrokeColor:(MICUiViewState)state {
    UIColor* color = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_STROKE_BGCOLOR];
    return color;
}

- (CGFloat) getSvgBgStrokeWidth:(MICUiViewState)state {
    id v = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_STROKE_BG_WIDTH];
    return v==nil ? 0 : [v floatValue];
}

- (MICSvgPath*) currentSvgBgPath {
    return [self getSvgBgPathForState:self.buttonState];
}

- (UIColor*) currentSvgBgColor {
    return [self getSvgBgColorForState:self.buttonState];
}

- (UIColor*) currentSvgBgStrokeColor {
    return [self getSvgBgStrokeColor:self.buttonState];
}
- (CGFloat) currentSvgBgStrokeWidth {
    return [self getSvgBgStrokeWidth:self.buttonState];
}

@end
