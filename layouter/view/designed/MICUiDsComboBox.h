//
//  MICUiDsComboBox.h
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsSvgIconButton.h"
#import "MICUiLayout.h"
#import "WPLValueCell.h"

@interface MICUiDsLabelValue : NSObject
@property (nonatomic,readonly) NSString* label;
@property (nonatomic) NSInteger value;
+ (instancetype) label:(NSString*)label value:(NSInteger) value;
- (instancetype) initWithLabel:(NSString*)label value:(NSInteger)value;
@end

@class MICUiDsComboBox;
@protocol IMICUiDsComboBoxDelegate
- (void) onDropDownBegin:(MICUiDsComboBox*)combo;
- (void) onDropDownEnd:(MICUiDsComboBox*)combo selected:(MICUiDsLabelValue*) selected;
@end

@interface MICUiDsComboBox : MICUiDsSvgIconButton

@property (nonatomic,readonly) NSArray<MICUiDsLabelValue*>* itemList;
@property (nonatomic) MICUiEdge anchorPos;    // DropDownの表示位置を決める基準点
@property (nonatomic) id<IMICUiDsComboBoxDelegate> comboBoxDelegate;
@property (nonatomic) bool droppingDown;
@property (nonatomic) CGFloat maxDropDownHeight;

- (instancetype)initWithFrame:(CGRect)frame
                    andValues:(NSArray<MICUiDsLabelValue*>*) values
                 initialValue:(NSInteger)initialValue
                     rootView:(UIView*) rootView
               pathRepository:(MICPathRepository*) repo;

- (void) setValueChangedListener:(id)target action:(SEL)action;

@end

@interface MICUiDsComboBoxCell : WPLValueCell

@end
