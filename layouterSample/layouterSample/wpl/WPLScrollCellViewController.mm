//
//  WPLScrollCellViewController.m
//  layouterSample
//
//  Created by Mitsuki Toyota on 2020/04/02.
//  Copyright © 2020 Mitsuki Toyota. All rights reserved.
//

#import "WPLScrollCellViewController.h"
#import "WPLGridView.h"
#import "WPLScrollCell.h"
#import "WPLContainersL.h"
#import "WPLCommandCell.h"
#import "WPLProperty.h"
#import "MICAutoLayoutBuilder.h"
#import "MICVar.h"

@interface WPLScrollCellViewController ()

@end

@implementation WPLScrollCellViewController {
    WPLCommand* _backCommand;
}

inline UIColor* nextColor(NSArray<UIColor*>* colors, int& index) {
    if(index>=colors.count) {
        index = 0;
    }
    return colors[index++];
}

- (void)createScrollerContents:(WPLScrollCell*) scroller {
//    let row = 10, column = 10;
//    let row=2, column=2;
//    let row=10, column=2;
    let row=2, column=10;
    let grid = [WPLGrid gridWithName:[NSString stringWithFormat:@"Grid(%@)", scroller.name] params:WPLGridParams().requestViewSize(VAUTO,VAUTO).cellSpacing(10,10).rowDefs(@[AUTO,AUTO,AUTO,AUTO, AUTO,AUTO,AUTO,AUTO, AUTO,AUTO]).colDefs(@[AUTO,AUTO,AUTO,AUTO, AUTO,AUTO,AUTO,AUTO, AUTO,AUTO]).align(A_CENTER,A_CENTER)];
    let colors = @[UIColor.blueColor, UIColor.brownColor, UIColor.cyanColor, UIColor.greenColor, UIColor.magentaColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.redColor, UIColor.yellowColor];
    int index = 0;
    for(int i=0 ; i<row ; i++) {
        for(int j=0 ; j<column ; j++) {
            let view = [[UIView alloc] init];
            view.backgroundColor = nextColor(colors, index);
            [grid addCell:[WPLCell newCellWithView:view name:[NSString stringWithFormat:@"(%@)-r:%d,c:%d", scroller.name, i, j] params:WPLCellParams().requestViewSize(100,100)] row:i column:j];
        }
    }
    [scroller addCell:grid];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    let gridView = [WPLGridView gridViewWithName:@"rootGrid" params:WPLGridParams().requestViewSize(VSTRC,VSTRC).rowDefs(@[AUTO,STRC,AUTO]).colDefs(@[STRC,STRC,STRC]).margin(MICEdgeInsets(10)).cellSpacing(MICSize(20,0))];

    let header = [[UILabel alloc] init];
    header.text = @"Scroll Cell Test";
    header.textColor = [UIColor blackColor];
    [header sizeToFit];
    [gridView.container addCell:[WPLCell newCellWithView:header name:@"header" params:WPLCellParams().align(A_LEFT,A_CENTER)] row:0 column:0];

    let footer = [[UILabel alloc] init];
    footer.text = @"Copyright (C) @toyota.m2k";
    footer.textColor = [UIColor blackColor];
    [footer sizeToFit];
    [gridView.container addCell:[WPLCell newCellWithView:header name:@"footer" params:WPLCellParams().align(A_CENTER,A_CENTER)] row:2 column:1];

    let btn = [[UIButton alloc] initWithFrame:MICRect::zero()];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    let backCell = [WPLCommandCell newCellWithView:btn name:@"backButton" params:WPLCellParams().align(A_RIGHT, A_CENTER)];
    [gridView.container addCell:backCell row:0 column:2];
    
    let scrollerV = [WPLScrollCell scrollCellWithName:@"ScrollerVert" params:WPLScrollCellParams(WPLScrollOrientationVERT).align(A_CENTER,A_CENTER)];
    [self createScrollerContents:scrollerV];
    let scrollerH = [WPLScrollCell scrollCellWithName:@"ScrollerHorz" params:WPLScrollCellParams(WPLScrollOrientationHORZ).align(A_CENTER,A_CENTER)];
    [self createScrollerContents:scrollerH];
    let scrollerB = [WPLScrollCell scrollCellWithName:@"ScrollerBoth" params:WPLScrollCellParams(WPLScrollOrientationBOTH).align(A_CENTER,A_CENTER)];
    [self createScrollerContents:scrollerB];

    [gridView.container addCell:scrollerV row:1 column:0];
    [gridView.container addCell:scrollerH row:1 column:1];
    [gridView.container addCell:scrollerB row:1 column:2];

    _backCommand = [WPLCommand commandAsName:@"back" initialValue:nil];
    [_backCommand.subject subscribe:^(id value) { [self dismissViewControllerAnimated:false completion:nil]; }];
    
    WPLBinderBuilder(gridView.binder)
    .command(_backCommand, backCell);
    
    [self.view addSubview:gridView.view];
    
    MICAutoLayoutBuilder(self.view)
    .fitToSafeArea(gridView.view);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void) backToPrev {
//    [self dismissViewControllerAnimated:false completion:nil];
//}

@end
