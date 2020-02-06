//
//  MICUiDsCheckBox.m
//  チェックマーク＋文字列のプレーンなチェックボックスクラス
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsCheckBox.h"
#import "MICVar.h"
#import "MICUiColorUtil.h"

@implementation MICUiDsCheckBox {
    MICTargetSelector* _actionOnChecked;
    bool _radioButton;
}

#pragma mark - Icon Path Definitions

#define PATH_SQUARE_BG @"M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3Z"
#define PATH_SQUARE @"M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3M19,5V19H5V5H19Z"
#define PATH_SQUARE_CHECKED @"M10,17L5,12L6.41,10.58L10,14.17L17.59,6.58L19,8M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3Z"

#define PATH_ROUND_BG @"M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"
#define PATH_ROUND @"M12,20A8,8 0 0,1 4,12A8,8 0 0,1 12,4A8,8 0 0,1 20,12A8,8 0 0,1 12,20M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"

#pragma mark - Initialization / Termination

- (instancetype)initWithFrame:(CGRect)frame
                        label:(NSString *)label
               forRadioButton:(bool)radioButton
              pathRepositiory:(MICPathRepository*) repo
          customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource {
    self = [super initWithFrame:frame iconSize:MICSize(24) pathViewboxSize:MICSize(24) pathRepositiory:repo];
    if(nil!=self) {
        var resource = [[MICUiStatefulResource alloc] init];
        if(colorResource!=nil) {
            // color customize
            [resource mergeWith:colorResource type:MICUiResTypeBGCOLOR state:MICUiViewStateNORMAL overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeFGCOLOR state:MICUiViewStateNORMAL overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeFGCOLOR state:MICUiViewStateDISABLED_ overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_COLOR state:MICUiViewStateNORMAL overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_COLOR state:MICUiViewStateSELECTED_ overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_COLOR state:MICUiViewStateDISABLED_ overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_BGCOLOR state:MICUiViewStateNORMAL overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_BGCOLOR state:MICUiViewStateSELECTED_ overwrite:true];
            [resource mergeWith:colorResource type:MICUiResTypeSVG_BGCOLOR state:MICUiViewStateDISABLED_ overwrite:true];
        }
        _radioButton = radioButton;
        self.text = label;
        if(_radioButton) {
            // 丸いチェックボックス
            [resource setResource:PATH_ROUND_BG forName:MICUiStatefulSvgBgPathNORMAL];
            [resource setResource:PATH_ROUND forName:MICUiStatefulSvgPathNORMAL];
        } else {
            // 四角いチェックボックス
            [resource setResource:PATH_SQUARE_BG forName:MICUiStatefulSvgBgPathNORMAL];
            [resource setResource:PATH_SQUARE forName:MICUiStatefulSvgPathNORMAL];
            [resource setResource:PATH_SQUARE_CHECKED forName:MICUiStatefulSvgPathSELECTED];
        }
        
        [resource mergeWithDictionary:@{
                      MICUiStatefulFgColorNORMAL: UIColor.blackColor,
                      MICUiStatefulFgColorDISABLED: UIColor.grayColor,
                      MICUiStatefulBgColorNORMAL: UIColor.clearColor,
                      MICUiStatefulSvgBgColorNORMAL: UIColor.whiteColor,
                      MICUiStatefulSvgColorNORMAL: UIColor.blackColor,
                      MICUiStatefulSvgColorSELECTED: MICUiColorRGB(0x0080FF),
                      MICUiStatefulSvgColorDISABLED:UIColor.grayColor
                      } overwrite:false];

        self.colorResources = resource;
        self.customButtonDelegate = self;
        self.textHorzAlignment = MICUiAlignLEFT;
    }
    return self;

}

/**
 * checkboxを作成
 */
+ (instancetype) checkboxWithLabel:(NSString*)label
                   pathRepositiory:(MICPathRepository*) repo
               customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource {
    let view = [[MICUiDsCheckBox alloc] initWithFrame:MICRect()
                                                label:label
                                       forRadioButton:false
                                      pathRepositiory:repo
                                  customColorResource:colorResource];
    [view sizeToFit];
    return view;
}

/**
 * radio button を作成
 */
