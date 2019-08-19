//
//  WPLCellHostingScrollView.h
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"
#import "WPLBinder.h"

@interface WPLCellHostingScrollView : UIScrollView

@property (nonatomic) id<IWPLContainerCell> containerCell;
@property (nonatomic,readonly) WPLBinder* binder;

- (instancetype)initWithFrame:(CGRect)frame container:(id<IWPLContainerCell>) containerCell;

@end

