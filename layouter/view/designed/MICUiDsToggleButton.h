//
//  MICUiDsToggleButton.h
//  ボタンタップで選択状態がトグルするボタン
//
//  Created by toyota.m2k on 2020/10/15.
//  Copyright © 2020 toyota.m2k. All rights reserved.
//

#import "MICUiDsSvgIconButton.h"
#import "WPLValueCell.h"

@interface MICUiDsToggleButton : MICUiDsSvgIconButton<MICUiDsCustomButtonDelegate>

/**
 * チェックボタンの状態が変化したときのイベント
 */
- (void)setSelectedListener:(id)target action:(SEL)action;

@end

@interface MICUiDsToggleButtonCell : WPLValueCell<IWPLCellSupportCommand>

@end
