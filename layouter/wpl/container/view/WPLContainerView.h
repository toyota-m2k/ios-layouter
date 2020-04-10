//
//  WPLContainerView.h
//
//  Created by @toyota-m2k on 2020/04/10.
//  Copyright (C) 2020 @toyota-m2k. All rights reserved.
//

#import "WPLCellHostingView.h"

@interface WPLContainerView : WPLCellHostingView

@property (nonatomic,readonly) id<IWPLContainerCell> container;

- (instancetype) initWithFrame:(CGRect)frame container:(id<IWPLContainerCell>)containerCell scrollable:(WPLScrollOrientation)scrollable;

@end

