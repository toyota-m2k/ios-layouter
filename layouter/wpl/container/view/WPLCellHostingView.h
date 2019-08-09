//
//  WPLCellHostingView.h
//  WP Layouter
//
//  Created by Mitsuki Toyota on 2019/08/08.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"

@interface WPLCellHostingView : UIView <IWPLContainerCellDelegate>

@property (nonatomic) id<IWPLContainerCell> containerCell;

@end

