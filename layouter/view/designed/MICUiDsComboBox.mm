//
//  MICUiDsComboBox.m
//  選択項目のラベル表示ビュー＋PDリストを持ったビュークラス
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsComboBox.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "WPLStackPanelView.h"
#import "WPLStackPanelScrollView.h"
#import "MICUiColorUtil.h"
#import "WPLCommandCell.h"
#import "WPLContainersL.h"
#import "WPLObservableMutableData.h"
#import "MICUiDsGuardView.h"

@implementation MICUiDsLabelValue

- (instancetype)initWithLabel:(NSString *)label value:(NSInteger)value {
    self = [super init];
    if(nil!=self) {
        _label = label;
        _value = value;
    }
    return self;
}

+ (instancetype)label:(NSString *)label value:(NSInteger)value {
    return [[self alloc] initWithLabel:label value:value];
}

@end

@implementation MICUiDsComboBox {
    NSArray<MICUiDsLabelValue*>* _values;
//    NSInteger _currentValue;
    WPLObservableMutableData* _currentValue;
    bool _droppingDown;
    MICTargetSelector* _valueChangedListener;
    UIView* _dropDownMenu;
    NSString* _calculatingSizeTarget;
    id<IWPLStackPanelView> _hostView;
}

- (MICUiDsLabelValue*) labelValueOf:(NSInteger)value {
    let index = [_values indexOfObjectPassingTest:^BOOL(MICUiDsLabelValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.value == value;
    }];
    if(index != NSNotFound) {
        return _values[index];
    }
    return nil;
}

- (NSString*) currentLabel {
    return ((MICUiDsLabelValue*)_currentValue.value).label;
}

- (NSInteger) value {
    return ((MICUiDsLabelValue*)_currentValue.value).value;
}


- (void) setValue:(NSInteger)value {
    let lv = [self labelValueOf:value];
    if(nil!=lv) {
        if(self.value != lv.value) {
            _currentValue.value = lv;
            self.text = lv.label;
            if(nil!=_valueChangedListener) {
                id me = self;
                [_valueChangedListener performWithParam:&me];
            }
        }
    }
}

- (void)setRootView:(UIView *)rootView {
    if(_rootView!=rootView) {
        if(_dropDownMenu!=nil) {
            [_dropDownMenu removeFromSuperview];
            _dropDownMenu = nil;
        }
        _rootView = rootView;
    }
}

#define PATH_CHEVRON @"M7.41,8.58L12,13.17L16.59,8.58L18,10L12,16L6,10L7.41,8.58Z"
#define PATH_CHECKED @"M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"

