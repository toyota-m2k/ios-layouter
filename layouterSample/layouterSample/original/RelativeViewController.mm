//
//  RelativeViewController.m
//  DTable
//
//  Created by M.TOYOTA on 2014/11/27.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "RelativeViewController.h"
#import "MICUiRelativeLayout.h"
#import "MICUiRectUtil.h"
#import "MICUiCellDragSupport.h"

@interface RelativeViewController () {
    MICUiRelativeLayout* _layout;
    MICUiCellDragSupport* _dragger;
}

@end

static UIColor* colors[] = {
    //    [UIColor blackColor],      // 0.0 white
    [UIColor darkGrayColor],   // 0.333 white
    [UIColor lightGrayColor],  // 0.667 white
    //    [UIColor whiteColor],      // 1.0 white
    [UIColor grayColor],       // 0.5 white
    [UIColor redColor],       // 1.0, 0.0, 0.0 RGB
    [UIColor greenColor],      // 0.0, 1.0, 0.0 RGB
    [UIColor blueColor],       // 0.0, 0.0, 1.0 RGB
    [UIColor cyanColor],       // 0.0, 1.0, 1.0 RGB
    [UIColor yellowColor],     // 1.0, 1.0, 0.0 RGB
    [UIColor magentaColor],    // 1.0, 0.0, 1.0 RGB
    [UIColor orangeColor],     // 1.0, 0.5, 0.0 RGB
    [UIColor purpleColor],     // 0.5, 0.0, 0.5 RGB
    [UIColor brownColor],      // 0.6, 0.4, 0.2 RGB
    //    [UIColor clearColor],      // 0.0 white, 0.0 alpha
};
static int colorCount = sizeof(colors)/sizeof(colors[0]);
static int currentIndex = 0;

@implementation RelativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton* back;
    back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(10, 20, 200, 50);
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    MICRect rc = self.view.frame;
    rc.deflate(10, 100, 10, 10);
    _layout = [[MICUiRelativeLayout alloc] init];
    _layout.overallSize = rc.size;
    _layout.marginTop = 100;
    _layout.marginLeft = 10;
    _layout.parentView = self.view;
    
    _dragger = [[MICUiCellDragSupport alloc] init];
    _dragger.layouter = _layout;
    _dragger.baseView = self.view;
    

    UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    label1.backgroundColor = colors[currentIndex%colorCount]; currentIndex++;
    label1.textColor = [UIColor whiteColor];
    label1.text = [NSString stringWithFormat:@"LABEL-%d",currentIndex];
    label1.frame = MICRect(0,0,50,20);
    
    // 横方向：親枠からの距離(左右１５ｐｘ）サイズ自由　／　縦方向：親枠上端にアタッチ、サイズ不変
    [_layout addChild:label1
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingFree]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachParent:15]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachParent:15]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachParent:0]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];
//    [_dragger enableDragEventHandlerOnChildView:label1];

    UILabel* label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    label2.backgroundColor = colors[currentIndex%colorCount]; currentIndex++;
    label2.textColor = [UIColor whiteColor];
    label2.text = [NSString stringWithFormat:@"LABEL-%d",currentIndex];
    label2.frame = MICRect(0,0,50,20);

    /// 横方向：センタリング：サイズ不変　／縦方向：最初のラベルの下に配置：サイズ不変
    [_layout addChild:label2
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachCenter]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:label1 inDistance:5]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];
//    [_dragger enableDragEventHandlerOnChildView:label2];

    // 縦横センタリング（サイズ不変）
    UILabel* label3 = [[UILabel alloc] initWithFrame:CGRectZero];
    label3.backgroundColor = colors[currentIndex%colorCount]; currentIndex++;
    label3.textColor = [UIColor whiteColor];
    label3.text = [NSString stringWithFormat:@"LABEL-%d",currentIndex];
    label3.frame = MICRect(0,0,50,30);
    [_layout addChild:label3];
//    [_dragger enableDragEventHandlerOnChildView:label3];

    // label3 の右側／上端合わせ
    UILabel* label4 = [[UILabel alloc] initWithFrame:CGRectZero];
    label4.backgroundColor = colors[currentIndex%colorCount]; currentIndex++;
    label4.textColor = [UIColor whiteColor];
    label4.text = [NSString stringWithFormat:@"LABEL-%d",currentIndex];
    label4.frame = MICRect(0,0,50,40);
    [_layout addChild:label4
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:label3 inDistance:5]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachFitTo:label3 inDistance:0]
                                                                //top:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:label3 inDistance:0]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachFree]]];
//    [_dragger enableDragEventHandlerOnChildView:label4];


    // label3 の左　／　label4と下揃え　label1の半分の幅
    UILabel* label5 = [[UILabel alloc] initWithFrame:CGRectZero];
    label5.backgroundColor = colors[currentIndex%colorCount]; currentIndex++;
    label5.textColor = [UIColor whiteColor];
    label5.text = [NSString stringWithFormat:@"LABEL-%d",currentIndex];
    label5.frame = MICRect(0,0,50,20);
    [_layout addChild:label5
              andInfo:[[MICUiRelativeLayoutInfo alloc] initWithHorz:[MICUiRelativeLayoutScalingInfo newScalingRelativeToView:label1 inRatio:0.5]
                                                               left:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                              right:[MICUiRelativeLayoutAttachInfo newAttachAdjacent:label3 inDistance:5]
                                                               vert:[MICUiRelativeLayoutScalingInfo newScalingNoSize]
                                                                top:[MICUiRelativeLayoutAttachInfo newAttachFree]
                                                             bottom:[MICUiRelativeLayoutAttachInfo newAttachFitTo:label4 inDistance:0]]];
//    [_dragger enableDragEventHandlerOnChildView:label5];
    [_layout updateLayout:false onCompleted:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [_dragger beginCustomizingWithLongPress:true endWithTap:true];
}

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
