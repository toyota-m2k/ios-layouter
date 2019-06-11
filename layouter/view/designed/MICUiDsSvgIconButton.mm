//
//  MICUiDsSvgIconButton.m
//  Anytime
//
//  Created by @toyota-m2k on 2019/03/15.
//  Copyright  2019年 @toyota-m2k Corporation. All rights reserved.
//

#import "MICUiDsSvgIconButton.h"
#import "MICSvgPath.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICPathRepository.h"

@implementation MICUiDsSvgIconButton {
    MICSvgPath* _svgPathNormal;
    MICSvgPath* _svgPathActivated;
    MICSvgPath* _svgPathSelected;
    MICSvgPath* _svgPathDisabled;
}

- (instancetype) initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame iconSize:MICSize(24,24) pathViewboxSize:MICSize(24,24)];
}

- (instancetype) initWithFrame:(CGRect) frame iconSize:(CGSize)iconSize pathViewboxSize:(CGSize)viewboxSize {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        self.backgroundColor = UIColor.clearColor;
        _viewboxSize = viewboxSize;
        _iconSize = iconSize;
        _svgPathNormal = nil;
        _svgPathActivated = nil;
        _svgPathSelected = nil;
        _svgPathDisabled = nil;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(nil==newSuperview) {
        [self dispose];
    }
}

- (void) dispose {
    [MICPathRepository.instance releasePath:_svgPathNormal];    _svgPathNormal = nil;
    [MICPathRepository.instance releasePath:_svgPathActivated]; _svgPathActivated = nil;
    [MICPathRepository.instance releasePath:_svgPathSelected];  _svgPathSelected = nil;
    [MICPathRepository.instance releasePath:_svgPathDisabled];  _svgPathDisabled = nil;
}

- (void) dealloc {
    [self dispose];
}

- (MICSvgPath*) createSvgPathForState:(MICUiViewState)state {
    NSString* path = [self.colorResources resourceOf:MICUiResTypeSVG_PATH forState:state fallbackState:MICUiViewStateNORMAL];
    return [MICPathRepository.instance getPath:path viewboxSize:_viewboxSize];
}

- (MICSvgPath*) getSvgPathForState:(MICUiViewState)state {
    switch(state) {
        default:
        case MICUiViewStateNORMAL:
            if(nil==_svgPathNormal) {
                _svgPathNormal = [self createSvgPathForState:state];
            }
            return _svgPathNormal;
        case MICUiViewStateSELECTED:
            if(nil==_svgPathSelected) {
                _svgPathSelected = [self createSvgPathForState:state];
            }
            return _svgPathSelected;
        case MICUiViewStateACTIVATED:
            if(nil==_svgPathActivated) {
                _svgPathActivated = [self createSvgPathForState:state];
            }
            return _svgPathActivated;
        case MICUiViewStateDISABLED:
            if(nil==_svgPathDisabled) {
                _svgPathDisabled = [self createSvgPathForState:state];
            }
            return _svgPathDisabled;
    }
}

- (UIColor*) getIconColorForState:(MICUiViewState)state {
    UIColor* color = [self.colorResources resourceOf:(MICUiResTypeSVG_COLOR) forState:state fallbackState:MICUiViewStateNORMAL];
    if(nil==color) {
        color = [self.colorResources resourceOf:(MICUiResTypeFGCOLOR) forState:state fallbackState:MICUiViewStateNORMAL];
    }
    return color;
}

- (MICSvgPath*) currentSvgPath {
    return [self getSvgPathForState:self.buttonState];
}

- (UIColor*) currentIconColor {
    return [self getIconColorForState:self.buttonState];
}

- (CGRect) calcIconRect {
    MICRect rc(_iconSize);
    MICPoint center(self.contentMargin.left+_iconSize.width/2, rc.center().y);
    rc.moveCenter(center);
    return rc;
}

- (CGSize) calcPlausibleButtonSizeFotHeight:(CGFloat)height forState:(MICUiViewState)state {
    MICEdgeInsets margin(self.contentMargin);
    CGFloat spacing = 0;
    MICSize textSize;
    NSTextAlignment halign = NSTextAlignmentCenter;
    
    if(nil!=self.text) {
        spacing = self.iconTextMargin;
        halign = NSTextAlignmentLeft;
    }
    
    if(nil!=self.text) {
        NSDictionary *attr = [self getTextAttributes:halign];
        textSize = [self.text sizeWithAttributes:attr];
    }
    return MICSize(_iconSize.width + spacing + textSize.width + margin.dw(), MAX(_iconSize.height, textSize.height+margin.dh()));
}

- (void)sizeToFit {
    self.frame = MICRect(self.frame.origin, [self calcPlausibleButtonSizeFotHeight:0 forState:MICUiViewStateNORMAL]);
}

- (void)getContentRect:(UIImage*)icon iconRect:(CGRect*)prcIcon textRect:(CGRect*)prcText {
    MICRect rcBounds = self.bounds;
    MICRect rcContent = rcBounds;
    rcContent.deflate(self.contentMargin);
    
    MICRect rcIcon([self calcIconRect]);
    *prcIcon = rcIcon;
    
    // text & icon
    MICRect rcText = rcContent;
    rcText.setLeft( rcIcon.right()+self.iconTextMargin);
    *prcText = rcText;
}


- (void)drawIcon:(CGContextRef)rctx icon:(UIImage *)icon rect:(CGRect)rect {
    let svgPath = self.currentSvgPath;
    if(nil!=svgPath) {
        [svgPath fill:rctx dstRect:rect fillColor:self.currentIconColor];
    }
}

@end
