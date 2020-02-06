//
//  WPLCommandCell.h
//  UIButton を内包して、tappedイベントを発行するセル
//
//  Created by toyota-m2k on 2019/12/17.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLCell.h"

@interface WPLCommandCell : WPLCell<IWPLCellSupportCommand>

// protected
- (void) onButtonTapped:(id)sender;
@property (nonatomic,readonly) bool tappedListenerRegistered;

@end