+ (instancetype) radioButtonWithLabel:(NSString*)label
                      pathRepositiory:(MICPathRepository*) repo
                  customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource {
    let view = [[MICUiDsCheckBox alloc] initWithFrame:MICRect()
                                                label:label
                                       forRadioButton:true
                                      pathRepositiory:repo
                                  customColorResource:colorResource];
    [view sizeToFit];
    return view;
}

#pragma mark - Properties & Events


- (bool)checked {
    return self.selected;
}

- (void)setChecked:(bool)checked {
    self.selected = checked;
}

/**
 * チェックボタンの状態が変化したときのイベント
 * @param action    (void)onChanged:(MICUiDsCheckBox*)sender
 */
- (void)setCheckedListener:(id)target action:(SEL)action {
    if(target!=nil && action!=nil) {
        _actionOnChecked = [[MICTargetSelector alloc] initWithTarget:target selector:action];
    }
}

#pragma mark - Internals ... drawing

- (void)drawIcon:(CGContextRef)rctx icon:(UIImage *)icon rect:(CGRect)rect {
    if(!_radioButton) {
        [super drawIcon:rctx icon:nil rect:rect];
    } else {
        // BG
        let roundFill = [self.pathRepository getPath:PATH_ROUND_BG viewboxSize:MICSize(24)];
        let roundStroke = [self.pathRepository getPath:PATH_ROUND viewboxSize:MICSize(24)];
        UIColor* colorBg = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_BGCOLOR];
        if(colorBg!=nil) {
            CGFloat r = 1.0/24.0/2.0;
            MICRect rcBg(rect-MICEdgeInsets(rect.size.width*r, rect.size.height*r));
            [roundFill fill:rctx dstRect:rcBg fillColor:colorBg];
        }
        // Circle
        let state = MICUiViewState_IsDisabled(self.buttonState) ? MICUiViewStateDISABLED_:MICUiViewStateNORMAL;
        UIColor* colorStroke = [self resource:self.colorResources onState:state ForType:MICUiResTypeSVG_COLOR];
        [roundStroke fill:rctx dstRect:rect fillColor:colorStroke];
        
        // checkmark
        if(MICUiViewState_IsSelected(self.buttonState)) {
            UIColor* colorCheck = [self resource:self.colorResources onStateForType:MICUiResTypeSVG_COLOR];
            CGFloat r = 12.0/24.0/2.0;
            MICRect rcCheck(rect-MICEdgeInsets(rect.size.width*r, rect.size.height*r));
            [roundFill fill:rctx dstRect:rcCheck fillColor:colorCheck];
        }
    }
}

#pragma mark - MICUiDsCustomButtonDelegate i/f

/**
 * ボタンの状態(buttonStateプロパティ)が変更されたときの通知
 */
- (void) onCustomButtonStateChangedAt:(MICUiDsCustomButton*)view from:(MICUiViewState)before to:(MICUiViewState)after {
    
}

/**
 * ボタンがタップされたときの通知
 */
- (void) onCustomButtonTapped:(MICUiDsCustomButton*)view {
    if(_radioButton && self.selected) {
        return; // onのラジオボタンをタップしてもオフにしない
    }
    // トグル
    self.selected = !self.selected;
    if(nil!=_actionOnChecked) {
        id me = self;
        [_actionOnChecked performWithParam:&me];
    }
}

@end

#pragma mark - IWPLCell Supports

@implementation MICUiDsChackBoxCell

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    NSAssert([view isKindOfClass:MICUiDsCheckBox.class], @"MICTmChackBoxCell: view must be instance of MICUiDsCheckBox");
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(nil!=self) {
        [(MICUiDsCheckBox*)view setCheckedListener:self action:@selector(onSwitchChanged:)];
    }
    return self;
}

- (id) value {
    return @(((MICUiDsCheckBox*)self.view).checked);
}

- (void) setValue:(id)v {
    bool bv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).boolValue : false;
    if(!(((MICUiDsCheckBox*)self.view).checked)!=!bv) {
        ((MICUiDsCheckBox*)self.view).checked = bv;
    }
}

- (void) onSwitchChanged:(id) _ {
    [self onValueChanged];
}

@end
