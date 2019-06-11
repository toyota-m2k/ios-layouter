//
//  MICUiAccordionCellViewSwicherProc.h
//
//  AccordionCellとレイアウターを使って、ViewSwitcherMediatorの動作を利用するための実装
//
//  Created by @toyota-m2k on 2015/01/07.
//  Copyright (c) 2015年 @toyota-m2k. All rights reserved.
//

#import "MICUiSwitchingViewMediator.h"
#import "MICUiAccordionCellView.h"

@interface MICUiAccordionCellViewSwicherProc : NSObject<MICUiAccordionCellDelegate,MICUiViewVisibilityDelegate, MICUiSwitchingViewDelegate>

@property (nonatomic,weak) id<MICUiLayoutProtocol> layouter;
@property (nonatomic,weak) MICUiSwitchingViewMediator *switcher;

@property (nonatomic,strong) id<MICUiLayoutProtocol> strongLayouter;
@property (nonatomic,strong) MICUiSwitchingViewMediator *strongSwitcher;

@end
