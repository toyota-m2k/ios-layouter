//
//  WPLCellHostingScrollView.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/18.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"

@interface WPLCellHostingScrollView : UIScrollView

@property (nonatomic) id<IWPLContainerCell> containerCell;

@end

