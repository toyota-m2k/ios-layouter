//
//  WPLSliderCell.mm
//
//  Created by @toyota-m2k on 2020/02/03.
//  Copyright @toyota-m2k. All rights reserved.
//

#import "WPLSliderCell.h"
#import "MICDicUtil.h"
#import "MICVar.h"

@implementation WPLSliderCell {
}

- (instancetype) initWithView:(UIView*)view
                         name:(NSString*) name
                       margin:(UIEdgeInsets) margin
              requestViewSize:(CGSize) requestViewSize
                   hAlignment:(WPLCellAlignment)hAlignment
                   vAlignment:(WPLCellAlignment)vAlignment
                   visibility:(WPLVisibility)visibility
            containerDelegate:(id<IWPLContainerCellDelegate>)containerDelegate {
    if(nil==view) {
        view = [[UISlider alloc] init];
    }
    NSAssert([view isKindOfClass:UISlider.class], @"WPLSwitchCell: view must be instance of UISlider");
    self = [super initWithView:view name:name margin:margin requestViewSize:requestViewSize hAlignment:hAlignment vAlignment:vAlignment visibility:visibility containerDelegate:nil];
    if(nil!=self) {
        _useIntValue = false;
        ((UISlider*)view).minimumValue = 0;
        ((UISlider*)view).maximumValue = 100;
        [(UISlider*)view addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id) value {
    float v = ((UISlider*)self.view).value;
    if(self.useIntValue) {
        return @((NSInteger)(round(v)));
    } else {
        return @(v);
    }
}

- (void) setValue:(id)v {
    float value = ([v isKindOfClass:NSNumber.class]) ? ((NSNumber*)v).floatValue : 0;
    if(self.useIntValue) {
        value = round(value);
    }
    if(((UISlider*)self.view).value!=value) {
        ((UISlider*)self.view).value = value;
    }
}

- (void) onSliderValueChanged:(id) _ {
    [self onValueChanged];
}

- (void)dispose { 
    [super dispose];
}

- (id)addNamed:(NSString *)name valueListener:(id)target selector:(SEL)selector {
    return nil;
}

- (void)removeNamed:(NSString*)name valueListener:(id)key {
    return;
}

- (float) floatValueForName:(NSString*)name {
    if([name isEqualToString:WPLSliderCell_MIN_NAME]) {
        return ((UISlider*)self.view).minimumValue;
    } else if([name isEqualToString:WPLSliderCell_MAX_NAME]) {
        return ((UISlider*)self.view).maximumValue;
    } else {
        return 0;
    }
}

- (void) setFloatValue:(float)value forName:(NSString*)name {
    if([name isEqualToString:WPLSliderCell_MIN_NAME]) {
        [self setMin:value];
    } else if([name isEqualToString:WPLSliderCell_MAX_NAME]) {
        [self setMax:value];
    }
}

- (void) setValue:(id)value forName:(NSString *)name {
    [self setFloatValue:[value floatValue] forName:name];
}

- (id)valueForName:(NSString *)name {
    return @([self floatValueForName:name]);
}

- (float)min {
    return ((UISlider*)self.view).minimumValue;
}
- (void)setMin:(float)min {
    if(self.useIntValue) {
        min = round(min);
    }
    if(min!=self.min) {
        let old = ((UISlider*)self.view).value;
        ((UISlider*)self.view).minimumValue = min;
        if(((UISlider*)self.view).value != old) {
            [self onValueChanged];
        }
    }
}
- (float)max {
    return ((UISlider*)self.view).maximumValue;
}
- (void)setMax:(float)max {
    if(self.useIntValue) {
        max = round(max);
    }
    if(max!=self.max) {
        let old = ((UISlider*)self.view).value;
        ((UISlider*)self.view).maximumValue = max;
        if(((UISlider*)self.view).value != old) {
            [self onValueChanged];
        }
    }
}


@end