- (instancetype)initWithFrame:(CGRect)frame
                    andValues:(NSArray<MICUiDsLabelValue*>*) values
                 initialValue:(NSInteger)initialValue
                     rootView:(UIView*) rootView
               pathRepository:(MICPathRepository*) repo {
    self = [super initWithFrame:frame iconSize:MICSize(24) pathViewboxSize:MICSize(24) pathRepositiory:repo];
    if(self!=nil) {
        _values = values;
        _currentValue = [[WPLObservableMutableData alloc] init];
        _currentValue.value = [self labelValueOf:initialValue];
        _rootView = rootView;
        self.text = self.currentLabel;
        self.colorResources = [[MICUiStatefulResource alloc] initWithDictionary:@{
            MICUiStatefulSvgPathNORMAL:PATH_CHEVRON,
            MICUiStatefulSvgColorNORMAL:UIColor.lightGrayColor,
            MICUiStatefulSvgColorDISABLED:UIColor.clearColor,
            MICUiStatefulFgColorNORMAL: UIColor.blackColor,
            MICUiStatefulFgColorDISABLED: UIColor.grayColor,
            MICUiStatefulBgColorNORMAL: UIColor.whiteColor,
            MICUiStatefulBorderColorNORMAL:UIColor.grayColor,
        }];
        [self setTarget:self action:@selector(onTapped:)];
        _droppingDown = false;
        _valueChangedListener = nil;
        _comboBoxDelegate = nil;
        _calculatingSizeTarget = nil;
        _hostView = nil;
        self.textHorzAlignment = MICUiAlignLEFT;
        self.contentMargin += MICEdgeInsets(4,0,0,0);
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if(nil==newSuperview) {
        if(_dropDownMenu!=nil) {
            [_dropDownMenu removeFromSuperview];
            _dropDownMenu = nil;
        }
        if(nil!=_hostView) {
            [_hostView dispose];
            _hostView = nil;
        }
    }
}


- (void) setValueChangedListener:(id)target action:(SEL)action {
    if(nil!=target && nil!=action) {
        _valueChangedListener = [MICTargetSelector target:target selector:action];
    } else {
        _valueChangedListener = nil;
    }
}

/**
 * テキストの右側にアイコン（チェブロンみたいなの）を配置
 */
- (void)getContentRect:(UIImage *)icon iconRect:(CGRect *)prcIcon textRect:(CGRect *)prcText {
    MICRect rcIcon, rcText;
    [super getContentRect:icon iconRect:&rcIcon textRect:&rcText];
    
    MICRect rcText2 = MICRect::XYWH(rcIcon.left(), rcText.top(), rcText.width(), rcText.height());
    *prcText = rcText2;
    *prcIcon = MICRect::XYWH(rcText2.right()+self.iconTextMargin, rcIcon.top(), rcIcon.width(), rcIcon.height());
}

- (NSString *)text {
    if(_calculatingSizeTarget!=nil) {
        return _calculatingSizeTarget;
    }
    return super.text;
}

- (CGSize)calcPlausibleButtonSizeFotHeight:(CGFloat)height forState:(MICUiViewState)state {
    MICSize size;
    for(MICUiDsLabelValue* v in _values) {
        _calculatingSizeTarget = v.label;
        MICSize s([super calcPlausibleButtonSizeFotHeight:0 forState:MICUiViewStateNORMAL]);
        size.width = MAX(size.width, s.width);
        size.height = MAX(size.height, s.height);
    }
    _calculatingSizeTarget = nil;
    return size;
}

- (void) onTapped:(MICUiDsCustomButton*)sender {
    [self toggleDrop];
}

- (void) setDroppingDown:(bool)droppingDown {
    if(droppingDown) {
        [self startDrop];
    }
}

- (void) startDrop {
    if(_droppingDown) {
        return;
    }
    _droppingDown = true;
    if(nil==_dropDownMenu) {
        [self prepareDropDownMenu];
    }
    _dropDownMenu.hidden = false;

    if(_comboBoxDelegate!=nil) {
        [_comboBoxDelegate onDropDownBegin:self];
    }
}

- (void) endDrop:(MICUiDsLabelValue*)lv {
    if(!_droppingDown) {
        return;
    }
    _droppingDown = false;
    _dropDownMenu.hidden = true;
    if(lv!=nil) {
        self.value = lv.value;
    }
    if(_comboBoxDelegate!=nil) {
        [_comboBoxDelegate onDropDownEnd:self selected:lv];
    }
}

- (void) toggleDrop {
    if(_droppingDown) {
        [self endDrop:nil];
    } else {
        [self startDrop];
    }
}

#define P_CURRENT @"current"

- (void) prepareDropDownMenu {
    NSAssert(_rootView!=nil, @"MICUiDsComboBox: rootView must be specified.");
    if(nil!=_dropDownMenu) {
        return;
    }
    if(self.maxDropDownHeight>0) {
        _hostView = [WPLStackPanelScrollView stackPanelViewWithName:@"combo" params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL).cellSpacing(1)];
    } else {
        _hostView = [WPLStackPanelView stackPanelViewWithName:@"combo" params:WPLStackPanelParams().orientation(WPLOrientationVERTICAL).cellSpacing(1)];
    }
    
    let container = _hostView.container;
    _hostView.view.backgroundColor = UIColor.grayColor;
    let resources = [[MICUiStatefulResource alloc] initWithDictionary:@{
        MICUiStatefulSvgPathNORMAL:PATH_CHECKED,
        MICUiStatefulSvgColorNORMAL:UIColor.clearColor,
        MICUiStatefulSvgColorSELECTED:MICUiColorRGB(0x5050FF),
        MICUiStatefulFgColorNORMAL: UIColor.blackColor,
        MICUiStatefulFgColorDISABLED: UIColor.grayColor,
        MICUiStatefulBgColorNORMAL: UIColor.whiteColor,
        MICUiStatefulBgColorSELECTED: MICUiColorRGB(0xE0FFFF),
        MICUiStatefulBgColorACTIVATED_SELECTED: MICUiColorRGB(0xA0FFFF),
    }];
    
    WPLBinderBuilder bb(_hostView.binder);
    bb.property(P_CURRENT, _currentValue);
    for(MICUiDsLabelValue* lv in _values) {
        let button = [[MICUiDsSvgIconButton alloc] initWithFrame:MICRect()
                                                        iconSize:MICSize(18)
                                                 pathViewboxSize:MICSize(24)
                                                 pathRepositiory:self.pathRepository];
        button.colorResources = resources;
        button.borderWidth=0;
        button.textHorzAlignment = MICUiAlignLEFT;
        button.contentMargin = button.contentMargin + MICEdgeInsets(4,4,8,4);
        button.tag = lv.value;
        button.text = lv.label;
        button.boldFont = self.boldFont;
        [button sizeToFit];
        [button setTarget:self action:@selector(onSelectItem:)];
        let cell = [WPLCell newCellWithView:button name:lv.label params:WPLCellParams().requestViewSize(MICSize(VSTRC,VAUTO))];
        NSInteger v = lv.value;
        bb.dependentProperty(lv.label, ^id(id<IWPLDelegatedDataSource>) {
                return @(v==self.value);
            }, P_CURRENT, nil)
          .bind(lv.label, cell, WPLPropTypeSELECTED);
        [container addCell:cell];
    }
    MICSize size([container layoutPrepare:MICSize()]);
    if(self.maxDropDownHeight>0 &&  self.maxDropDownHeight<size.height) {
        size.height = self.maxDropDownHeight;
    }
    
    MICRect rcMenu(size);
    MICRect rcButton(self.bounds);
    switch(self.anchorPos) {
        case MICUiEdgeLT:
            rcMenu.moveLeftBottom(rcButton.LT());
            break;
        case MICUIEdgeLB:
            rcMenu.moveLeftTop(rcButton.LB());
            break;
        case MICUiEdgeRT:
            rcMenu.moveRightBottom(rcButton.RT());
            break;
        case MICUIEdgeRB:
        default:
            rcMenu.moveRightTop(rcButton.RB());
            break;
    }
    
    _hostView.view.frame = [_rootView convertRect:rcMenu fromView:self];
    _dropDownMenu = [MICUiDsGuardView guardViewOnRootView:_rootView target:self action:@selector(onGuardTouch)];
    [_dropDownMenu addSubview:_hostView.view];
    [_rootView addSubview:_dropDownMenu];
}

