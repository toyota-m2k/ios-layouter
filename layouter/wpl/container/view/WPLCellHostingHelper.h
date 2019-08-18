//
//  WPLCellHostingHelper.h
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/18.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPLContainerDef.h"

@interface WPLCellHostingHelper : NSObject <IWPLContainerCellDelegate>

@property (nonatomic) id<IWPLContainerCell> containerCell;

- (instancetype) initWithView:(UIView*) view;

- (void) dispose;

@end

