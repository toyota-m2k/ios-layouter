//
//  WPLSampleViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/18.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLSampleViewController.h"
#import "MICAutoLayoutBuilder.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "WPLStackPanelView.h"
#import "WPLBindViewController.h"
#import "WPLStackPanelSampleViewController.h"
#import "WPLGridSampleViewController.h"

@interface WPLSampleViewController ()

@end

@implementation WPLSampleViewController {
    WPLStackPanelView* _stackPanel;
}

enum {
    CMDStackPanel,
    CMDGridPanel,
    
    CMDOtherTest,
};

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    _stackPanel = [WPLStackPanelView stackPanelViewWithName:@"contentStack"
                                                     params:WPLStackPanelParams()
                                                            .orientation(WPLOrientationVERTICAL)
                                                            .align(WPLAlignment(WPLCellAlignmentCENTER))
                                                            .cellSpacing(15)];

    UIButton* btn;
    WPLCell* cell;
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDStackPanel;
    [btn setTitle:@"Stack Panel" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    cell = [WPLCell newCellWithView:btn name:@"StackPanelButton" params:WPLCellParams()];
    [_stackPanel.container addCell:cell];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDGridPanel;
    [btn setTitle:@"Grid Panel" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    cell = [WPLCell newCellWithView:btn name:@"GridPanelButton" params:WPLCellParams()];
    [_stackPanel.container addCell:cell];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDOtherTest;
    [btn setTitle:@"Other Test" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    cell = [WPLCell newCellWithView:btn name:@"GridPanelButton" params:WPLCellParams()];
    [_stackPanel.container addCell:cell];

    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(10, 20, 200, 50);
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    cell = [WPLCell newCellWithView:back name:@"BackButton" params:WPLCellParams().margin(MICEdgeInsets(0,10,0,0))];
    [_stackPanel.container addCell:cell];

    [self.view addSubview:_stackPanel];
    
    MICAutoLayoutBuilder(self.view)
    .fitToParent(_stackPanel, MICUiPosExALL, MICEdgeInsets(10));
    
}

- (void) onCommand:(id)sender {
    UIViewController* controller = nil;
    switch( [sender tag]) {
        case CMDStackPanel:
            controller = [[WPLStackPanelSampleViewController alloc] init];
            break;
        case CMDGridPanel:
            controller = [[WPLGridSampleViewController alloc] init];
            break;
        case CMDOtherTest:
            controller = [[WPLBindViewController alloc] init];
            break;
        default:
            return;
    }
    if(nil!=controller) {
        [self presentViewController:controller animated:true completion:nil];
    }
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
