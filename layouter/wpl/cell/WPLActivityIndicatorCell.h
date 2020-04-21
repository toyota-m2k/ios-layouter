//
//  WPLActivityIndicatorCell.h
//
//  Created by toyota-m2k on 2020/04/16.
//  Copyright © 2020 toyota-m2k. All rights reserved.
//

#import "WPLValueCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPLActivityIndicatorCell : WPLValueCell

#ifdef __cplusplus
+ (instancetype) indicatorCellNamed:(NSString*)name style:(UIActivityIndicatorViewStyle)style params:(const WPLCellParams&) params;
#endif

@end

NS_ASSUME_NONNULL_END
