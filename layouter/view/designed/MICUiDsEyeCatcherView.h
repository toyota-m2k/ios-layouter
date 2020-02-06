//
//  MICUiDsEyeCatcherView.h
//
//  Created by @toyota-m2k on 2020/02/05.
//  Copyright © 2020 @toyota-m2k. All rights reserved.
//

#import "MICUiDsSvgIconButton.h"

@interface MICUiDsEyeCatcherView : MICUiDsSvgIconButton

- (instancetype) initWithMessage:(NSString*) string
                     isMultiLine:(bool) isMultiLine
                  pathRepository:(MICPathRepository*) repo;

@end

