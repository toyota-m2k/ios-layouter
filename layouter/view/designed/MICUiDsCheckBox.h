//
//  MICUiDsCheckBox.h
//  チェックボックス/ラジオボタン用にデザインされたトグルボタンの特殊型
//
//  Created by @toyota-m2k on 2020/02/04.
//  Copyright (c) 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsToggleButton.h"

@interface MICUiDsCheckBox : MICUiDsToggleButton

/**
 * @param radioButton false:四角いチェックボックス / true: 丸いチェックボックス（ラジオボタンとして利用）
 */
- (instancetype)initWithFrame:(CGRect)frame
                        label:(NSString *)label
               forRadioButton:(bool)radioButton
              pathRepositiory:(MICPathRepository*) repo
          customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource;

@property (nonatomic) bool checked;         // selectedのエイリアス：チェックボタンの状態(true: on / false:off：デフォルト）

/**
 * checkboxを作成
 */
+ (instancetype) checkboxWithLabel:(NSString*)label
                   pathRepositiory:(MICPathRepository*) repo
               customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource;

/**
 * radio button を作成
 */
+ (instancetype) radioButtonWithLabel:(NSString*)label
                      pathRepositiory:(MICPathRepository*) repo
                  customColorResource:(id<MICUiStatefulResourceProtocol>)colorResource;
/**
 * チェックボタンの状態が変化したときのイベント
 * ToggleButton#setSelectedListener のエイリアス
 */
- (void)setCheckedListener:(id)target action:(SEL)action;



@end

@interface MICUiDsChackBoxCell : MICUiDsToggleButtonCell

@end