- (void) onSelectItem:(UIView*)sender {
    [self endDrop:[self labelValueOf:sender.tag]];
}

- (void) onGuardTouch {
    [self endDrop:nil];
}



@end


@implementation MICUiDsComboBoxCell

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   limitWidth:(WPLMinMax) limitWidth
                  limitHeight:(WPLMinMax) limitHeight
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility {
    NSAssert([view isKindOfClass:MICUiDsComboBox.class], @"MICTmComboBoxCell: view must be instance of MICUiDsComboBox");
    self = [super initWithView:view
                          name:name
                        margin:margin
               requestViewSize:requestViewSize
                    limitWidth:limitWidth
                   limitHeight:limitHeight
                    hAlignment:hAlignment
                    vAlignment:vAlignment
                    visibility:visibility];
    if(nil!=self) {
        [(MICUiDsComboBox*)view setValueChangedListener:self action:@selector(onValueChanged:)];
    }
    return self;
}

- (id) value {
    return @(((MICUiDsComboBox*)self.view).value);
}

- (void) setValue:(id)v {
    NSInteger iv = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).intValue : 0;
    if(((MICUiDsComboBox*)self.view).value!=iv) {
        ((MICUiDsComboBox*)self.view).value = iv;
    }
}

- (void) onValueChanged:(id) _ {
    [self onValueChanged];
}

@end
