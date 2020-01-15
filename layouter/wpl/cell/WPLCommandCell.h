//
//  WPLCommandCell.h
//  UIButton を内包して、tappedイベントを発行するセル
//
//  Created by Mitsuki Toyota on 2019/12/17.
//  Copyright © 2019 MichaelSoft. All rights reserved.
//

#import "WPLCell.h"

@interface WPLCommandCell : WPLCell<IWPLCellSupportCommand>

// protected
- (void) onButtonTapped:(id)sender;
@property (nonatomic,readonly) bool tappedListenerRegistered;

@end

