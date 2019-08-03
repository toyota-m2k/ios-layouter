//
//  WPLSampleView.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2019/08/03.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "WPLSampleView.h"
#import "MICUiRectUtil.h"
#import "WPLTextCell.h"
#import "WPLStackPanel.h"
#import "MICVar.h"

@implementation WPLSampleView {
    WPLStackPanel* _stackPanel;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self!=nil) {
        //self.backgroundColor = UIColor.greenColor;
        _stackPanel = [WPLStackPanel stackPanelViewWithName:@"rootStackPanel"
                                                     margin:MICEdgeInsets()
                                            requestViewSize:MICSize()
                                                 hAlignment:WPLCellAlignmentCENTER
                                                 vAlignment:WPLCellAlignmentCENTER
                                                 visibility:WPLVisibilityVISIBLE
                                          containerDelegate:self
                                                orientation:WPLOrientationVERTICAL];
        [self addSubview:_stackPanel.view];
        
        let tv1 = [[UITextView alloc] init];
        tv1.text = @"Wg";
        [tv1 sizeToFit];
        tv1.text = @"";
        tv1.backgroundColor = UIColor.cyanColor;
        
        let tcell1 = [WPLTextCell newCellWithTextView:tv1 name:@"no1-text" margin:UIEdgeInsets() requestViewSize:MICSize(200,0) hAlignment:WPLCellAlignmentEND vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];

        let tv2 = [[UITextView alloc] initWithFrame:MICRect(0,0, 300, tv1.frame.size.height)];
        tv2.backgroundColor = UIColor.blueColor;
        
        let tcell2 = [WPLTextCell newCellWithTextView:tv2 name:@"no2-text" margin:MICEdgeInsets(0,20,0,0) requestViewSize:MICSize(0,0) hAlignment:WPLCellAlignmentSTART vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];

        let tv3 = [[UITextView alloc] initWithFrame:MICRect(0,0, 150, tv1.frame.size.height)];
        tv3.backgroundColor = UIColor.redColor;
        let tcell3 = [WPLTextCell newCellWithTextView:tv3 name:@"no3-text" margin:MICEdgeInsets(0,20,0,0) requestViewSize:MICSize(0,0) hAlignment:WPLCellAlignmentSTRETCH vAlignment:WPLCellAlignmentSTART visibility:WPLVisibilityVISIBLE];

        [_stackPanel addCell:tcell1];
        [_stackPanel addCell:tcell2];
        [_stackPanel addCell:tcell3];
        
        let innerPanel = [WPLStackPanel stackPanelViewWithName:@"innerStackPanel"
                                                        margin:MICEdgeInsets(0,20,0,0)
                                               requestViewSize:MICSize()
                                                    hAlignment:WPLCellAlignmentCENTER
                                                    vAlignment:WPLCellAlignmentCENTER
                                                    visibility:WPLVisibilityVISIBLE
                                             containerDelegate:self
                                                   orientation:WPLOrientationHORIZONTAL];
        [_stackPanel addCell:innerPanel];
        
        let v1 = [[UIView alloc] init];
        v1.backgroundColor = UIColor.purpleColor;
        let vc1 = [WPLCell newCellWithView:v1 name:@"v1" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
        [innerPanel addCell:vc1];
        let v2 = [[UIView alloc] init];
        v2.backgroundColor = UIColor.purpleColor;
        let vc2 = [WPLCell newCellWithView:v2 name:@"v2" margin:MICEdgeInsets(0,0,5,0) requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
        [innerPanel addCell:vc2];
        let v3 = [[UIView alloc] init];
        v3.backgroundColor = UIColor.purpleColor;
        let vc3 = [WPLCell newCellWithView:v3 name:@"v3" margin:MICEdgeInsets() requestViewSize:MICSize(20,20) hAlignment:(WPLCellAlignmentCENTER) vAlignment:(WPLCellAlignmentCENTER) visibility:(WPLVisibilityVISIBLE) containerDelegate:nil];
        [innerPanel addCell:vc3];

        
        [self addSubview:_stackPanel.view];
        
        [self onChildCellModified:_stackPanel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) onChildCellModified:(id<IWPLCell>) cell {
    MICSize size = [_stackPanel layout];
    MICRect rc(MICPoint(), size);
    rc.moveCenter(MICRect(self.frame).center());
    cell.view.frame = rc;
}

@end
